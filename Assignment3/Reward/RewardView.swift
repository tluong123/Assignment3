//
//  RewardView.swift
//  Assignment3
//
//  Created by thomas on 12/10/2024.
//

import SwiftUI
import CoreData

struct RewardView: View {
    @FetchRequest(
        entity: Reward.entity(),
        sortDescriptors: []
    ) var rewards: FetchedResults<Reward>
    
    @FetchRequest(
        entity: TaskEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: false)],
        predicate: NSPredicate(format: "isCompleted == true")
    ) var completedTasks: FetchedResults<TaskEntity>

    let pointsPerTask = 10 // You can set this value to determine how many points are earned per task

    // Computed property to determine progress goal based on current points
    private var progressGoal: Int {
        if let reward = rewards.first {
            if reward.totalPoints < 50 {
                return 50 // Bronze
            } else if reward.totalPoints < 150 {
                return 150 // Silver
            } else {
                return 300 // Gold
            }
        }
        return 50 // Default to first milestone if no rewards data is present
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                let rewardPoints = rewards.first?.totalPoints ?? 0
                
                Text("Total Points for this Month")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Progress bar for reward points
                ProgressView(value: min(Double(rewardPoints), Double(progressGoal)), total: Double(progressGoal))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal)
                
                // Display current points
                Text("\(rewardPoints) / \(progressGoal)")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                
                // Display inspiring message if points reach the current goal
                if rewardPoints >= progressGoal {
                    VStack {
                        Text("Congratulations!")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("You reached your current goal!")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Keep going for the next reward!")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .multilineTextAlignment(.center)
                }
                
                Divider()
                
                // Medal Section
                Text("Your Medals")
                    .font(.title2)
                    .padding(.top)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    VStack {
                        Image(systemName: "medal.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(rewardPoints >= 50 ? .brown : .gray) // Bronze
                        Text("Bronze")
                            .font(.subheadline)
                    }
                    VStack {
                        Image(systemName: "medal.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(rewardPoints >= 150 ? Color(UIColor.lightGray) : .gray) // Silver (lighter gray)
                        Text("Silver")
                            .font(.subheadline)
                    }
                    VStack {
                        Image(systemName: "medal.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(rewardPoints >= 300 ? .yellow : .gray) // Gold
                        Text("Gold")
                            .font(.subheadline)
                    }
                }
                .padding()
                
                Divider()
                
                // History of completed tasks with points
                Text("Completed Points History")
                    .font(.title2)
                    .padding(.top)
                    .multilineTextAlignment(.center)
                
                ForEach(completedTasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title ?? "Completed Task")
                                .font(.headline)
                            if let dueDate = task.dueDate {
                                Text("\(dueDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        // Display the points for each completed task
                        Text("+\(pointsPerTask) points")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 5)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .multilineTextAlignment(.center)
        }
        .navigationTitle("Reward Points")
        .onAppear {
            updateRewardPoints()
        }
    }

    // Function to save the Core Data context
    private func saveContext() {
        let context = rewards.first?.managedObjectContext
        do {
            try context?.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
    
    // Function to update reward points when tasks are marked as incomplete or removed
    private func updateRewardPoints() {
        guard let reward = rewards.first else { return }

        // Calculate points based on completed tasks
        let completedTaskCount = completedTasks.count
        let newTotalPoints = completedTaskCount * pointsPerTask

        if reward.totalPoints != newTotalPoints {
            reward.totalPoints = Int64(newTotalPoints)
            saveContext()
        }
    }
}

struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        // Setup for preview
        let context = PersistenceController.preview.container.viewContext
        let sampleReward = Reward(context: context)
        sampleReward.totalPoints = 300 // Set sample points for preview

        let sampleTask = TaskEntity(context: context)
        sampleTask.title = "Morning Walk"
        sampleTask.dueDate = Date()
        sampleTask.isCompleted = true

        return NavigationView {
            RewardView()
                .environment(\.managedObjectContext, context)
        }
    }
}

// Date formatter to format the task completion date
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
