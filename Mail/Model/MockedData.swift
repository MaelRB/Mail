//
//  MockedData.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 13/03/2021.
//

import UIKit

extension Thread {
    static var mockedData = Thread(id: "1", title: "MVP docs", userIdList: [], modifiedDate: Date(), isNew: false, isFlagged: false, mailList: Mail.mockedDataArray)
    
    static var mockedDataArray = [
        Thread(id: "1", title: "MVP docs", userIdList: [], modifiedDate: Date().addingTimeInterval(-10000), isNew: true, isFlagged: true, mailList: Mail.mockedDataArray),
        Thread(id: "2", title: "Meetings", userIdList: [], modifiedDate: Date(), isNew: false, isFlagged: true, mailList: Mail.mockedDataArray),
        Thread(id: "3", title: "2021 Goals", userIdList: [], modifiedDate: Date().addingTimeInterval(-3000), isNew: false, isFlagged: false, mailList: Mail.mockedDataArray)
    ]
}

extension User {
    static var mockedData = User(name: "Maria watson", mail: "maria.watson@gmail.com", profilePicture: UIImage(named: "profile1")!)
    
    static var mockedDataArray = [
        User(name: "Maria watson", mail: "maria.watson@gmail.com", profilePicture: UIImage(named: "profile1")!),
        User(name: "Anna Kong", mail: "anna.kong@outlook.com", profilePicture: UIImage(named: "profile2")!),
        User(name: "Thierry Nones", mail: "thierry.nones@gmail.com", profilePicture: UIImage(named: "profile3")!)
    ]
}

extension Mail {
    static var mockedData = Mail(sender: User.mockedDataArray[0],message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-45000), isRead: true, isFlagged: true)
    
    static var mockedDataArray = [
        Mail(sender: User.mockedDataArray[0], message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-45000), isRead: true, isFlagged: true),
        Mail(sender: User.mockedDataArray[1], message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news. Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-56000), isRead: true, isFlagged: true),
        Mail(sender: User.mockedDataArray[2], message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-5000), isRead: true, isFlagged: true)
    ]
}
