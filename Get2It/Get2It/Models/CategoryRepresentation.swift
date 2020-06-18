//
//  CategoryRepresentation.swift
//  Get2It
//
//  Created by John Kouris on 5/27/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

struct CategoryRepresentation: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case categoriesId = "id"
        case userId = "user_id"
        case name
    }
    
    var categoriesId: Int?
    let userId: Int?
    let name: String
    
    init(categoriesId: Int? = nil, userId: Int? = nil, name: String) {
        self.categoriesId = categoriesId
        self.userId = userId
        self.name = name
    }
}
