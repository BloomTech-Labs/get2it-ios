//
//  User.swift
//  Get2It
//
//  Created by John Kouris on 4/20/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

struct AuthenticatedUser: Codable {
    let id: Int
    let displayName: String
    let password: String
    let email: String
}

struct User: Codable {
    let displayName: String?
    let password: String
    let email: String
}

struct UserResult: Codable {
    let message: String
    let user: AuthenticatedUser
    let token: String
}
