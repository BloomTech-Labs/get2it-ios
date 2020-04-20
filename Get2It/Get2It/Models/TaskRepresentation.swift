//
//  TaskRepresentation.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable, Hashable {
    let taskId: Int
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
}
