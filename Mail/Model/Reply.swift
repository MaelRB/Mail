//
//  Reply.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 22/04/2021.
//

import Foundation

struct Reply: Encodable {
    var message: Recipients
    var comment: String
    
    struct Recipients: Encodable {
        var toRecipients: [Address]
    }
    
    struct Address: Encodable {
        var emailAddress: EmailAddress
    }
    
    struct EmailAddress: Encodable {
        var address: String
        var name: String
    }
}

extension Reply {
    func getJSON() -> Data? {
        let encoder = JSONEncoder()
        
        do {
            return try encoder.encode(self)
        }
        catch {
            return nil
        }
    }
}

