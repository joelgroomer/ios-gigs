//
//  GigController.swift
//  Gigs
//
//  Created by Joel Groomer on 9/10/19.
//  Copyright © 2019 julltron. All rights reserved.
//

import Foundation

let appJSON = "application/json"
let contentType = "Content-Type"

enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
}

class GigController {
    var bearer: Bearer?
    var baseURL = URL(string: "https://lambdagigs.vapor.cloud/api")!

    func signUp(with user: User, completion: @escaping (Error?) -> Void) {
        let signUpUrl = baseURL.appendingPathComponent("users/signup")
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = HttpMethod.post.rawValue
        request.setValue(appJSON, forHTTPHeaderField: contentType)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            request.httpBody = data
        } catch {
            print("Error encoding user to JSON: \(error)")
            completion(NSError(domain: "", code: 1, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, res, err) in
            if let err = err {
                print("Error performing sign up data task: \(err)")
                completion(err)
                return
            }
            
            if let res = res as? HTTPURLResponse, res.statusCode != 200 {
                completion(NSError(domain: "", code: res.statusCode, userInfo: nil))
            }
            
            completion(nil)
        }.resume()
    }
    
    func signIn(with user: User, completion: @escaping (Error?) -> Void) {
        let signInUrl = baseURL.appendingPathComponent("users/login")
        var request = URLRequest(url: signInUrl)
        request.httpMethod = HttpMethod.post.rawValue
        request.setValue(appJSON, forHTTPHeaderField: contentType)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            request.httpBody = data
        } catch {
            print("Error encoding user to JSON: \(error)")
            completion(NSError(domain: "", code: 2, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, res, err) in
            if let err = err {
                print("Error performing sign in data task: \(err)")
                completion(err)
                return
            }
            
            if let res = res as? HTTPURLResponse, res.statusCode != 200 {
                completion(NSError(domain: "", code: res.statusCode, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "", code: 3, userInfo: nil))
                return
            }
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                print("Error decoding bearer: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
}