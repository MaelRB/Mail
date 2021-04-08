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

class FirestoreConversationController: FirestoreController {
    
    // MARK: Properties
    
    var delegate: FirestoreConversationControllerDelegate?
    
    private let bgQueue = DispatchQueue.init(label: "firestoreConversation", qos: .userInitiated)
    
    override init() {
        super.init()
        onError = { err in
            self.threadListretrieved([], with: err)
        }
    }
    
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
    
    func sendMail(_ mail: Mail, to thread: Thread) {
        updateThread(thread)
        updateMail(mail, thread)
    }
    
    // MARK: - Private methods
    
    private func threadListretrieved(_ list: [Thread], with error: Error?) {
        DispatchQueue.main.async {
            self.delegate?.conversationDidLoad(list, with: error)
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
        var newThreadList = [Thread]()
        for thread in threadList {
            db.collection(Constant.Firestore.mailCollectionName).document(thread.id).collection("mails").getDocuments { (querySnap, err) in
                if let error = err {
                    self.threadListretrieved([], with: error)
                } else {
                    var newThread = thread
                    let documents = querySnap!.documents
                    for doc in documents {
                        var mail = Mail(doc.data())
                        if doc.data()["sentBy"] as! String == Constant.logUser!.uid {
                            mail.sender = Constant.logUser!
                        } else {
                            mail.sender = user
                        }
                        newThread.mailList.append(mail)
                    }
                    newThreadList.append(newThread)
                    
                    // If last id it should return the list
                    if  newThreadList.count == threadList.count {
                        completion(newThreadList)
                    }
                }
            }
        }
    }
    
    private func updateThread(_ thread: Thread) {
        db.collection(Constant.Firestore.threadCollectionName).document(thread.id).setData(["modifiedAt":Timestamp(date: thread.modifiedDate)], merge: true)
    }
    
    private func updateMail(_ mail: Mail, _ thread: Thread) {
        let docRef = db.collection(Constant.Firestore.mailCollectionName).document(thread.id).collection("mails").addDocument(data:
            [
                "messageText": mail.message,
                "sentAt": Timestamp(date: mail.date),
                "sentBy": mail.sender.uid,
                "readBy": [mail.sender.uid],
                "flagBy": []
            ])
        
        db.collection(Constant.Firestore.mailCollectionName).document(thread.id).collection("mails").document(docRef.documentID).setData(["id": docRef.documentID], merge: true)
        
        db.collection(Constant.Firestore.mailCollectionName).document(thread.id).setData(["lastMail":docRef.documentID], merge: true)
    }
    
}
