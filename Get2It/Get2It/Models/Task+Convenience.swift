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
    // CoreData (Task) -> TaskRepresentation -> JSON
    var taskRepresentation: TaskRepresentation? {
        .init(
            taskId: Int(taskId),
            userId: Int(userId),
            categoriesId: Int(categoriesId),
            name: name ?? "",
            status: status,
            date: date ?? Date(),
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
        self.categoriesId = Int64(taskRepresentation.categoriesId ?? 0)
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
        self.categoriesId = Int64(taskRepresentation.categoriesId ?? 0)
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

extension Task {
    // https://www.donnywals.com/modern-table-views-with-diffable-data-sources/
    struct Diffable: Hashable {
        let taskId: Int
        let name: String?
        let startTime: String?
        let endTime: String?
        let date: Date?
        let task: Task
        
        init(task: Task) {
            self.taskId = Int(task.taskId)
            self.name = task.name
            self.startTime = task.startTime
            self.endTime = task.endTime
            self.date = task.date
            self.task = task
        }
    }
}
