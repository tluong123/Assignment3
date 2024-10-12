//
//  TaskManager.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import SwiftUI
import CoreData

class TaskManager: ObservableObject {
    @Published var tasks: [TaskEntity] = [] // Use TaskEntity directly

    // Inject the managed object context into the TaskManager
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchTasks() // Fetch tasks from Core Data when TaskManager is initialized
    }

    // Add a new task using the new createNewTask method in TaskEntity
    func addTask(title: String, isCompleted: Bool = false, dueDate: Date? = nil, location: String = "", description: String = "") {
        _ = TaskEntity.createNewTask(
            title: title,
            isCompleted: isCompleted,
            dueDate: dueDate,
            location: location,
            description: description,
            context: viewContext
        )

        saveContext()
        fetchTasks()
    }

    // Remove tasks at specific offsets (e.g., from a list)
    func removeTask(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            viewContext.delete(task)
        }
        saveContext()
        fetchTasks()
    }

    // Toggle the task's completion state
    func toggleTaskCompletion(_ task: TaskEntity) {
        task.isCompleted.toggle()
        saveContext()

        if task.isCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.viewContext.delete(task)
                self.saveContext()
                self.fetchTasks()
            }
        }
    }

    // Fetch tasks from Core Data
    private func fetchTasks() {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        do {
            self.tasks = try viewContext.fetch(request)
        } catch let error {
            print("Error fetching tasks: \(error)")
        }
    }

    // Save changes to Core Data
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
