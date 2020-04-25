//
//  CoreDataStack.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/19/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let newContainer = NSPersistentContainer(name: "Task")
        newContainer.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Failed to load to persistent stores: \(error!)")
            }
        }
        newContainer.viewContext.automaticallyMergesChangesFromParent = true
        return newContainer
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Error saving contenxt: \(error)")
                // reset it in case it doesn't save but rarely happens
                context.reset()
            }
        }
    }
}
