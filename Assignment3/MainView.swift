//
//  MainView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import SwiftUI
import CoreData
import MapKit


struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var firestoreManager: FirestoreManager
    @State private var shouldRefresh = false
    @State private var showMap = false
    @State private var taskLocations: [Location] = []

    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<TaskEntity>

    var body: some View {
        NavigationStack {
            VStack {
                // Fetch dog information from Firestore when the view appears
                if let dog = firestoreManager.dog {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(dog.name)
                                .font(.title2)
                            Text("\(dog.age) years old, \(dog.breed)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        Spacer()
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                } else {
                    // If dog information is unavailable, prompt the user to add a dog
                    NavigationLink(destination: DogInfoView()
                        .environmentObject(firestoreManager)
                        .onDisappear {
                            shouldRefresh.toggle()
                        }) {
                        Text("Add your dog now!")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }

                // Task Schedule Section
                VStack(alignment: .leading) {
                    Text("Upcoming Schedule")
                        .font(.headline)
                        .padding(.leading)

                    // Filter tasks to only show incomplete ones
                    let incompleteTasks = tasks.filter { !$0.isCompleted }

                    // If there are no tasks, display a message
                    if incompleteTasks.isEmpty {
                        Text("No activities scheduled")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Otherwise, display the list of tasks
                        List {
                            ForEach(incompleteTasks) { task in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(task.title ?? "No Title") // Provide a default value
                                            .font(.headline)
                                    }
                                    Spacer()
                                    if let dueDate = task.dueDate {
                                        Text("\(dueDate, format: .dateTime)")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }


                Spacer()

                // Taskbar buttons
                HStack {
                    // Link to Calendar
                    NavigationLink(destination: TaskListView()
                        .environment(\.managedObjectContext, viewContext)
                        .onDisappear {
                            shouldRefresh.toggle()
                        }
                    ) {
                        VStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("Calendar")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }

                    Spacer()
                    
                    Button(action: {
                        loadTaskLocations()
                        showMap = true
                    }) {
                        VStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("Map")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    .sheet(isPresented: $showMap) {
                        TaskLocationMapView(taskLocations: $taskLocations) // Pass the task locations here
                    }

                    
                    Spacer()

                    // Link to viewing Dog information
                    NavigationLink(destination: DogView()
                        .environmentObject(firestoreManager)
                        .onDisappear {
                            shouldRefresh.toggle()
                        }) {
                        VStack {
                            Image(systemName: "pawprint")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("Your Dog")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
            .navigationTitle("FitPaws")
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                firestoreManager.fetchDog {
                }
            }
            .id(shouldRefresh)
        }
    }
    // Function to load task locations, excluding completed tasks
    private func loadTaskLocations() {
        taskLocations = tasks.filter { !$0.isCompleted }.compactMap { task in
            let latitude = task.latitude
            let longitude = task.longitude
            return Location(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
    }
}


// Preview setup
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        // Sample data for tasks
        let sampleTask = TaskEntity(context: context)
        sampleTask.id = UUID()
        sampleTask.title = "Sample Walk"
        sampleTask.dueDate = Date()
        sampleTask.isCompleted = false

        return MainView()
            .environment(\.managedObjectContext, context)
            .environmentObject(FirestoreManager()) // Use FirestoreManager for preview
    }
}
