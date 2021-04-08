//
//  thread.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import UIKit

struct Thread: Hashable {
    
    var id: String
    var title: String
    var userIdList: [String]
    var modifiedDate: Date
    var mailList: [Mail]
}
