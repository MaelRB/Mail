//
//  Loadable.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 30/03/2021.
//

import Foundation

enum State {
    case notRequested
    case loading
    case loaded
    case error(Error)
}
