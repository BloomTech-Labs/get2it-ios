//
//  APIClient.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/21/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}

