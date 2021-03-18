//
//  Mail.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 15/03/2021.
//

import Foundation

struct Mail: Hashable {
    var object: String
    var sender: User
    var to: User
    var message: String
    var content: Data?
    var date: Date
}
