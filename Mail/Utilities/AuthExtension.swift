//
//  AuthExtension.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 26/03/2021.
//

import UIKit
import Firebase

extension Auth {
    
    func logUser() -> User {
        let user = self.currentUser!
        return User(name: user.displayName!, mail: user.email!, profilePicture: UIImage(named: "profile1")!)
    }
}
