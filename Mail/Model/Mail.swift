//
//  Mail.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 15/03/2021.
//

import Foundation

struct Mail: Hashable {
    var sender: User
    var message: String
    var content: Data?
    var date: Date
    var isRead: Bool
    var isFlagged: Bool
}
