//
//  DogManager.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation


class DogManager: ObservableObject {
    @Published var dog: SimpleDog
    
    init(dog: SimpleDog = SimpleDog()) {
        self.dog = dog
    }
    
    func updateDog(name: String, age: Int, breed: String, size: String, weight: Int) {
        dog.name = name
        dog.age = age
        dog.breed = breed
        dog.size = size
        dog.weight = weight
    }
}
