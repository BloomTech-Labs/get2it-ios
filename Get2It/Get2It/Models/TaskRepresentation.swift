//
//  TaskRepresentation.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case taskId = "id"
        case userId = "user_id"
        case name
        case status
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case taskIcon = "task_icon"
        case timeLeft
        case initialNotify
        case notifyOn
    }
    
    let taskId: Int?
    let userId: Int
    let name: String
    let status: String?
    let date: Date
    let startTime: String
    let endTime: String
    let taskIcon: String
    let timeLeft: String?
    let initialNotify: String?
    let notifyOn: Bool
    
    init(taskId: Int? = nil, userId: Int, name: String, status: String?, date: Date, startTime: String, endTime: String, taskIcon: String, timeLeft: String?, initialNotify: String?, notifyOn: Bool) {
        self.taskId = taskId
        self.userId = userId
        self.name = name
        self.status = status
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.taskIcon = taskIcon
        self.timeLeft = timeLeft
        self.initialNotify = initialNotify
        self.notifyOn = notifyOn
    }
}
