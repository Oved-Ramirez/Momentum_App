//
//  DailyTask.swift
//  Momentum
//  Domain model for daily tasks and habits
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct DailyTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var category: TaskCategory
    var isCompleted: Bool
    var date: Date
    
    // Optional scheduling
    var scheduledTime: Date?
    var reminderEnabled: Bool
    
    // Metadata
    var createdAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        category: TaskCategory,
        isCompleted: Bool = false,
        date: Date = Date(),
        scheduledTime: Date? = nil,
        reminderEnabled: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.isCompleted = isCompleted
        self.date = date
        self.scheduledTime = scheduledTime
        self.reminderEnabled = reminderEnabled
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}

// MARK: - Supporting Enums

enum TaskCategory: String, Codable, CaseIterable {
    case fitness = "Fitness"
    case nutrition = "Nutrition"
    case wellness = "Wellness"
    case hydration = "Hydration"
    case sleep = "Sleep"
    case mindfulness = "Mindfulness"
    
    var icon: String {
        switch self {
        case .fitness: return "figure.run"
        case .nutrition: return "fork.knife"
        case .wellness: return "heart.fill"
        case .hydration: return "drop.fill"
        case .sleep: return "bed.double.fill"
        case .mindfulness: return "brain.head.profile"
        }
    }
    
    var color: String {
        switch self {
        case .fitness: return "blue"
        case .nutrition: return "green"
        case .wellness: return "pink"
        case .hydration: return "cyan"
        case .sleep: return "purple"
        case .mindfulness: return "indigo"
        }
    }
}

// MARK: - Helper Extensions

extension DailyTask {
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isOverdue: Bool {
        guard let scheduledTime = scheduledTime, !isCompleted else {
            return false
        }
        return scheduledTime < Date()
    }
    
    mutating func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}

// MARK: - Sample Tasks for Development

extension DailyTask {
    static let sampleTasks: [DailyTask] = [
        DailyTask(
            title: "Complete morning workout",
            description: "30 min strength training",
            category: .fitness
        ),
        DailyTask(
            title: "Log all meals",
            description: "Track breakfast, lunch, and dinner",
            category: .nutrition
        ),
        DailyTask(
            title: "Drink 8 glasses of water",
            category: .hydration
        ),
        DailyTask(
            title: "10 minute meditation",
            category: .mindfulness
        )
    ]
}
