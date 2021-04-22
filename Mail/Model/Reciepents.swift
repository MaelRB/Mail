//
//  Reciepents.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 22/04/2021.
//

import Foundation

struct Recipients: Encodable {
    var toRecipients: [Address]
    
    struct Address: Encodable {
        var emailAddress: EmailAddress
    }
    
    struct EmailAddress: Encodable {
        var address: String
        var name: String
    }
}


