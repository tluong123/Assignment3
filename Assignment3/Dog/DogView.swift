//
//  DogView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import SwiftUI

struct DogView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var navigateToDogInfoView = false
    @State private var shouldRefresh = false

    var body: some View {
        NavigationStack {
            Form {
                if let dog = firestoreManager.dog {
                    Section(header: Text("Dog Information")) {
                        HStack {
                            Text("Name:")
                            Spacer()
                            Text(dog.name)
                        }
                        HStack {
                            Text("Age:")
                            Spacer()
                            if dog.age > 0 {
                                Text("\(dog.age)")
                            }
                        }
                        HStack {
                            Text("Breed:")
                            Spacer()
                            Text(dog.breed)
                        }
                        HStack {
                            Text("Size:")
                            Spacer()
                            Text(dog.size)
                        }
                        HStack {
                            Text("Weight:")
                            Spacer()
                            if dog.weight > 0 {
                                Text("\(dog.weight)")
                            }
                        }
                    }
                } else {
                    Text("No Dog Information Available")
                }

                // Button to Edit Dog Info
                Button(action: {
                    navigateToDogInfoView = true
                }) {
                    Text("Edit Dog Info")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $navigateToDogInfoView) {
                    DogInfoView()
                        .environmentObject(firestoreManager)
                        .onAppear {
                            firestoreManager.fetchDog {
                            }
                        }
                }
            }
            .navigationTitle("Dog Info Display")
            .onAppear {
                firestoreManager.fetchDog {
                }
            }
        }
    }
}

struct DogView_Previews: PreviewProvider {
    static var previews: some View {
        DogView()
            .environmentObject(FirestoreManager()) // Provide FirestoreManager for the preview
    }
}
