//
//  DogInfoView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import SwiftUI

struct DogInfoView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode

    // Temporary state variables to hold edited values
    @State private var editedName: String = ""
    @State private var editedAge: Int = 0
    @State private var editedBreed: String = ""
    @State private var editedSize: String = ""
    @State private var editedWeight: Int = 0
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @State private var isSaving = false // To manage UI state during saving
    
    var dog: SimpleDog?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Dog Information")) {
                    LabeledContent("*Name:") {
                        TextField("Enter dog's name", text: $editedName)
                            .onAppear {
                                editedName = dog?.name ?? ""
                            }
                    }
                    Picker("*Age:", selection: $editedAge) {
                        ForEach(0...25, id: \.self) { age in
                            Text("\(age)").tag(age)
                        }
                    }
                    .onAppear {
                        editedAge = dog?.age ?? 0
                    }
                    LabeledContent("*Breed:") {
                        TextField("Enter breed", text: $editedBreed)
                            .onAppear {
                                editedBreed = dog?.breed ?? ""
                            }
                    }
                    LabeledContent("*Size:") {
                        TextField("Enter size (e.g., Large, Medium)", text: $editedSize)
                            .onAppear {
                                editedSize = dog?.size ?? ""
                            }
                    }
                    Picker("*Weight(kg):", selection: $editedWeight) {
                        ForEach(0...100, id: \.self) { weight in
                            Text("\(weight)").tag(weight)
                        }
                    }
                    .onAppear {
                        editedWeight = dog?.weight ?? 0
                    }
                }
            }
            .navigationTitle("Your Dog's Info")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSaving {
                        ProgressView() // Show a progress indicator while saving
                    } else {
                        Button("Save") {
                            if validateFields() {
                                saveDog()
                            }
                        }
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    // Validate all fields and show appropriate alert messages
    private func validateFields() -> Bool {
        if editedName.isEmpty {
            alertMessage = "Please enter your dog's name."
            showAlert = true
            return false
        }
        if editedAge == 0 {
            alertMessage = "Please select a valid age for your dog."
            showAlert = true
            return false
        }
        if editedBreed.isEmpty {
            alertMessage = "Please enter your dog's breed."
            showAlert = true
            return false
        }
        if editedSize.isEmpty {
            alertMessage = "Please enter your dog's size (e.g., Small, Medium, Large)."
            showAlert = true
            return false
        }
        if editedWeight == 0 {
            alertMessage = "Please enter a valid weight for your dog."
            showAlert = true
            return false
        }
        return true
    }

    // Save the dog information to Firestore with error handling
    private func saveDog() {
        let newDog = SimpleDog(
            name: editedName,
            age: editedAge,
            breed: editedBreed,
            size: editedSize,
            weight: editedWeight
        )

        // Set the saving state
        isSaving = true

        // Save dog to Firestore with a completion handler to handle success and failure
        firestoreManager.addOrUpdateDog(dog: newDog) { result in
            isSaving = false // Reset saving state regardless of the result

            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss() // Close the view if successful
            case .failure(let error):
                alertMessage = "Error saving dog data: \(error.localizedDescription)"
                showAlert = true // Show an alert if there's an error
            }
        }
    }

}
