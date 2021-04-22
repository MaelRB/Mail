//
//  MessageSend.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 22/04/2021.
//

import Foundation

struct MessageSend: Encodable {
    
    var message: Message
}

extension MessageSend {
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
