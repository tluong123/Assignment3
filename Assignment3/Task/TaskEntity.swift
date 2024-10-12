//
//  TaskEntity.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import CoreData

// Extension on TaskEntity to add functionality without subclassing
extension TaskEntity {

    // Static method to create a new TaskEntity (for adding new tasks)
    static func createNewTask(id: UUID = UUID(), title: String, isCompleted: Bool = false, dueDate: Date? = nil, location: String = "", description: String = "", context: NSManagedObjectContext) -> TaskEntity {
        // Ensure the entity description is available
        guard let entity = NSEntityDescription.entity(forEntityName: "TaskEntity", in: context) else {
            fatalError("Failed to find entity description for TaskEntity")
        }

        // Initialize a new TaskEntity with the provided entity and context
        let newTask = TaskEntity(entity: entity, insertInto: context)
        newTask.id = id
        newTask.title = title
        newTask.isCompleted = isCompleted
        newTask.dueDate = dueDate
        newTask.walkDescription = description
        return newTask
    }

    // Method to convert an existing TaskEntity into a dictionary or other structure if needed
    func toDictionary() -> [String: Any] {
        return [
            "id": id?.uuidString ?? "",
            "title": title ?? "",
            "isCompleted": isCompleted,
            "dueDate": dueDate ?? Date(),
            "walkDescription": walkDescription ?? ""
        ]
    }

    // Additional helper methods can be added as needed, e.g., marking a task as complete
    func markAsCompleted() {
        self.isCompleted = true
    }
}

