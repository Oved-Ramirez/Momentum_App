//
//  userProfile.swift
//  Momentum
//  Domain model for user profile and settings
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var age: Int?
    var weight: Double? // in pounds or kg
    var height: Double? // in inches or cm
    var useMetric: Bool
    
    // Goals
    var primaryGoal: FitnessGoal
    var secondaryGoals: [FitnessGoal]
    var targetWeight: Double?
    
    // Activity & Experience
    var activityLevel: ActivityLevel
    var fitnessExperience: ExperienceLevel
    var workoutFrequency: Int // times per week
    var preferredWorkouts: [WorkoutType]
    
    // Nutrition
    var dailyCalorieGoal: Int?
    var dailyProteinGoal: Int? // grams
    
    // Metadata
    var createdAt: Date
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        name: String = "",
        age: Int? = nil,
        weight: Double? = nil,
        height: Double? = nil,
        useMetric: Bool = false,
        primaryGoal: FitnessGoal = .maintenance,
        secondaryGoals: [FitnessGoal] = [],
        targetWeight: Double? = nil,
        activityLevel: ActivityLevel = .moderate,
        fitnessExperience: ExperienceLevel = .beginner,
        workoutFrequency: Int = 3,
        preferredWorkouts: [WorkoutType] = [],
        dailyCalorieGoal: Int? = nil,
        dailyProteinGoal: Int? = nil,
        createdAt: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.weight = weight
        self.height = height
        self.useMetric = useMetric
        self.primaryGoal = primaryGoal
        self.secondaryGoals = secondaryGoals
        self.targetWeight = targetWeight
        self.activityLevel = activityLevel
        self.fitnessExperience = fitnessExperience
        self.workoutFrequency = workoutFrequency
        self.preferredWorkouts = preferredWorkouts
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Supporting Enums

enum FitnessGoal: String, Codable, CaseIterable {
    case loseWeight = "Lose Weight"
    case buildMuscle = "Build Muscle"
    case maintenance = "Maintain Health"
    case improveEndurance = "Improve Endurance"
    case increaseStrength = "Increase Strength"
    case flexibility = "Improve Flexibility"
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Lightly Active"
    case moderate = "Moderately Active"
    case veryActive = "Very Active"
    case extreme = "Extremely Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .veryActive: return 1.725
        case .extreme: return 1.9
        }
    }
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case elite = "Elite"
}

enum WorkoutType: String, Codable, CaseIterable {
    case strength = "Strength Training"
    case cardio = "Cardio"
    case hiit = "HIIT"
    case yoga = "Yoga"
    case pilates = "Pilates"
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case walking = "Walking"
    case sports = "Sports"
}
