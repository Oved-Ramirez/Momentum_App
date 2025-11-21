//
//  WorkoutEntity.swift
//  Momentum
//  SwiftData persistence model for Workout
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class WorkoutEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var typeRaw: String
    var duration: TimeInterval
    var calories: Int?
    var notes: String?
    
    @Relationship(deleteRule: .cascade)
    var exercises: [ExerciseEntity]?
    
    var sourceRaw: String
    var healthKitWorkoutId: UUID?
    var reviewStatusRaw: String
    
    var createdAt: Date
    var lastUpdated: Date
    
    init(from workout: Workout) {
        self.id = workout.id
        self.date = workout.date
        self.typeRaw = workout.type.rawValue
        self.duration = workout.duration
        self.calories = workout.calories
        self.notes = workout.notes
        self.exercises = workout.exercises.map { ExerciseEntity(from: $0) }
        self.sourceRaw = workout.source.rawValue
        self.healthKitWorkoutId = workout.healthKitWorkoutId
        self.reviewStatusRaw = workout.reviewStatus.rawValue
        self.createdAt = workout.createdAt
        self.lastUpdated = workout.lastUpdated
    }
    
    func toDomain() -> Workout {
        Workout(
            id: id,
            date: date,
            type: WorkoutType(rawValue: typeRaw) ?? .strength,
            duration: duration,
            calories: calories,
            notes: notes,
            exercises: exercises?.map { $0.toDomain() } ?? [],
            source: WorkoutSource(rawValue: sourceRaw) ?? .manual,
            healthKitWorkoutId: healthKitWorkoutId,
            reviewStatus: ReviewStatus(rawValue: reviewStatusRaw) ?? .approved,
            createdAt: createdAt,
            lastUpdated: lastUpdated
        )
    }
}

@Model
final class ExerciseEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var notes: String?
    
    @Relationship(deleteRule: .cascade)
    var sets: [ExerciseSetEntity]?
    
    init(from exercise: Exercise) {
        self.id = exercise.id
        self.name = exercise.name
        self.notes = exercise.notes
        self.sets = exercise.sets.map { ExerciseSetEntity(from: $0) }
    }
    
    func toDomain() -> Exercise {
        Exercise(
            id: id,
            name: name,
            sets: sets?.map { $0.toDomain() } ?? [],
            notes: notes
        )
    }
}

@Model
final class ExerciseSetEntity {
    @Attribute(.unique) var id: UUID
    var reps: Int
    var weight: Double?
    var duration: TimeInterval?
    var completed: Bool
    
    init(from set: ExerciseSet) {
        self.id = set.id
        self.reps = set.reps
        self.weight = set.weight
        self.duration = set.duration
        self.completed = set.completed
    }
    
    func toDomain() -> ExerciseSet {
        ExerciseSet(
            id: id,
            reps: reps,
            weight: weight,
            duration: duration,
            completed: completed
        )
    }
}
