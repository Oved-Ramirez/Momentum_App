//
//  DailyTaskEntity.swift
//  Momentum
//  SwiftData persistence model for DailyTask
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class DailyTaskEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String?
    var categoryRaw: String
    var isCompleted: Bool
    var date: Date
    
    var scheduledTime: Date?
    var reminderEnabled: Bool
    
    var createdAt: Date
    var completedAt: Date?
    
    init(from task: DailyTask) {
        self.id = task.id
        self.title = task.title
        self.taskDescription = task.description
        self.categoryRaw = task.category.rawValue
        self.isCompleted = task.isCompleted
        self.date = task.date
        self.scheduledTime = task.scheduledTime
        self.reminderEnabled = task.reminderEnabled
        self.createdAt = task.createdAt
        self.completedAt = task.completedAt
    }
    
    func toDomain() -> DailyTask {
        DailyTask(
            id: id,
            title: title,
            description: taskDescription,
            category: TaskCategory(rawValue: categoryRaw) ?? .fitness,
            isCompleted: isCompleted,
            date: date,
            scheduledTime: scheduledTime,
            reminderEnabled: reminderEnabled,
            createdAt: createdAt,
            completedAt: completedAt
        )
    }
}
