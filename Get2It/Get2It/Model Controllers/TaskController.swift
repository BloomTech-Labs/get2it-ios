//
//  TaskController.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/21/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation
import CoreData

class TaskController {
    typealias CompletionHandler = (Error?) -> Void
    
    private let baseURL = URL(string: "https://get2it.herokuapp.com/api")!
    var tasks: [TaskRepresentation] = []
    // TODO: create a singleton of login controller
    var userId = 150 // temporary
    var token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE1MCwidXNlcm5hbWUiOiJ2cyIsImlhdCI6MTU4NzUxMTUwOCwiZXhwIjoxNTg3NTk3OTA4fQ.yfUEBJGfNXVBHwJR7ROPQzKmyAJM-t8XPWZwAIgiHss" // temporary
    
    // MARK: - Server
    
    func fetchTasksFromServer(completion: @escaping (Result<[TaskRepresentation], NetworkError>) -> Void) {
        let requestURL = baseURL.appendingPathComponent("/users/\(userId)/tasks")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: get the token from the login controller
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.badAuth))
            }
            
            if error != nil {
                completion(.failure(.otherError))
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let taskRepresentations = try decoder.decode([TaskRepresentation].self, from: data)
                self.updateTasksInCoreData(with: taskRepresentations)
            } catch {
                print("Error decoding tasks: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    // task representation to json to server, get back task rep and save to core data
    func createTaskOnServer(taskRepresentation: TaskRepresentation , completion: @escaping (Result<[TaskRepresentation], NetworkError>) -> Void) {
        let requestURL = baseURL.appendingPathComponent("/users/\(userId)/tasks")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: get the token from the login controller
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        //encode
        do {
            request.httpBody = try JSONEncoder().encode(taskRepresentation)
        } catch {
            NSLog("Error encoding task representation: \(error)")
            completion(.failure(.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 201 {
                completion(.failure(.badAuth))
            }
            
            if error != nil {
                completion(.failure(.otherError))
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            // decode to save it
            let decoder = JSONDecoder()
            do {
                let taskRepresentation = try decoder.decode(TaskRepresentation.self, from: data)
                self.saveTaskInCoreData(for: taskRepresentation)
            } catch {
                print("Error decoding tasks: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    // MARK: - Core Data (iPhone)
    
    func updateTasksInCoreData(with representations: [TaskRepresentation]) {
        let identifiersToFetch = representations.map { $0.taskId }
        let representationsById = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var tasksToCreate = representationsById
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "taskId IN %@", identifiersToFetch)
                
                let existingTasks = try context.fetch(fetchRequest)
                for task in existingTasks {
                    let taskId = Int(task.taskId)
                    guard let representation = representationsById[taskId] else { continue }
                    
                    task.apply(representation)
                    
                    tasksToCreate.removeValue(forKey: taskId)
                }
                
                for representation in tasksToCreate.values {
                    Task(representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fetching tasks from persistent store")
            }
        }
    }
    
    func saveTaskInCoreData(for representation: TaskRepresentation) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            Task(representation, context: context)
            CoreDataStack.shared.save(context: context)
        }
    }
}
