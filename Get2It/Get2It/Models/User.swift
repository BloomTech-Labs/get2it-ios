//
//  User.swift
//  Get2It
//
//  Created by John Kouris on 4/20/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

struct User: Codable {
//    let displayName: String
    let username: String
    let password: String
}

struct Token: Codable {
    let token: String
}
