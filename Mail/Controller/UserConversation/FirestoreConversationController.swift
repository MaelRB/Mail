//
//  FirestoreConversationController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 05/04/2021.
//

import Foundation
import Firebase

protocol FirestoreConversationControllerDelegate {
    func conversationDidLoad(_ threadList: [Thread], with error: Error?)
}

class FirestoreConversationController {
    
    // MARK: Properties
    
    private let db = Firestore.firestore()
    
    var delegate: FirestoreConversationControllerDelegate?
    
    private let bgQueue = DispatchQueue.init(label: "firestoreConversation", qos: .userInitiated)
    
    // MARK: - Public methods
    
    func fetchThread(for user: User) {
        bgQueue.async {
            
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
        db.collection(Constant.Firestore.threadCollectionName).whereField("id", in: threadList).whereField("members", arrayContains: user.uid).getDocuments { (querySnap, err) in
            if let error = err {
                self.threadListretrieved([], with: error)
            } else {
                // Convert data to Thread
            }
        }
    }
    
    
}
