//
//  Reply.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 22/04/2021.
//

import Foundation
import MSGraphClientModels

struct Reply: Encodable {
    var message: Recipients
    var comment: String
    
    init(email: MSGraphEmailAddress, comment: String) {
        self.comment = comment
        self.message = Recipients(toRecipients: [Recipients.Address(emailAddress: Recipients.EmailAddress(address: email.address ?? "", name: email.name ?? ""))])
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

