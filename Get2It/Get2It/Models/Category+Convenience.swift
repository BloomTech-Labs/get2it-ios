//
//  Category+Convenience.swift
//  Get2It
//
//  Created by John Kouris on 5/27/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation
import CoreData

extension Category {
    var categoryRepresentation: CategoryRepresentation? {
        .init(
            categoriesId: Int(categoriesId),
            userId: Int(userId),
            name: name ?? ""
        )
    }
    
    @discardableResult
    convenience init(_ categoryRepresentation: CategoryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.categoriesId = Int64(categoryRepresentation.categoriesId ?? 0)
        self.userId = Int64(categoryRepresentation.userId ?? 0)
        self.name = categoryRepresentation.name
    }
    
    func applyChanges(from categoryRepresentation: CategoryRepresentation) {
        self.categoriesId = Int64(categoryRepresentation.categoriesId ?? 0)
        self.userId = Int64(categoryRepresentation.userId ?? 0)
        self.name = categoryRepresentation.name
    }
}

extension Category {
    struct Diffable: Hashable {
        let categoriesId: Int
        let name: String?
        let category: Category
        
        init(category: Category) {
            self.categoriesId = Int(category.categoriesId)
            self.name = category.name
            self.category = category
        }
    }
}
