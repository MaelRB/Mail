//
//  MockedData.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 13/03/2021.
//

import UIKit

extension Thread {
    static var mockedData = Thread(user: User.mockedData, date: Date(), isNew: false, isFlagged: false, mailList: Mail.mockedDataArray)
    
    static var mockedDataArray = [
        Thread(user: User.mockedDataArray[0], date: Date().addingTimeInterval(-10000), isNew: true, isFlagged: true, mailList: Mail.mockedDataArray),
        Thread(user: User.mockedDataArray[1], date: Date(), isNew: false, isFlagged: true, mailList: Mail.mockedDataArray),
        Thread(user: User.mockedDataArray[2], date: Date().addingTimeInterval(-3000), isNew: false, isFlagged: false, mailList: Mail.mockedDataArray)
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
    static var mockedData = Mail(object: "2021 Goals", sender: User.mockedDataArray[0], to: User.mockedDataArray[1], message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-45000))
    
    static var mockedDataArray = [
        Mail(object: "2021 Goals", sender: User.mockedDataArray[0], to: User.mockedDataArray[1], message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-45000)),
        Mail(object: "MVP goals", sender: User.mockedDataArray[1], to: User.mockedDataArray[2], message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news. Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-56000)),
        Mail(object: "Meeting", sender: User.mockedDataArray[2], to: User.mockedDataArray[0], message: "Hey Anna, Thank uou for reaching out to me. I'm currently have a bad news.", content: nil, date: Date().addingTimeInterval(-5000))
    ]
    
    static var headerMail = Mail(object: "", sender: User.mockedData, to: User.mockedData, message: "", content: nil, date: Date())
}
