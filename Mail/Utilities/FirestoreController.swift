//
//  FirestoreController.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 06/04/2021.
//

import Foundation
import Firebase

class FirestoreController {
    
    internal let db = Firestore.firestore()
    
    internal var onError: (Error) -> Void = { err in }
    
    internal func fetchDatabase(for collection: String, where field: String, isEqualTo value: Any, completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        db.collection(collection).whereField(field, isEqualTo: value).getDocuments { (querySnap, err) in
            if let error = err {
                self.onError(error)
            } else {
                completion(querySnap!.documents)
            }
        }
    }
    
    internal func getLogUserThreadList(completion: @escaping ([String]) -> Void) {
        fetchDatabase(for: Constant.Firestore.userCollectionName, where: "uid", isEqualTo: Auth.auth().currentUser!.uid) { (documentSnapshot) in
            completion(documentSnapshot.first!.data()["threads"] as! [String])
        }
    }
}
