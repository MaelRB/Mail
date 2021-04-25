//
//  Attachment.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 25/04/2021.
//

import Foundation

struct Attachment: Codable {
    let name: String
    let contentType: String
    let contentBytes: String
    let size: String
    
    init(dict: [String : Any]) {
        self.name = dict["name"] as? String ?? ""
        self.contentType = dict["contentType"] as? String ?? ""
        self.contentBytes = dict["contentBytes"] as? String ?? ""
        self.size = dict["size"] as? String ?? ""
    }
}
