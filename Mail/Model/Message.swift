//
//  Message.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 22/04/2021.
//

import Foundation

struct Message: Encodable {
    
    var subject: String
    var body: Body
    var toRecipients: [Recipients.Address]
    
    init(to: String, body: String, subject: String) {
        self.body = Body(content: body)
        self.subject = subject
        self.toRecipients = [Recipients.Address(emailAddress: Recipients.EmailAddress(address: to, name: ""))]
    }
    
    struct Body: Encodable {
        let contentType = "TEXT"
        var content: String
    }
}

extension Message {
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
