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
    
    // Implement singleton pattern
    static let instance = GraphManager()
    
    private let client: MSHTTPClient?
    
    public var userTimeZone: String
    
    // Next link : pagination
    private var nextLink: URL? = nil
    
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
    
    // Return true if there is a next link, false otherwise
    public func getNextInboxPage(completion: @escaping([MSGraphMessage]?, Error?) -> Void) {
        guard let link = nextLink else { return }
        getMailInbox(link) { (messages, error) in
            completion(messages, error)
        }
    }
}