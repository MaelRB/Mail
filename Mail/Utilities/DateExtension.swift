//
//  DateExtension.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 14/03/2021.
//

import Foundation

extension Date {
    
    init(str: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.date(from: str)
        guard let safeDate = date else { fatalError("Bad date") }
        self.init(timeIntervalSinceNow: safeDate.timeIntervalSinceNow)
    }
    
    func relativeDate() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func string() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
}
