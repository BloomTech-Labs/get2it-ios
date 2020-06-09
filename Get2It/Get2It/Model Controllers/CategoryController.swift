//
//  CategoryController.swift
//  Get2It
//
//  Created by John Kouris on 6/8/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation
import CoreData

class CategoryController {
    typealias CompletionHandler = (Error?) -> Void
    
    private let baseURL = URL(string: "https://get2itpt9.herokuapp.com/api")!
    
    private var token: String? {
        return UserController.shared.token
    }
    
    private var userId: Int? {
        return UserController.shared.authenticatedUser?.id
    }
    
    func fetchCategoriesFromServer(completion: ((Result<[CategoryRepresentation], NetworkError>) -> Void)? = nil) {
        
        
    }
}
