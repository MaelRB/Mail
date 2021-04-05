//
//  FirestoreConversationController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 05/04/2021.
//

import Foundation
import Firebase

protocol FirestoreConversationControllerDelegate {
    func conversationDidLoad(_ fetchThreadList: [Thread], with error: Error?)
}

class FirestoreConversationController {
    
    // MARK: Properties
    
    private let db = Firestore.firestore()
    
    var delegate: FirestoreConversationControllerDelegate?
    
    private let bgQueue = DispatchQueue.init(label: "firestoreConversation", qos: .userInitiated)
    
    // MARK: - Public methods
    
    func fetchThread(for user: User) {
        bgQueue.async { [weak self] in
            guard let self = self else { return }
            self.getLogUserThreadList { threadIdList in
                self.getThread(with: user, in: threadIdList) { threadList in
                    self.fetchMail(for: threadList, user) { list in
                        self.threadListretrieved(list, with: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func threadListretrieved(_ list: [Thread], with error: Error?) {
        DispatchQueue.main.async {
            self.delegate?.conversationDidLoad(list, with: error)
        }
    }
    
    private func fetchDatabase(for collection: String, where field: String, isEqualTo value: Any, completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        db.collection(collection).whereField(field, isEqualTo: value).getDocuments { (querySnap, err) in
            if let error = err {
                self.threadListretrieved([], with: error)
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
    
    private func getThread(with user: User, in threadList: [String], completion: @escaping ([Thread]) -> Void) {
        var newThreadList = [Thread]()
        db.collection(Constant.Firestore.threadCollectionName).whereField("id", in: threadList).whereField("members", arrayContains: user.uid).getDocuments { (querySnap, err) in
            if let error = err {
                self.threadListretrieved([], with: error)
            } else {
                let documents = querySnap!.documents
                for doc in documents {
                    newThreadList.append(Thread(doc.data()))
                }
                completion(newThreadList)
            }
        }
    }
    
    private func fetchMail(for threadList: [Thread], _ user: User, completion: @escaping ([Thread]) -> Void) {
        var newThreadList = threadList
        for index in 0..<newThreadList.count {
            db.collection(Constant.Firestore.mailCollectionName).document(newThreadList[index].id).collection("mails").getDocuments { (querySnap, err) in
                if let error = err {
                    self.threadListretrieved([], with: error)
                } else {
                    let documents = querySnap!.documents
                    for doc in documents {
                        var mail = Mail(doc.data())
                        if doc.data()["sentBy"] as! String == Constant.logUser!.uid {
                            mail.sender = Constant.logUser!
                        } else {
                            mail.sender = user
                        }
                        newThreadList[0].mailList.append(mail)
                    }
                    
                    // If last id it should return the list
                    if  index == newThreadList.count - 1 {
                        completion(newThreadList)
                    }
                }
            }
        }
    }
    
}
