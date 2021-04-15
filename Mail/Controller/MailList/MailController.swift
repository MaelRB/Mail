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
    
    private var mailCollectionViewController: MailCollectionViewController
    
    init(collectionView: UICollectionView, completion: @escaping (Error?) -> Void) {
        mailCollectionViewController = MailCollectionViewController(collectionView: collectionView)
        getUserMailContext(completion: completion)
    }
    
    subscript(key: MSGraphMailFolder) -> [MSGraphMessage] {
        get { return mailCache[key] ?? [] }
    }
    
    subscript(key: Int) -> MSGraphMessage? {
        get { return mailCache[selectedFolder]?[key]}
    }
    
    func updateMessage(at indexPath: IndexPath, _ message: MSGraphMessage) {
        mailCache[selectedFolder]![indexPath.row] = message
        mailCollectionViewController.updateMessage(at: indexPath.row, message)
    }
    
    func switchFolder(_ newFolder: MSGraphMailFolder, completion: @escaping (Error?) -> Void) {
        selectedFolder = newFolder
        mailCollectionViewController.clearDataSource()
        getMessages { error in
            guard error == nil else {
                completion(error)
                return
            }
            self.mailCollectionViewController.addMessages(self.mailCache[self.selectedFolder]!)
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
                
                self.mailCache[self.selectedFolder] = messages
                self.mailCollectionViewController.addMessages(self.mailCache[self.selectedFolder]!)
                completion(nil)
            }
        }
    }
    
    private func getMessages(completion: @escaping (Error?) -> Void) {
        guard mailCache[selectedFolder] == nil else {
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
                
                self.mailCache.insert(messages, forKey: self.selectedFolder)
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
                
                self.mailCache.insert(messages, forKey: self.selectedFolder)
                self.mailCollectionViewController.addMessages(self.mailCache[self.selectedFolder]!)
            }
        }
    }
}
