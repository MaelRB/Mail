//
//  ModelInit.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 26/03/2021.
//

import Foundation
import Firebase

extension Thread {
    init(_ dict: [String: Any]) {
        self.id = dict["id"] as! String
        self.title = dict["title"] as! String
        self.modifiedDate = (dict["modifiedAt"] as! Timestamp).dateValue()
        self.isNew = dict["isNew"] as! Bool
        self.isFlagged = dict["isFlagged"] as! Bool
        self.mailList = []
        self.userIdList = dict["members"] as! [String]
    
    }
}

extension Mail {
    init(_ dict: [String: Any]) {
        self.isRead = dict["isRead"] as! Bool
        self.isFlagged = dict["isFlagged"] as! Bool
        self.message = dict["messageText"] as! String
        self.date = (dict["sentAt"] as! Timestamp).dateValue()
        self.sender = User(name: "", mail: "", profilePicture: UIImage()) // TODO: - Fetch sender info
    }
}
