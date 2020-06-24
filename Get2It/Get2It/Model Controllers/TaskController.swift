//
//  TaskController.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/21/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation
import CoreData
import UserNotifications

class TaskController {
    typealias CompletionHandler = (Error?) -> Void
    
    private let baseURL = URL(string: "https://get2itpt9.herokuapp.com/api")!
    
    private var token: String? {
        return UserController.shared.token
    }
    
    private var userId: Int? {
        return UserController.shared.authenticatedUser?.id
    }
    
    // MARK: - Server
    
    func fetchTasksFromServer(completion: ((Result<[TaskRepresentation], NetworkError>) -> Void)? = nil) {
        guard let userId = userId else { return }
        let requestURL = baseURL.appendingPathComponent("/users/\(userId)/tasks")
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
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
//            decoder.dateDecodingStrategy = .custom({ decoder -> Date in
//                let container = try decoder.singleValueContainer()
//                let dateStr = try container.decode(String.self)
//                let dayOnly = dateStr.prefix { $0 != "T" }
//                if let date = DateFormatter.dayOnly.date(from: String(dayOnly)) {
//                    return date
//                } else {
//                    return Date()
//                }
//            })
            do {
                let taskRepresentations = try decoder.decode([TaskRepresentation].self, from: data)
                self.updateTasksInCoreData(with: taskRepresentations)
                completion?(.success(taskRepresentations))
            } catch {
                print("Error decoding tasks: \(error)")
                completion?(.failure(.noDecode))
                return
            }
        }.resume()
    }
    
    // task representation to json to server, get back task rep and save to core data
    func createTaskOnServer(taskRepresentation: TaskRepresentation , completion: @escaping (Result<TaskRepresentation, NetworkError>) -> Void) {
        guard let userId = userId else { return }
        let requestURL = baseURL.appendingPathComponent("/users/\(userId)/tasks")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "authorization")
        
        // Encoding the task
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let body = try encoder.encode(taskRepresentation)
            request.httpBody = body
        } catch {
            NSLog("Error encoding task representation: \(error)")
            completion(.failure(.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            if let response = response as? HTTPURLResponse,
                response.statusCode == 201 {
                let decoder = JSONDecoder()
                do {
                    struct CreateTaskResponse: Decodable { let id: Int }
                    let createTaskResponse = try decoder.decode(CreateTaskResponse.self, from: data)
                    var taskRepresentation = taskRepresentation
                    taskRepresentation.taskId = createTaskResponse.id
                    completion(.success(taskRepresentation))
                } catch { fatalError() }
            } else {
                print("status code is not 201")
                completion(.failure(.otherError))
            }
            
        }.resume()
    }
    
    func updateTaskOnServer(task: Task, completion: @escaping (Result<Task, NetworkError>) -> Void) {
        guard let taskRepresentation = task.taskRepresentation else { return }
        let requestURL = baseURL.appendingPathComponent("/users/tasks/\(task.taskId)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "authorization")
        
        // Encoding the task
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let body = try encoder.encode(taskRepresentation)
            request.httpBody = body
        } catch {
            NSLog("Error encoding task representation: \(error)")
            completion(.failure(.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                completion(.success(task))
            } else {
                completion(.failure(.otherError))
            }
        }.resume()
    }
    
    func delete(task: Task, completion: @escaping (Error?) -> Void = { _ in }) {
        
        let requestURL = baseURL.appendingPathComponent("/users/tasks/\(task.taskId)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(error)
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
        }.resume()
        
        CoreDataStack.shared.mainContext.delete(task)
        CoreDataStack.shared.save()
    }
    
    // Getting tasks from Category Id
    func fetchTasksFromServerBy(categoryId: Int?, completion: ((Result<[TaskRepresentation], NetworkError>) -> Void)? = nil) {
        guard let categoryId = categoryId else { return }
        let requestURL = baseURL.appendingPathComponent("/categories/\(categoryId)/tasks")
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
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            do {
                let taskRepresentations = try decoder.decode([TaskRepresentation].self, from: data)
                completion?(.success(taskRepresentations))
            } catch {
                print("Error decoding tasks: \(error)")
                completion?(.failure(.noDecode))
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
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "taskId IN %@", identifiersToFetch)
                
                let existingTasks = try context.fetch(fetchRequest)
                for task in existingTasks {
                    let taskId = Int(task.taskId)
                    guard let representation = representationsById[taskId] else { continue }
                    
                    task.applyChanges(from: representation)
                    
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
        
        syncLocalNotifications(tasks: representations)
    }
    
    func saveTaskInCoreData(for representation: TaskRepresentation) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            Task(representation, context: context)
            CoreDataStack.shared.save(context: context)
        }
    }
    
    func syncLocalNotifications(tasks: [TaskRepresentation]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "MMMM dd, yyyy h:mm a"
        
        for task in tasks {
            let dayString = dateFormatter.string(from: task.date)
            guard let date = fullFormatter.date(from: "\(dayString) \(task.startTime)") else { continue }
            
            let components = Calendar.current.dateComponents([.month, .day, .year, .hour, .minute], from: date.addingTimeInterval(-600))

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let notificationId = UUID().uuidString
            scheduleNotification(identifier: notificationId, trigger: trigger, title: task.name, sound: true)
        }
    }
}

extension TaskController: NotificationScheduler {}

extension TaskController {
    static func clearData() {
        let context = CoreDataStack.shared.mainContext
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                CoreDataStack.shared.save(context: context)
            } catch {
                print("Error deleting core data.")
            }
        }
    }
}
