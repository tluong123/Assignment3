//
//  TaskRowView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import Foundation
import SwiftUI
import CoreData

struct TaskRowView: View {
    var task: TaskEntity // Use TaskEntity directly

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Safely unwrap and handle task title
                if let title = task.title, !title.isEmpty {
                    Text(title)
                        .font(.headline)
                } else {
                    Text("No Title")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Display "Complete" or scheduled date if not completed
            if task.isCompleted {
                Text("Complete")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else if let dueDate = task.dueDate {
                Text("\(dueDate, format: .dateTime) ")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                Text("No Date")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
        .contentShape(Rectangle()) // Allows tapping the whole row
    }
}

