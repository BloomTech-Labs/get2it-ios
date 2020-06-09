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
        guard let userId = userId else { return }
        let requestURL = baseURL.appendingPathComponent("/categories/\(userId)/categories")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion?(.failure(.badAuth))
            }
            
            if error != nil {
                completion?(.failure(.otherError))
            }
            
            guard let data = data else {
                completion?(.failure(.badData))
                return
            }
            
            let decorder = JSONDecoder()
            decorder.dateDecodingStrategy = .formatted(.iso8601Full)
            
            do {
                let categoryRepresentations = try decorder.decode([CategoryRepresentation].self, from: data)
                self.updateCategoriesInCoreData(with: categoryRepresentations)
                completion?(.success(categoryRepresentations))
            } catch {
                print("Error decoding categories: \(error)")
                completion?(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    func updateCategoriesInCoreData(with representations: [CategoryRepresentation]) {
        let identifiersToFetch = representations.map { $0.categoriesId }
        let representationsById = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var categoriesToCreate = representationsById
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "categoriesId IN %@", identifiersToFetch)
                
                let existingCategories = try context.fetch(fetchRequest)
                for category in existingCategories {
                    let categoryId = Int(category.categoriesId)
                    guard let representation = representationsById[categoryId] else { continue }
                    
                    category.applyChanges(from: representation)
                    
                    categoriesToCreate.removeValue(forKey: categoryId)
                }
                
                for representation in categoriesToCreate.values {
                    Category(representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
            } catch {
                print("Error fetching categories from persistent store")
            }
        }
    }
}
