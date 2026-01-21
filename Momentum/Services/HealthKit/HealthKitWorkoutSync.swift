//
//  HealthKitWorkoutSync.swift
//  Momentum
//
//  Handles workout syncing with review flow
//
// Created by Oved Ramirez on 12/22/25.

import Foundation
import HealthKit

final class HealthKitWorkoutSync {
    
    private let healthStore = HKHealthStore()
    private let dataStore: DataStore
    
    // Anchor for tracking last synced workout
    private var workoutAnchor: HKQueryAnchor? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "workoutAnchor"),
                  let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data) else {
                return nil
            }
            return anchor
        }
        set {
            if let anchor = newValue,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "workoutAnchor")
            }
        }
    }
    
    init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
    }
    
    // MARK: - Fetch New Workouts
    
    func fetchNewWorkouts() async throws -> [WorkoutReviewItem] {
        let workoutType = HKObjectType.workoutType()
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(
                type: workoutType,
                predicate: nil,
                anchor: workoutAnchor,
                limit: HKObjectQueryNoLimit
            ) { [weak self] query, samples, deletedObjects, newAnchor, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Update anchor for next sync
                self?.workoutAnchor = newAnchor
                
                guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Convert to WorkoutReviewItems
                let reviewItems = workouts.compactMap { self?.convertToReviewItem($0) }
                
                print("📥 Found \(reviewItems.count) new workouts to review")
                continuation.resume(returning: reviewItems)
            }
            
            healthStore.execute(query)
        }
    }
    // MARK: - Fetch Recent Workouts (Last 30 Days)

    func fetchRecentWorkouts(days: Int = 30) async throws -> [WorkoutReviewItem] {
        let workoutType = HKObjectType.workoutType()
        
        // Create date range for last 30 days
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
        
        print("📥 Fetching workouts from last \(days) days...")
        
        return try await withCheckedThrowingContinuation { continuation in
            // Create predicate for date range
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: .strictStartDate
            )
            
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { [weak self] query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Convert to WorkoutReviewItems
                let reviewItems = workouts.compactMap { self?.convertToReviewItem($0) }
                
                print("📥 Found \(reviewItems.count) workouts from last \(days) days")
                continuation.resume(returning: reviewItems)
            }
            
            healthStore.execute(query)
        }
    }
    // MARK: - Convert HKWorkout to WorkoutReviewItem
    
    private func convertToReviewItem(_ workout: HKWorkout) -> WorkoutReviewItem? {
        // Map HKWorkoutActivityType to our WorkoutType
        guard let workoutType = mapWorkoutType(workout.workoutActivityType) else {
            return nil
        }
        
        let calories: Int?
        if let energyStats = workout.statistics(for: HKQuantityType(.activeEnergyBurned)) {
            if let sum = energyStats.sumQuantity() {
                calories = Int(sum.doubleValue(for: .kilocalorie()))
            } else {
                calories = nil
            }
        } else {
            calories = nil
        }

        let distance: Double?
        if let distanceStats = workout.statistics(for: HKQuantityType(.distanceWalkingRunning)) {
            if let sum = distanceStats.sumQuantity() {
                distance = sum.doubleValue(for: .mile())
            } else {
                distance = nil
            }
        } else {
            distance = nil
        }
        
        return WorkoutReviewItem(
            healthKitWorkoutId: workout.uuid,
            date: workout.startDate,
            type: workoutType,
            duration: workout.duration,
            calories: calories,
            distance: distance,
            averagePace: nil, // Can calculate from distance/duration if needed
            averageHeartRate: nil, // Would need separate query
            maxHeartRate: nil,
            elevationGain: nil,
            hasRoute: false,
            routeData: nil,
            detectedAt: Date()
        )
    }
    
    // MARK: - Map HKWorkoutActivityType to WorkoutType
    
    private func mapWorkoutType(_ activityType: HKWorkoutActivityType) -> WorkoutType? {
        switch activityType {
        case .running:
            return .running
        case .walking:
            return .walking
        case .cycling:
            return .cycling
        case .swimming:
            return .swimming
        case .hiking:
            return .walking
        case .traditionalStrengthTraining, .functionalStrengthTraining:
            return .strength
        case .highIntensityIntervalTraining:
            return .hiit
        case .yoga:
            return .yoga
        case .pilates:
            return .pilates
        case .stairClimbing:
            return .stairClimber
        case .soccer:
            return .soccer
        case .pickleball:
            return .pickleball
        case .basketball:
            return .basketball
        case .tennis:
            return .tennis
        case .volleyball:
            return .volleyball
        default:
            // Filter out unsupported workout types
            return nil
        }
    }
    
    // MARK: - Approve Workout
    
    func approveWorkout(_ reviewItem: WorkoutReviewItem) async throws {
        // Check if it's a cardio workout
        if reviewItem.isCardio, let cardioSession = reviewItem.toCardioSession() {
            try dataStore.saveCardioSession(cardioSession)
            print("✅ Approved cardio workout: \(reviewItem.type.rawValue)")
        } else {
            // Save as regular workout
            let workout = reviewItem.toWorkout()
            try dataStore.saveWorkout(workout)
            print("✅ Approved workout: \(reviewItem.type.rawValue)")
        }
    }
    
    // MARK: - Ignore Workout
    
    func ignoreWorkout(_ reviewItem: WorkoutReviewItem) {
        // Just don't save it - anchor already updated
        print("⏭️ Ignored workout: \(reviewItem.type.rawValue)")
    }
    
    // MARK: - Background Observer
    
    func enableBackgroundDelivery(completion: @escaping (Bool, Error?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        
        healthStore.enableBackgroundDelivery(
            for: workoutType,
            frequency: .immediate
        ) { success, error in
            if success {
                print("✅ Background delivery enabled for workouts")
            } else {
                print("❌ Failed to enable background delivery: \(error?.localizedDescription ?? "unknown")")
            }
            completion(success, error)
        }
    }
    
    func setupWorkoutObserver(handler: @escaping ([WorkoutReviewItem]) -> Void) {
        let workoutType = HKObjectType.workoutType()
        
        let query = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("❌ Observer query error: \(error)")
                completionHandler()
                return
            }
            
            Task {
                do {
                    let newWorkouts = try await self?.fetchNewWorkouts() ?? []
                    if !newWorkouts.isEmpty {
                        await MainActor.run {
                            handler(newWorkouts)
                        }
                    }
                } catch {
                    print("❌ Error fetching new workouts: \(error)")
                }
                completionHandler()
            }
        }
        
        healthStore.execute(query)
        print("👀 Workout observer setup complete")
    }
}
