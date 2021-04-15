//
//  MailController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 15/04/2021.
//

import UIKit
import MSGraphClientModels

class MailController {
    
    private var mailCache = Cache<MSGraphMailFolder, [MSGraphMessage]>()
    
    private(set) var mailFolder = [MSGraphMailFolder]()
    
    var selectedFolder: MSGraphMailFolder!
    var mailList = [MSGraphMessage]() {
        didSet {
            mailCollectionViewController.dataSource = mailList
        }
    }
    
    private var mailCollectionViewController: MailCollectionViewController
    
    init(collectionView: UICollectionView, completion: @escaping (Error?) -> Void) {
        mailCollectionViewController = MailCollectionViewController(collectionView: collectionView)
        getUserMailContext(completion: completion)
        mailCollectionViewController.mailController = self
    }
    
    func updateMessage(at indexPath: IndexPath, _ message: MSGraphMessage) {
        mailList[indexPath.row] = message
    }
    
    func switchFolder(_ newFolder: MSGraphMailFolder, completion: @escaping (Error?) -> Void) {
        mailCache[selectedFolder] = mailList
        selectedFolder = newFolder
        mailList = []
        getMessages { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(error)
        }
    }

}

// MARK: - Graph manager methods

extension MailController {
    
    private func getUserMailContext(completion: @escaping (Error?) -> Void) {
        getMailFolder(completion: completion)
    }
    
    private func getMailFolder(completion: @escaping (Error?) -> Void) {
        GraphManager.instance.getMailFolders { (foldersArray, error) in
            DispatchQueue.main.async {
                
                guard let foldersArray = foldersArray, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    completion(error)
                    return
                }
                
                self.mailFolder = foldersArray
                self.selectedFolder = foldersArray[1] // The second folder refers to the inbox
                self.getUserInbox(completion: completion)        
            }
        }
    }
    
    private func getUserInbox(completion: @escaping (Error?) -> Void) {
        GraphManager.instance.getMailInbox { (messages, error) in
            DispatchQueue.main.async {
                
                guard let messages = messages, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    completion(error)
                    return
                }
                
                self.mailList = messages
                completion(nil)
            }
        }
    }
    
    private func getMessages(completion: @escaping (Error?) -> Void) {
        guard mailCache[selectedFolder] == nil else {
            mailList = mailCache[selectedFolder]!
            completion(nil)
            return
        }
        
        GraphManager.instance.getMail(from: selectedFolder) { (messages, error) in
            DispatchQueue.main.async {
                
                guard let messages = messages, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    completion(error)
                    return
                }
                
                self.mailList = messages
                completion(nil)
            }
        }
    }
    
    func getNextPage() {
        GraphManager.instance.getNextPage { (messages, error) in
            DispatchQueue.main.async {
                
                guard let messages = messages, error == nil else {
                    print("Error getting user: \(String(describing: error))")
                    return
                }
                
                self.mailList.append(contentsOf: messages)
            }
        }
    }
}
