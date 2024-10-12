//
//  WalkDetailView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import SwiftUI
import CoreData
import MapKit

// Struct to display task details
struct WalkDetailView: View {
    let task: TaskEntity // Use TaskEntity directly
    @Environment(\.managedObjectContext) private var viewContext // CoreData context
    @Environment(\.presentationMode) var presentationMode
    @State private var showEditTaskView = false
    
    // Create a region for the map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.865143, longitude: 151.209900), // Default to Sydney
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // Display the task title
                if let title = task.title {
                    Text(title)
                        .font(.largeTitle)
                        .padding()
                }

                VStack(alignment: .leading) {
                    // Display the scheduled time if available
                    if let dueDate = task.dueDate {
                        VStack(alignment: .leading) {
                            Text("Scheduled Time")
                                .font(.headline)
                            Text("\(dueDate, format: .dateTime)")
                                .padding(.bottom)
                        }
                    }

                    // Display the description (walkDescription)
                    if let walkDescription = task.walkDescription, !walkDescription.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.headline)
                            Text(walkDescription)
                                .padding(.bottom)
                        }
                    }
                }
                .padding()

                // Display a map showing the task location
                if let latitude = task.latitude, let longitude = task.longitude {
                    // If location is available, update the map region
                    Map(coordinateRegion: $region, annotationItems: [Location(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))]) { location in
                        MapMarker(coordinate: location.coordinate, tint: .blue)
                    }
                    .frame(height: 400)
                    .onAppear {
                        region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    }
                } else {
                    // If no location is set, show a message
                    Text("No location set for this task.")
                        .foregroundColor(.gray)
                        .padding()
                }

                Spacer()

                // Mark as Complete or Uncomplete Button
                Button(action: {
                    toggleTaskCompletion() // Call function to toggle completion
                }) {
                    Text(task.isCompleted ? "Mark Uncomplete" : "Mark Complete")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(task.isCompleted ? Color.red : Color.green) // Change button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Edit Task Button
                        Button {
                            showEditTaskView = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)

                        // Delete Task Button
                        Button(role: .destructive) {
                            deleteTask() // Call the function to delete the task
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showEditTaskView) {
            AddTaskView(task: task)
        }
    }

    // Function to toggle the completion status of a task
    private func toggleTaskCompletion() {
        task.isCompleted.toggle() // Toggle completion flag

        // Save the updated state to CoreData
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Dismiss the view after saving
        } catch {
            print("Error saving task: \(error.localizedDescription)")
        }
    }

    // Function to delete the task
    private func deleteTask() {
        viewContext.delete(task) // Remove the task from the CoreData context

        // Save the changes
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Dismiss the view after deletion
        } catch {
            print("Error deleting task: \(error.localizedDescription)")
        }
    }
}
