//
//  Task+Convenience.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/19/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation
import CoreData

extension Task {
    // CoreData -> TaskRepresentation -> JSON
    var taskRepresentation: TaskRepresentation? {
        .init(
            taskId: Int(taskId),
            userId: Int(userId),
            name: name ?? "",
            status: status,
            date: date ?? "",
            startTime: startTime ?? "",
            endTime: endTime ?? "",
            taskIcon: taskIcon ?? "",
            timeLeft: Int(timeLeft),
            initialNotify: initialNotify,
            notifyOn: notifyOn
        )
    }
    
    // JSON -> TaskRepresentation -> CoreData
    @discardableResult
    convenience init(_ taskRepresentation: TaskRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.taskId = Int64(taskRepresentation.taskId ?? 0)
        self.userId = Int64(taskRepresentation.userId ?? 0)
        self.name = taskRepresentation.name
        self.status = taskRepresentation.status ?? false
        self.date = taskRepresentation.date
        self.startTime = taskRepresentation.startTime
        self.endTime = taskRepresentation.endTime
        self.taskIcon = taskRepresentation.taskIcon
        self.timeLeft = Int64(taskRepresentation.timeLeft ?? 0)
        self.initialNotify = taskRepresentation.initialNotify ?? false
        self.notifyOn = taskRepresentation.notifyOn ?? false
    }
    
    // Updates the task object from task representation
    func applyChanges(from taskRepresentation: TaskRepresentation) {
        self.taskId = Int64(taskRepresentation.taskId ?? 0)
        self.userId = Int64(taskRepresentation.userId ?? 0)
        self.name = taskRepresentation.name
        self.status = taskRepresentation.status ?? false
        self.date = taskRepresentation.date
        self.startTime = taskRepresentation.startTime
        self.endTime = taskRepresentation.endTime
        self.taskIcon = taskRepresentation.taskIcon
        self.timeLeft = Int64(taskRepresentation.timeLeft ?? 0)
        self.initialNotify = taskRepresentation.initialNotify ?? false
        self.notifyOn = taskRepresentation.notifyOn ?? false
    }
}
