//
//  UserProfileEntity.swift
//  Momentum
//  SwiftData persistence model for UserProfile
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class UserProfileEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var age: Int?
    var weight: Double?
    var height: Double?
    var useMetric: Bool
    
    // Goals (stored as raw values)
    var primaryGoalRaw: String
    var secondaryGoalsRaw: [String]
    var targetWeight: Double?
    
    // Activity & Experience
    var activityLevelRaw: String
    var fitnessExperienceRaw: String
    var workoutFrequency: Int
    var preferredWorkoutsRaw: [String]
    
    // Nutrition
    var dailyCalorieGoal: Int?
    var dailyProteinGoal: Int?
    
    // Metadata
    var createdAt: Date
    var lastUpdated: Date
    
    init(from profile: UserProfile) {
        self.id = profile.id
        self.name = profile.name
        self.age = profile.age
        self.weight = profile.weight
        self.height = profile.height
        self.useMetric = profile.useMetric
        self.primaryGoalRaw = profile.primaryGoal.rawValue
        self.secondaryGoalsRaw = profile.secondaryGoals.map { $0.rawValue }
        self.targetWeight = profile.targetWeight
        self.activityLevelRaw = profile.activityLevel.rawValue
        self.fitnessExperienceRaw = profile.fitnessExperience.rawValue
        self.workoutFrequency = profile.workoutFrequency
        self.preferredWorkoutsRaw = profile.preferredWorkouts.map { $0.rawValue }
        self.dailyCalorieGoal = profile.dailyCalorieGoal
        self.dailyProteinGoal = profile.dailyProteinGoal
        self.createdAt = profile.createdAt
        self.lastUpdated = profile.lastUpdated
    }
    
    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            name: name,
            age: age,
            weight: weight,
            height: height,
            useMetric: useMetric,
            primaryGoal: FitnessGoal(rawValue: primaryGoalRaw) ?? .maintenance,
            secondaryGoals: secondaryGoalsRaw.compactMap { FitnessGoal(rawValue: $0) },
            targetWeight: targetWeight,
            activityLevel: ActivityLevel(rawValue: activityLevelRaw) ?? .moderate,
            fitnessExperience: ExperienceLevel(rawValue: fitnessExperienceRaw) ?? .beginner,
            workoutFrequency: workoutFrequency,
            preferredWorkouts: preferredWorkoutsRaw.compactMap { WorkoutType(rawValue: $0) },
            dailyCalorieGoal: dailyCalorieGoal,
            dailyProteinGoal: dailyProteinGoal,
            createdAt: createdAt,
            lastUpdated: lastUpdated
        )
    }
}
