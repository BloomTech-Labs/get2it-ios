//
//  UserController.swift
//  Get2It
//
//  Created by John Kouris on 4/22/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

class UserController {
    static let shared = UserController()
    private let baseURL = URL(string: "https://get2itpt9.herokuapp.com/api")!
    var token: String?
    var authenticatedUser: AuthenticatedUser?
    
    func signUp(with user: User, completion: @escaping(Error?) -> Void) {
        let requestURL = baseURL.appendingPathComponent("auth").appendingPathComponent("register")
        
        // Build the request
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        
        // Tell the API that the body is in JSON format
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        do {
            let userJSON = try encoder.encode(user)
            request.httpBody = userJSON
        } catch {
            completion(error)
        }
        
        // Perform the request (data task)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Handle errors
            if let error = error {
                NSLog("Error signing up user: \(error)")
                completion(error)
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 201 {
                completion(error)
            }
            
            // nil means there was no error, everything succeeded
            completion(nil)
        }.resume()
    }
    
    func signIn(_ user: User, completion: @escaping (Error?) -> Void) {
        let requestURL = baseURL.appendingPathComponent("auth").appendingPathComponent("login")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            NSLog("Error encoding user for sign in: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error signing in user: \(error)")
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                let statusCodeError = NSError(domain: "com.JohnKouris.Get2It", code: response.statusCode, userInfo: nil)
                completion(statusCodeError)
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                let noDataError = NSError(domain: "com.JohnKouris.Get2It", code: -1, userInfo: nil)
                completion(noDataError)
                return
            }
            
            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                self.authenticatedUser = userResult.user
                self.token = userResult.token
                print(userResult)
            } catch {
                print("Error decoding result")
                completion(error)
            }
            
            completion(nil)
        }.resume()
    }
    
    func signOut() {
        self.token = nil
        self.authenticatedUser = nil
    }
    
}
