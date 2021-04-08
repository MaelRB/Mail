//
//  MockedData.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 13/03/2021.
//

import UIKit

extension Thread {
    static var mockedData = Thread(id: "1", title: "MVP docs", userIdList: [], modifiedDate: Date(), mailList: Mail.mockedDataArray)
    
    static var mockedDataArray = [
        Thread(id: "1", title: "MVP docs", userIdList: [], modifiedDate: Date().addingTimeInterval(-10000), mailList: Mail.mockedDataArray),
        Thread(id: "2", title: "Meetings", userIdList: [], modifiedDate: Date(), mailList: Mail.mockedDataArray),
        Thread(id: "3", title: "2021 Goals", userIdList: [], modifiedDate: Date().addingTimeInterval(-3000), mailList: Mail.mockedDataArray)
    ]
}

extension User {
    static var mockedData = User(uid: "1", name: "Maria watson", mail: "maria.watson@gmail.com", profilePicture: UIImage(named: "profile1")!, threadIdList: [])
    
    static var mockedDataArray = [
        User(uid: "1", name: "Maria watson", mail: "maria.watson@gmail.com", profilePicture: UIImage(named: "profile1")!, threadIdList: []),
        User(uid: "2", name: "Anna Kong", mail: "anna.kong@outlook.com", profilePicture: UIImage(named: "profile2")!, threadIdList: []),
        User(uid: "3", name: "Thierry Nones", mail: "thierry.nones@gmail.com", profilePicture: UIImage(named: "profile3")!, threadIdList: [])
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
