//
//  Dog.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import Combine

// Protocol for Dog's information
protocol Dog: Identifiable, Codable {
    var id: String { get set }
    var name: String { get set }
    var age: Int { get set }
    var breed: String { get set }
    var size: String { get set }
    var weight: Int { get set }
}

// Implementation of Dog Protocol
class SimpleDog: Dog, ObservableObject {
    var id: String // Firestore uses String IDs
    var name: String
    var age: Int
    var breed: String
    var size: String
    var weight: Int
    
    // Initializer to create a SimpleDog instance
    init(id: String = UUID().uuidString, name: String = "", age: Int = 0, breed: String = "", size: String = "", weight: Int = 0) {
        self.id = id
        self.name = name
        self.age = age
        self.breed = breed
        self.size = size
        self.weight = weight
    }
    
    // Initializer to create a SimpleDog from Firestore data
    convenience init?(from data: [String: Any], documentID: String) {
        guard let name = data["name"] as? String,
              let age = data["age"] as? Int,
              let breed = data["breed"] as? String,
              let size = data["size"] as? String,
              let weight = data["weight"] as? Int else {
            return nil
        }
        
        self.init(id: documentID, name: name, age: age, breed: breed, size: size, weight: weight)
    }
}
