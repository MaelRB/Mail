//
//  thread.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit

struct Thread: Hashable {
    
    var title: String
    var user: User
    var date: Date
    var isNew: Bool
    var isFlagged: Bool
    var mailList: [Mail]
    
}
