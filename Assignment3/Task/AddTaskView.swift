//
//  AddTaskView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import SwiftUI
import CoreData
import MapKit

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dogManager: DogManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showMissingFieldsAlert = false
    @State private var showMap = false
    
    var task: TaskEntity?
    @State private var taskTitle: String
    @State private var taskDueDate: Date
    @State private var taskDescription: String
    @State private var selectedLocation: CLLocationCoordinate2D?

    // Optional task passed in for editing; set default values if task is nil
    init(task: TaskEntity? = nil) {
        self.task = task
        _taskTitle = State(initialValue: task?.title ?? "")
        _taskDueDate = State(initialValue: task?.dueDate ?? Date())
        _taskDescription = State(initialValue: task?.walkDescription ?? "")
        _selectedLocation = State(initialValue: {
            if let latitude = task?.latitude, let longitude = task?.longitude {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            } else {
                return nil
            }
        }())
    }

    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Activity Name")
                            .font(.headline)
                        Text("*")
                            .foregroundColor(.red)
                    }
                    // Suggested activity names
                    TextField("Walk, Haircut, Medication, Vet Visit", text: $taskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()

                VStack(alignment: .leading) {
                    HStack {
                        Text("Location")
                            .font(.headline)
                        Text("*")
                            .foregroundColor(.red)
                        
                        
                        if selectedLocation != nil {
                            Text("Location Selected")
                                .foregroundColor(.gray)
                        } else {
                            Text("No location selected")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    Button(action: {
                        showMap = true // Show the map view
                    }) {
                        Text("Select Location on Map")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                VStack(alignment: .leading) {
                    Text("Description (optional)")
                        .font(.headline)
                    TextField("Enter description", text: $taskDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()

                DatePicker("Scheduled Date", selection: $taskDueDate, displayedComponents: [.date, .hourAndMinute])
                    .padding()

                Button(action: {
                    if taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedLocation == nil {
                        showMissingFieldsAlert = true
                    } else {
                        if let task = task {
                            editTask(task)
                        } else {
                            addTask()
                        }
                    }
                }) {
                    Text(task == nil ? "Add to Calendar" : "Save Changes")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle(task == nil ? "Add New Activity" : "Edit Activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Please fill in all required fields.", isPresented: $showMissingFieldsAlert) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $showMap) {
                MapView(selectedLocation: $selectedLocation, isPresented: $showMap) // Present MapView to select location
            }
        }
    }

    // Function to add a new task to Core Data
    private func addTask() {
        guard let entity = NSEntityDescription.entity(forEntityName: "TaskEntity", in: viewContext) else {
            fatalError("Failed to find entity description for TaskEntity")
        }

        let newTask = TaskEntity(entity: entity, insertInto: viewContext)
        newTask.id = UUID()
        newTask.title = taskTitle
        newTask.dueDate = taskDueDate
        newTask.walkDescription = taskDescription
        newTask.isCompleted = false
        if let location = selectedLocation {
            newTask.latitude = location.latitude // Save the latitude
            newTask.longitude = location.longitude // Save the longitude
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        presentationMode.wrappedValue.dismiss()
    }

    // Function to edit an existing task
    private func editTask(_ task: TaskEntity) {
        task.title = taskTitle
        task.dueDate = taskDueDate
        task.walkDescription = taskDescription
        if let location = selectedLocation {
            task.latitude = location.latitude
            task.longitude = location.longitude
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(DogManager())
    }
}
