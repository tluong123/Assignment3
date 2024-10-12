//
//  FirestoreManager.swift
//  Assignment3
//
//  Created by thomas on 9/10/2024.
//

import FirebaseFirestore

class FirestoreManager: ObservableObject {
    @Published var dog: SimpleDog?
    private var db = Firestore.firestore()

    // This function should have a completion handler that returns a result
    func addOrUpdateDog(dog: SimpleDog, completion: @escaping (Result<Void, Error>) -> Void) {
        // Convert dog data to dictionary
        let dogData: [String: Any] = [
            "name": dog.name,
            "age": dog.age,
            "breed": dog.breed,
            "size": dog.size,
            "weight": dog.weight
        ]

        // Check if we have an existing dog
        if let existingDog = self.dog {
            // Update the existing dog document
            db.collection("dogs").document(existingDog.id).setData(dogData) { error in
                if let error = error {
                    completion(.failure(error)) // Return failure
                } else {
                    self.dog = dog // Update local dog object
                    completion(.success(())) // Return success
                }
            }
        } else {
            // Add a new dog document
            db.collection("dogs").addDocument(data: dogData) { error in
                if let error = error {
                    completion(.failure(error)) // Return failure
                } else {
                    self.dog = dog // Set the local dog object
                    completion(.success(())) // Return success
                }
            }
        }
    }
    
    // Fetch dog information from Firestore
    func fetchDog(completion: @escaping () -> Void) {
        db.collection("dogs").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching dog: \(error.localizedDescription)")
            } else if let document = snapshot?.documents.first {
                let data = document.data()
                self.dog = SimpleDog(
                    id: document.documentID, 
                    name: data["name"] as? String ?? "",
                    age: data["age"] as? Int ?? 0,
                    breed: data["breed"] as? String ?? "",
                    size: data["size"] as? String ?? "",
                    weight: data["weight"] as? Int ?? 0
                )
            }
            completion()
        }
    }
}
