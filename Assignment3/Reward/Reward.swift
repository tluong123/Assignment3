//
//  Reward.swift
//  Assignment3
//
//  Created by thomas on 10/10/2024.
//

import Foundation
import CoreData

class Reward: NSManagedObject, Identifiable {
    @NSManaged var totalPoints: Int64

    // Function to add points
    func addPoints(_ points: Int64) {
        totalPoints += points
    }
}

extension Reward {
    static func fetchRequest() -> NSFetchRequest<Reward> {
        let request = NSFetchRequest<Reward>(entityName: "Reward")
        request.sortDescriptors = []
        return request
    }
}
