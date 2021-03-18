//
//  UserDB.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 18/03/2021.
//

import Foundation

struct UserDB: Hashable, Codable {
    
    var name: String
    var mail: String
    var profilePicture: Data
    
}
