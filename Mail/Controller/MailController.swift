//
//  MailController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 15/04/2021.
//

import UIKit
import MSGraphClientModels

protocol MailControllerMailListDelegate {
    func updateFolderMenu(_ folderList: [MSGraphMailFolder])
    func updateTitle(_ title: NSAttributedString)
    func updateViewSate(_ state: State)
}

protocol MailControllerMailCollectionDataSource {
    func updateDataSource(_ mailList: [MSGraphMessage])
}

final class MailController {
    
    // MARK:- Properties
    
    // Private
    
    private var mailCache = Cache<MSGraphMailFolder, [MSGraphMessage]>()
    private var nextLinkCache = Cache<MSGraphMailFolder, URL>()
    
    // MailListVC
    private var mailFolder = [MSGraphMailFolder]() {
        didSet {
            mailListDelegate?.updateFolderMenu(mailFolder)
        }
    }
    
    var selectedFolder: MSGraphMailFolder! {
        didSet {
            updateTitle()
        }
    }
    
    var mailListDelegate: MailControllerMailListDelegate?
    
    // MailCollectionVC
    var dataSource: MailControllerMailCollectionDataSource?
    private(set) var mailList = [MSGraphMessage]() {
        didSet {
            dataSource?.updateDataSource(mailList)
        }
    }
    
    // MailDetailVC
    private(set) var selectedMail: MSGraphMessage? {
        didSet {
            updateIsRead()
        }
    }
    
    // MARK: - Mail list methods
    
    func updateMessage(_ newMessage: MSGraphMessage) {
        for (index, message) in mailList.enumerated() {
            if message.entityId == newMessage.entityId {
                mailList[index] = newMessage
                readFormeFolder(newMessage)
                break
            }
        }
    }
    
    func switchFolder(_ newFolder: MSGraphMailFolder) {
        mailListDelegate?.updateViewSate(.loading)
        mailCache[selectedFolder] = mailList
        nextLinkCache[selectedFolder] = GraphManager.instance.nextLink
        selectedFolder = newFolder
        mailList = []
        getMessages()
    }
    
    private func updateTitle() {
        let text = NSMutableAttributedString(string: "\(selectedFolder.displayName!)   \(selectedFolder.unreadItemCount)")
        text.setAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),
                            NSAttributedString.Key.foregroundColor: UIColor.systemBlue],
                           range: NSMakeRange(0, selectedFolder.displayName!.count))
        mailListDelegate?.updateTitle(text)
    }
    
    func setSelectedMail(_ indexPath: IndexPath) {
        selectedMail = mailList[indexPath.row]
    }
    
    // MARK: - Mail detail methods
    
    func mail(at indexPath: IndexPath) -> MSGraphMessage {
        return mailList[indexPath.row]
    }
    
    private func deleteFromFolder(_ message: MSGraphMessage) {
        selectedFolder.unreadItemCount -= message.isRead ? 0 : 1
        updateTitle()
    }
    
    private func readFormeFolder(_ message: MSGraphMessage) {
        selectedFolder.unreadItemCount += message.isRead ? -1 : 1
        updateTitle()
    }

}

// MARK: - Graph manager methods

extension MailController {
    
    func getUserMailContext() {
        getMailFolder()
    }
    
    private func getMailFolder() {
        GraphManager.instance.getMailFolders { (foldersArray, error) in
            DispatchQueue.main.async {
                
                guard let foldersArray = foldersArray, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    self.mailListDelegate?.updateViewSate(.error(error!))
                    return
                }
                
                self.mailFolder = foldersArray
                self.selectedFolder = foldersArray[1] // The second folder refers to the inbox
                self.getMessages()
            }
        }
    }
    
    private func getMessages() {
        guard mailCache[selectedFolder] == nil else {
            mailList = mailCache[selectedFolder]!
            mailListDelegate?.updateViewSate(.loaded)
            GraphManager.instance.nextLink = nextLinkCache[selectedFolder]
            return
        }
        
        GraphManager.instance.getMail(from: selectedFolder) { (messages, error) in
            DispatchQueue.main.async {
                
                guard let messages = messages, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    self.mailListDelegate?.updateViewSate(.error(error!))
                    return
                }
                
                self.mailList = messages
                self.mailListDelegate?.updateViewSate(.loaded)
            }
        }
    }
    
    func getNextPage() {
        GraphManager.instance.getNextPage { (messages, error) in
            DispatchQueue.main.async {
                
                guard let messages = messages, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    self.mailListDelegate?.updateViewSate(.error(error!))
                    return
                }
                
                self.mailList.append(contentsOf: messages)
                self.mailListDelegate?.updateViewSate(.loaded)
            }
        }
    }
    
    private func updateIsRead() {
        guard let mail = selectedMail else { return }
        GraphManager.instance.updateRead(for: mail, newValue: true) { (message, error) in
            DispatchQueue.main.async {
                
                guard let message = message, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    return
                }
                
                self.updateMessage(message)
            }
        }
    }
    
    func updateIsRead(for mail: MSGraphMessage, with completion: @escaping (Bool) -> Void) {
        GraphManager.instance.updateRead(for: mail, newValue: !mail.isRead) { (message, error) in
            DispatchQueue.main.async {
                
                guard let message = message, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    completion(false)
                    return
                }
                
                self.updateMessage(message)
                completion(true)
            }
        }
    }
    
    func deleteMessage(_ message: MSGraphMessage, completion: ((Bool) -> Void)? = nil) {
        GraphManager.instance.delete(message: message) { (error) in
            DispatchQueue.main.async { [self] in
                guard error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    completion?(false)
                    return
                }
                mailList.removeAll { $0.entityId == message.entityId }
                self.deleteFromFolder(message)
                completion?(true)
            }
        }
    }
}
