//
//  Persistence.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DogWalkModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Check if there are already tasks in the preview context
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true) // Fetch all tasks

        let taskCount = (try? viewContext.count(for: fetchRequest)) ?? 0
        
        if taskCount == 0 {
        let newTask = TaskEntity.createNewTask(
            title: "Morning Walk",
            isCompleted: false,
            dueDate: Date(),
            description: "Take dog for a walk",
            context: viewContext
        )
        
        // Sample Dog data
        let newDog = DogEntity(context: viewContext)
        newDog.id = UUID()
        newDog.name = "Buddy"
        newDog.age = 3
        newDog.breed = "Golden Retriever"
        newDog.size = "Large"
        newDog.weight = 35
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
        return result

    }()
}
