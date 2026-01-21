//
//  DailyTasksCard.swift
//  Momentum
//  Displays daily tasks checklist
//
//  Created by Oved Ramirez on 1/20/26.
//

import SwiftUI

struct DailyTasksCard: View {
    let tasks: [DailyTask]
    let onToggle: (DailyTask) -> Void
    
    var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        tasks.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header
            HStack {
                Text("Today's Focus")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.text)
                
                Spacer()
                
                Text("\(completedCount)/\(totalCount)")
                    .font(Theme.Fonts.bodyBold)
                    .foregroundColor(Theme.Colors.primary)
            }
            
            // Progress bar
            ProgressView(value: progress)
                .tint(Theme.Colors.primary)
            
            // Tasks list
            if tasks.isEmpty {
                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Text("No tasks for today")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.lg)
            } else {
                VStack(spacing: Theme.Spacing.sm) {
                    ForEach(tasks) { task in
                        TaskRow(task: task, onToggle: onToggle)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

struct TaskRow: View {
    let task: DailyTask
    let onToggle: (DailyTask) -> Void
    
    var body: some View {
        Button {
            withAnimation(Theme.Animations.quick) {
                onToggle(task)
            }
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                // Checkbox
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? Theme.Colors.success : Theme.Colors.secondaryText)
                
                // Task info
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.text)
                        .strikethrough(task.isCompleted)
                    
                    if let description = task.description {
                        Text(description)
                            .font(Theme.Fonts.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Category icon
                Image(systemName: task.category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(categoryColor(for: task.category))
            }
            .padding(.vertical, Theme.Spacing.xs)
        }
        .buttonStyle(.plain)
    }
    
    private func categoryColor(for category: TaskCategory) -> Color {
        switch category {
        case .fitness: return Theme.Colors.fitness
        case .nutrition: return Theme.Colors.nutrition
        case .wellness: return Theme.Colors.wellness
        case .hydration: return Theme.Colors.hydration
        case .sleep: return Theme.Colors.sleep
        case .mindfulness: return Theme.Colors.mindfulness
        }
    }
}

#Preview {
    VStack {
        DailyTasksCard(
            tasks: DailyTask.sampleTasks,
            onToggle: { _ in }
        )
    }
    .padding()
}
