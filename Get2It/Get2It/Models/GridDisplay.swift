//
//  CoreDataStack.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/19/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

struct GridDisplay: Equatable, Hashable {
    let gridIndex: Int // this is the grid number of the summary cell
    let numberOfTasks: Int // this is the number that is showed in the cell
}

extension GridDisplay {
    // calculating the number of tasks for the summary cell
    static func tasks(numberOfTasks: Int = 0) -> GridDisplay {
        .init(gridIndex: 0, numberOfTasks: numberOfTasks)
    }
    
        // calculating the number of completed tasks for the summary cell
    static func completedTasks(numberOfTasks: Int = 0) -> GridDisplay {
        .init(gridIndex: 1, numberOfTasks: numberOfTasks)
    }
}
