//
//  User.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 14/03/2021.
//

import UIKit

struct User: Hashable {
    
    var uid: String
    var name: String
    var mail: String
    var profilePicture: UIImage
    var threadIdList: [String]
}
