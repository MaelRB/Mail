//
//  MailDB.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 18/03/2021.
//

import Foundation

struct MailDB: Hashable, Codable {
    
    var message: String
    var contenu: Data?
    //var mailboxes: [Mailboxes] Create init to decode string to mailboxes
    
}
