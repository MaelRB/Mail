//
//  GraphManager.swift
//  Mail
//
//  Created by Mael Romanin Bluteau on 08/04/2021.
//

import Foundation
import MSGraphClientSDK
import MSGraphClientModels

class GraphManager {
    
    enum ResponseError: Error {
        case badStatusCode
    }
    
    // Implement singleton pattern
    static let instance = GraphManager()
    
    private let client: MSHTTPClient?
    
    public var userTimeZone: String
    
    // Next link : pagination
    var nextLink: URL? = nil
    
    private init() {
        client = MSClientFactory.createHTTPClient(with: AuthenticationManager.instance)
        userTimeZone = "UTC"
    }
    
    // MARK: - User methods
    
    public func getMe(completion: @escaping(MSGraphUser?, Error?) -> Void) {
        // GET /me
        let select = "$select=displayName,mail,mailboxSettings,userPrincipalName"
        let meRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me?\(select)")!)
        let meDataTask = MSURLSessionDataTask(request: meRequest, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let meData = data, graphError == nil else {
                completion(nil, graphError)
                return
            }
            
            do {
                // Deserialize response as a user
                let user = try MSGraphUser(data: meData)
                completion(user, nil)
            } catch {
                completion(nil, error)
            }
        })
        
        // Execute the request
        meDataTask?.execute()
    }
    
    // MARK: - Mail methods
    
    public func getMailFolders(completion: @escaping([MSGraphMailFolder]?, Error?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/mailFolders")!)
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let data = data, graphError == nil else {
                completion(nil, graphError)
                return
            }
            
            do {
                // Deserialize response as events collection
                let foldersCollection = try MSCollection(data: data)
                var foldersArray: [MSGraphMailFolder] = []
                
                guard foldersCollection.value != nil else {
                    completion(nil, graphError)
                    return
                }
                
                foldersCollection.value.forEach({
                    (rawFolder: Any) in
                    // Convert JSON to a dictionary
                    guard let folderDict = rawFolder as? [String: Any] else {
                        return
                    }
                    
                    // Deserialize event from the dictionary
                    let folder = MSGraphMailFolder(dictionary: folderDict)!
                    foldersArray.append(folder)
                })
                
                // Return the array
                completion(foldersArray, nil)
            } catch {
                completion(nil, error)
            }
        })
        
        // Execute the request
        dataTask?.execute()
    }
    
    public func getMailInbox(_ link: URL? = nil, completion: @escaping([MSGraphMessage]?, Error?) -> Void) {
        
        var request = NSMutableURLRequest()
        if let link = link {
            request = NSMutableURLRequest(url: link)
        } else {
            request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/messages")!)
        }
        
        getMailSessionDataTask(with: request, completion: completion)
        
    }
    
    public func getNextPage(completion: @escaping([MSGraphMessage]?, Error?) -> Void) {
        guard let link = nextLink else { return }
        getMailInbox(link) { (messages, error) in
            completion(messages, error)
        }
    }
    
    public func getMail(from folder: MSGraphMailFolder, completion: @escaping([MSGraphMessage]?, Error?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/mailFolders/\(folder.entityId)/messages")!)
        getMailSessionDataTask(with: request, completion: completion)
    }
    
    public func getAttachments(for message: MSGraphMessage, completion: @escaping([Attachment]?, Error?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/messages/\(message.entityId)/attachments")!)
        
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let response = response as? HTTPURLResponse, graphError == nil else {
                completion(nil, graphError)
                return
            }
            print(response.statusCode)
            do {
                let attCollection = try MSCollection(data: data)
                var attArray: [Attachment] = []
                
                guard attCollection.value != nil else {
                    completion(nil, graphError)
                    return
                }
                
                attCollection.value.forEach({
                    (rawAtt: Any) in
                    // Convert JSON to a dictionary
                    guard let attDict = rawAtt as? [String: Any] else {
                        return
                    }
                    
                    attArray.append(Attachment(dict: attDict))
                })
                
                completion(attArray, nil)
            } catch {
                completion(nil, error)
            }
            
        })
        
        dataTask?.execute()
    }
    
    private func getMailSessionDataTask(with request: NSMutableURLRequest, completion: @escaping([MSGraphMessage]?, Error?) -> Void) {
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let data = data, graphError == nil else {
                completion(nil, graphError)
                return
            }
            
            do {
                
                // Deserialize response as events collection
                let messagesCollection = try MSCollection(data: data)
                self.nextLink = messagesCollection.nextLink
                var mmessagesArray: [MSGraphMessage] = []
                
                messagesCollection.value.forEach({
                    (rawMessage: Any) in
                    // Convert JSON to a dictionary
                    guard let messageDict = rawMessage as? [String: Any] else {
                        return
                    }
                    
                    // Deserialize event from the dictionary
                    let message = MSGraphMessage(dictionary: messageDict)!
                    mmessagesArray.append(message)
                })
                
                // Return the array
                completion(mmessagesArray, nil)
            } catch {
                completion(nil, error)
            }
        })
        
        // Execute the request
        dataTask?.execute()
    }
    
    public func updateRead(for message: MSGraphMessage, newValue: Bool, completion: @escaping(MSGraphMessage?, Error?) -> Void) {
        let updateMessageDict: [String: Any] = [
            "isRead": newValue
        ]
        
        let updateData = try? JSONSerialization.data(withJSONObject: updateMessageDict)
         
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/messages/\(message.entityId)")!)
        request.httpMethod = "PATCH"
        request.httpBody = updateData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let data = data, graphError == nil else {
                completion(nil, graphError)
                return
            }
            
            do {
                let message = try MSGraphMessage(data: data)
                completion(message, nil)
            } catch {
                completion(nil, error)
            }
        })
        
        dataTask?.execute()
    }
    
    public func delete(message: MSGraphMessage, completion: @escaping(Error?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/messages/\(message.entityId)")!)
        request.httpMethod = "DELETE"
        
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard graphError == nil else {
                completion(graphError)
                return
            }
            completion(nil)
        })
        
        dataTask?.execute()
    }
    
    public func reply(to message: MSGraphMessage, _ reply: Reply, completion: @escaping(MSGraphMessage?, Error?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/messages/\(message.entityId)/reply")!)
        request.httpMethod = "POST"
        request.httpBody = reply.getJSON()
        //print(String(data: reply.getJSON()!, encoding: .utf8))
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let response = response as? HTTPURLResponse, graphError == nil else {
                completion(nil, graphError)
                return
            }
            print(response.statusCode)
        })
        
        dataTask?.execute()
    }
    
    public func createMessage(_ message: Message, completion: @escaping(MSGraphMessage?, Error?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/messages")!)
        request.httpMethod = "POST"
        request.httpBody = message.getJSON()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let response = response as? HTTPURLResponse, graphError == nil else {
                completion(nil, graphError)
                return
            }
            print(response.statusCode)
        })
        
        dataTask?.execute()
    }
    
    public func sendMessage(_ message: Message, completion: @escaping(Error?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/sendMail")!)
        request.httpMethod = "POST"
        request.httpBody = MessageSend(message: message).getJSON()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dataTask = MSURLSessionDataTask(request: request, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let response = response as? HTTPURLResponse, graphError == nil else {
                completion(graphError)
                return
            }
            if response.statusCode != 202 {
                completion(ResponseError.badStatusCode)
            } else {
                completion(nil)
            }
        })
        
        dataTask?.execute()
    }
    
    
}
