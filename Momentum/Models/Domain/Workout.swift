//
//  Workout.swift
//  Momentum
//  Domain model for workout sessions
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    var date: Date
    var type: WorkoutType
    var duration: TimeInterval // in seconds
    var calories: Int?
    var notes: String?
    
    // Exercises (for strength workouts)
    var exercises: [Exercise]
    
    // Source tracking
    var source: WorkoutSource
    var healthKitWorkoutId: UUID? // Reference to HealthKit workout
    
    // Review status (for HealthKit workouts)
    var reviewStatus: ReviewStatus
    
    // Metadata
    var createdAt: Date
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        type: WorkoutType,
        duration: TimeInterval = 0,
        calories: Int? = nil,
        notes: String? = nil,
        exercises: [Exercise] = [],
        source: WorkoutSource = .manual,
        healthKitWorkoutId: UUID? = nil,
        reviewStatus: ReviewStatus = .approved,
        createdAt: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.duration = duration
        self.calories = calories
        self.notes = notes
        self.exercises = exercises
        self.source = source
        self.healthKitWorkoutId = healthKitWorkoutId
        self.reviewStatus = reviewStatus
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Exercise Model

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var sets: [ExerciseSet]
    var notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        sets: [ExerciseSet] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
    }
}

struct ExerciseSet: Identifiable, Codable {
    let id: UUID
    var reps: Int
    var weight: Double? // pounds or kg
    var duration: TimeInterval? // for timed exercises
    var completed: Bool
    
    init(
        id: UUID = UUID(),
        reps: Int = 0,
        weight: Double? = nil,
        duration: TimeInterval? = nil,
        completed: Bool = false
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.completed = completed
    }
}

// MARK: - Supporting Enums

enum WorkoutSource: String, Codable {
    case manual = "Manual"
    case healthKit = "HealthKit"
    case appleWatch = "Apple Watch"
}

enum ReviewStatus: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case ignored = "Ignored"
}

// MARK: - Helper Extensions

extension Workout {
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var needsReview: Bool {
        reviewStatus == .pending && source == .healthKit
    }
}
