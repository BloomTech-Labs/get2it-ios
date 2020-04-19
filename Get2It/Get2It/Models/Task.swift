//
//  Task.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

struct Task: Codable, Hashable {
    let id: Int
    let user_id: Int
    var name: String
    var status: String?
    var date: Date
    var start_time: String
    var end_time: String
    var task_icon: String
    var timeLeft: String?
    var initialNotify: String?
    var notifyOn: Bool
}
