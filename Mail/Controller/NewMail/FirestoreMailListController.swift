//
//  FirestoreMailListController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 26/03/2021.
//

import Foundation
import Firebase

protocol FirestoreMailListControllerDelegate {
    func newMailsRetrieved(_ fetchThreadList: [Thread], _ error: Error?)
}

class FirestoreMailListController {
    
    // MARK: Properties
    
    private let db = Firestore.firestore()
    
    var delegate: FirestoreMailListControllerDelegate?
    
    private let bgQueue = DispatchQueue.init(label: "firestoreThreadList", qos: .userInitiated)
    
    // MARK: - Public methods
    
    func fetchMail(for mailbox: Mailboxes) {
        bgQueue.async { [weak self] in
            guard let self = self else { return }
            self.getLogUserThreadList { threadIdList in
                self.fetchThreads(from: threadIdList) { (threadList) in
                    let sortedThreadList = threadList.sorted { (t1, t2) -> Bool in
                        t1.modifiedDate < t2.modifiedDate
                    }
                    self.fetchThreadNewMails(for: sortedThreadList) { list in
                        self.mailsRetrieved(list, with: nil)
                    }
                }
            }
        }
    }
    
    func mailsRetrieved(_ list: [Thread], with error: Error?) {
        DispatchQueue.main.async {
            self.delegate?.newMailsRetrieved(list, error)
        }
    }
    
    // MARK: - Private methods
    
    private func fetchDatabase(for collection: String, where field: String, isEqualTo value: Any, completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        db.collection(collection).whereField(field, isEqualTo: value).getDocuments { (querySnap, err) in
            if let error = err {
                self.mailsRetrieved([], with: error)
            } else {
                completion(querySnap!.documents)
            }
        }
    }
    
    private func getLogUserThreadList(completion: @escaping ([String]) -> Void) {
        fetchDatabase(for: Constant.Firestore.userCollectionName, where: "uid", isEqualTo: Auth.auth().currentUser!.uid) { (documentSnapshot) in
            completion(documentSnapshot.first!.data()["threads"] as! [String])
        }
    }
    
    private func fetchThreads(from threadList: [String], completion: @escaping ([Thread]) -> Void) {
        var fetchThreadList = [Thread]()
        for threadID in threadList {
            fetchDatabase(for: Constant.Firestore.threadCollectionName, where: "id", isEqualTo: threadID) { (documentSnapshot) in
                let thread = Thread(documentSnapshot.first!.data())
                fetchThreadList.append(thread)
                
                // If last id it should return the list
                if thread.id == threadList[threadList.count - 1] {
                    completion(fetchThreadList)
                }
            }
        }
    }
    
    private func fetchThreadNewMails(for threadList: [Thread], completion: @escaping ([Thread]) -> Void) {
        var newThreadList = threadList
        var threadFetch = 0
        for index in 0..<threadList.count {
            
            fetchDatabase(for: Constant.Firestore.mailCollectionName, where: "id", isEqualTo: threadList[index].id) { (documentSnapshot) in
                let lastMailID = documentSnapshot.first!.data()["lastMail"] as! String
                let docPath = documentSnapshot.first!.data()["id"] as! String
                self.db.collection(Constant.Firestore.mailCollectionName).document(docPath).collection("mails").whereField("id", isEqualTo: lastMailID).getDocuments { (snap, err) in
                    if let error = err {
                        self.mailsRetrieved([], with: error)
                    } else {
                        var mail = Mail(snap!.documents.first!.data())
                        self.fetchUser(snap!.documents.first!.data()["sentBy"] as! String) { user in
                            mail.sender = user
                            newThreadList[index].mailList.append(mail)
                            threadFetch += 1
                            
                            // If last id it should return the list
                            if  threadFetch == threadList.count {
                                completion(newThreadList)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func fetchUser(_ id: String, completion: @escaping (User) -> Void) {
        fetchDatabase(for: Constant.Firestore.userCollectionName, where: "uid", isEqualTo: id) { (documentSnapshot) in
            let user = User(documentSnapshot.first!.data())
            completion(user)
        }
    }
    
}
