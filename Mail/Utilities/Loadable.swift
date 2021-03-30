//
//  Loadable.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 30/03/2021.
//

import Foundation

enum Loadable<T: Hashable> {
    case notRequested
    case loading
    case loaded(T)
    case error(Error)
    
    var value: T? {
        switch self {
            case .loaded(let value):  return value
            default:                  return nil
        }
    }
}
