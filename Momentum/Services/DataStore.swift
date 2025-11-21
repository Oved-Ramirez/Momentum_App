//
//  DataStore.swift
//  Momentum
//  Central service for managing SwiftData persistence
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation
import SwiftData


@Observable
final class DataStore {
    static let shared = DataStore()
    
    private var container: ModelContainer?
    private var context: ModelContext?
    
    private init() {
        setupContainer()
    }
    
    private func setupContainer() {
        let schema = Schema([
            UserProfileEntity.self,
            HealthMetricsEntity.self,
            WorkoutEntity.self,
            ExerciseEntity.self,
            ExerciseSetEntity.self,
            CardioSessionEntity.self,
            MealEntity.self,
            FoodItemEntity.self,
            DailyTaskEntity.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
            context = ModelContext(container!)
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Context Access
    
    func getContext() -> ModelContext? {
        return context
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) throws {
        guard let context = context else { return }
        
        // Check if profile exists
        let descriptor = FetchDescriptor<UserProfileEntity>(
            predicate: #Predicate { $0.id == profile.id }
        )
        
        if let existing = try context.fetch(descriptor).first {
            // Update existing
            existing.name = profile.name
            existing.age = profile.age
            existing.weight = profile.weight
            existing.height = profile.height
            existing.useMetric = profile.useMetric
            existing.primaryGoalRaw = profile.primaryGoal.rawValue
            existing.secondaryGoalsRaw = profile.secondaryGoals.map { $0.rawValue }
            existing.targetWeight = profile.targetWeight
            existing.activityLevelRaw = profile.activityLevel.rawValue
            existing.fitnessExperienceRaw = profile.fitnessExperience.rawValue
            existing.workoutFrequency = profile.workoutFrequency
            existing.preferredWorkoutsRaw = profile.preferredWorkouts.map { $0.rawValue }
            existing.dailyCalorieGoal = profile.dailyCalorieGoal
            existing.dailyProteinGoal = profile.dailyProteinGoal
            existing.lastUpdated = Date()
        } else {
            // Create new
            let entity = UserProfileEntity(from: profile)
            context.insert(entity)
        }
        
        try context.save()
    }
    
    func fetchUserProfile() throws -> UserProfile? {
        guard let context = context else { return nil }
        
        let descriptor = FetchDescriptor<UserProfileEntity>()
        let entities = try context.fetch(descriptor)
        return entities.first?.toDomain()
    }
    
    // MARK: - Health Metrics
    
    func saveHealthMetrics(_ metrics: HealthMetrics) throws {
        guard let context = context else { return }
        
        // Check if metrics for this date exist
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: metrics.date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<HealthMetricsEntity>(
            predicate: #Predicate { entity in
                entity.date >= startOfDay && entity.date < endOfDay
            }
        )
        
        if let existing = try context.fetch(descriptor).first {
            // Update existing metrics
            existing.steps = metrics.steps
            existing.distance = metrics.distance
            existing.activeCalories = metrics.activeCalories
            existing.totalCalories = metrics.totalCalories
            existing.activeMinutes = metrics.activeMinutes
            existing.averageHeartRate = metrics.averageHeartRate
            existing.restingHeartRate = metrics.restingHeartRate
            existing.maxHeartRate = metrics.maxHeartRate
            existing.flightsClimbed = metrics.flightsClimbed
            existing.lastSynced = Date()
        } else {
            // Create new
            let entity = HealthMetricsEntity(from: metrics)
            context.insert(entity)
        }
        
        try context.save()
    }
    
    func fetchTodayHealthMetrics() throws -> HealthMetrics? {
        guard let context = context else { return nil }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<HealthMetricsEntity>(
            predicate: #Predicate { entity in
                entity.date >= startOfDay && entity.date < endOfDay
            }
        )
        
        let entities = try context.fetch(descriptor)
        return entities.first?.toDomain()
    }
    
    func fetchHealthMetrics(from startDate: Date, to endDate: Date) throws -> [HealthMetrics] {
        guard let context = context else { return [] }
        
        let descriptor = FetchDescriptor<HealthMetricsEntity>(
            predicate: #Predicate { entity in
                entity.date >= startDate && entity.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    // MARK: - Workouts
    
    func saveWorkout(_ workout: Workout) throws {
        guard let context = context else { return }
        
        let entity = WorkoutEntity(from: workout)
        context.insert(entity)
        try context.save()
    }
    
    func fetchWorkouts(limit: Int = 50) throws -> [Workout] {
        guard let context = context else { return [] }
        
        var descriptor = FetchDescriptor<WorkoutEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func fetchWorkoutsForToday() throws -> [Workout] {
        guard let context = context else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<WorkoutEntity>(
            predicate: #Predicate { entity in
                entity.date >= startOfDay && entity.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func deleteWorkout(_ workout: Workout) throws {
        guard let context = context else { return }
        
        let descriptor = FetchDescriptor<WorkoutEntity>(
            predicate: #Predicate { $0.id == workout.id }
        )
        
        if let entity = try context.fetch(descriptor).first {
            context.delete(entity)
            try context.save()
        }
    }
    
    // MARK: - Cardio Sessions
    
    func saveCardioSession(_ session: CardioSession) throws {
        guard let context = context else { return }
        
        let entity = CardioSessionEntity(from: session)
        context.insert(entity)
        try context.save()
    }
    
    func fetchCardioSessions(limit: Int = 50) throws -> [CardioSession] {
        guard let context = context else { return [] }
        
        var descriptor = FetchDescriptor<CardioSessionEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func fetchCardioSessionsLast7Days() throws -> [CardioSession] {
        guard let context = context else { return [] }
        
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let descriptor = FetchDescriptor<CardioSessionEntity>(
            predicate: #Predicate { entity in
                entity.date >= sevenDaysAgo
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    // MARK: - Meals
    
    func saveMeal(_ meal: Meal) throws {
        guard let context = context else { return }
        
        let entity = MealEntity(from: meal)
        context.insert(entity)
        try context.save()
    }
    
    func fetchMealsForToday() throws -> [Meal] {
        guard let context = context else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { entity in
                entity.date >= startOfDay && entity.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func deleteMeal(_ meal: Meal) throws {
        guard let context = context else { return }
        
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { $0.id == meal.id }
        )
        
        if let entity = try context.fetch(descriptor).first {
            context.delete(entity)
            try context.save()
        }
    }
    
    // MARK: - Daily Tasks
    
    func saveDailyTask(_ task: DailyTask) throws {
        guard let context = context else { return }
        
        let descriptor = FetchDescriptor<DailyTaskEntity>(
            predicate: #Predicate { $0.id == task.id }
        )
        
        if let existing = try context.fetch(descriptor).first {
            // Update existing
            existing.title = task.title
            existing.taskDescription = task.description
            existing.categoryRaw = task.category.rawValue
            existing.isCompleted = task.isCompleted
            existing.completedAt = task.completedAt
        } else {
            // Create new
            let entity = DailyTaskEntity(from: task)
            context.insert(entity)
        }
        
        try context.save()
    }
    
    func fetchTasksForToday() throws -> [DailyTask] {
        guard let context = context else { return [] }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<DailyTaskEntity>(
            predicate: #Predicate { entity in
                entity.date >= startOfDay && entity.date < endOfDay
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        let entities = try context.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func deleteTask(_ task: DailyTask) throws {
        guard let context = context else { return }
        
        let descriptor = FetchDescriptor<DailyTaskEntity>(
            predicate: #Predicate { $0.id == task.id }
        )
        
        if let entity = try context.fetch(descriptor).first {
            context.delete(entity)
            try context.save()
        }
    }
}
