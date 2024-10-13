//
//  TaskListView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import SwiftUI
import FSCalendar
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showAddTaskView = false
    @State private var selectedDate = Date() // This holds the selected date
    @State private var selectedTasks: Set<TaskEntity.ID> = []
    @State private var showAddDogAlert = false
    @State private var shouldRefresh = false
    
    // FetchRequest to retrieve tasks from Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<TaskEntity>

    var body: some View {
        NavigationStack {
            VStack {
                // Calendar for selecting the date
                FSCalendarView(selectedDate: $selectedDate)
                    .padding()
                    .frame(height: 400)

                Spacer()

                // Filter tasks for the selected date
                let tasksForSelectedDate = tasks.filter { task in
                    guard let taskDate = task.dueDate else { return false }
                    return Calendar.current.isDate(taskDate, inSameDayAs: selectedDate)
                }

                // If there are no tasks, display a message
                if tasksForSelectedDate.isEmpty {
                    Text("No tasks for \(selectedDate, style: .date)")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(tasksForSelectedDate) { taskEntity in
                            NavigationLink(destination: WalkDetailView(task: taskEntity)
                                .onDisappear {
                                    shouldRefresh.toggle() // Trigger refresh when returning from WalkDetailView
                                }
                                .applyBackground
                            ) {
                                TaskRowView(task: taskEntity)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden) // Removes default list background
                    .background(Color.clear)
                    .id(shouldRefresh) // Use shouldRefresh to force the list to refresh
                }

    
                // Button to add new activity
                Button(action: {
                    showAddTaskView.toggle()
                }) {
                    Text("Add New Activity")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .sheet(isPresented: $showAddTaskView) {
                    AddTaskView()
                        .environment(\.managedObjectContext, viewContext)
                }
                .alert("Please add your dog's information first.", isPresented: $showAddDogAlert) {
                    Button("OK", role: .cancel) { }
                }

                Spacer()
            }
            .navigationTitle("Activity Calendar")
        }
    }

    // Function to delete tasks
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            viewContext.delete(task)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


// Preview setup
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        // Add sample data for the preview
        let sampleTask = TaskEntity(context: context)
        sampleTask.id = UUID()
        sampleTask.title = "Sample Walk"
        sampleTask.dueDate = Date()
        sampleTask.isCompleted = false

        return TaskListView()
            .environment(\.managedObjectContext, context)
    }
}
