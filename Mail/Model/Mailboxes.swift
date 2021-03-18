//
//  Mailboxes.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 12/03/2021.
//

import Foundation

enum Mailboxes: String, CaseIterable {
    case Inbox
    case Flagged
    case Sent
    case Draft
    
    var symbol: String {
        switch self {
            case .Inbox: return "tray.fill"
            case .Flagged: return "flag.fill"
            case .Sent: return "paperplane.fill"
            case .Draft: return "doc.fill"
        }
    }
}
