//
//  WorkoutReviewViewModel.swift
//  Momentum
// Manages workout review and approval flow
//
//  Created by Oved Ramirez on 1/20/26.
//

import Foundation
import SwiftUI

@Observable
final class WorkoutReviewViewModel {
    
    // MARK: - State
    
    var pendingWorkouts: [WorkoutReviewItem] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let healthKitManager: HealthKitManager
    
    init(healthKitManager: HealthKitManager = .shared) {
        self.healthKitManager = healthKitManager
        
        // Load pending workouts from manager
        self.pendingWorkouts = healthKitManager.pendingWorkouts
    }
    
    // MARK: - Fetch Pending Workouts
    
    @MainActor
    func fetchPendingWorkouts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await healthKitManager.syncWorkouts()
            pendingWorkouts = healthKitManager.pendingWorkouts.sorted { $0.date > $1.date }
            
            print("📥 Found \(pendingWorkouts.count) pending workouts")
        } catch {
            print("❌ Error fetching workouts: \(error)")
            errorMessage = "Failed to fetch workouts"
        }
        
        isLoading = false
    }
    // MARK: - Fetch last (30 days) Workouts
    @MainActor
    func fetchAllWorkouts() async {
        isLoading = true
        errorMessage = nil
        
        print("📥 Fetching workouts from last 30 days...")
        
        do {
            // Fetch workouts from last 30 days
            try await healthKitManager.fetchRecentWorkouts(days: 30)
            
            // Sort by date, newest first
            pendingWorkouts = healthKitManager.pendingWorkouts.sorted { $0.date > $1.date }
            
            print("📥 Found \(pendingWorkouts.count) workouts")
        } catch {
            print("❌ Error fetching workouts: \(error)")
            errorMessage = "Failed to fetch workouts"
        }
        
        isLoading = false
    }
    // MARK: - Approve Workout
    
    @MainActor
    func approveWorkout(_ workout: WorkoutReviewItem) async {
        do {
            try await healthKitManager.approveWorkout(workout)
            
            // Remove from pending list
            pendingWorkouts.removeAll { $0.id == workout.id }
            
            print("✅ Approved workout: \(workout.type.rawValue)")
        } catch {
            print("❌ Error approving workout: \(error)")
            errorMessage = "Failed to approve workout"
        }
    }
    
    // MARK: - Ignore Workout
    
    @MainActor
    func ignoreWorkout(_ workout: WorkoutReviewItem) {
        healthKitManager.ignoreWorkout(workout)
        
        // Remove from pending list
        pendingWorkouts.removeAll { $0.id == workout.id }
        
        print("⏭️ Ignored workout: \(workout.type.rawValue)")
    }
    
    // MARK: - Batch Actions
    
    @MainActor
    func approveAll() async {
        for workout in pendingWorkouts {
            try? await healthKitManager.approveWorkout(workout)
        }
        
        pendingWorkouts.removeAll()
        print("✅ Approved all workouts")
    }
    
    @MainActor
    func ignoreAll() {
        for workout in pendingWorkouts {
            healthKitManager.ignoreWorkout(workout)
        }
        
        pendingWorkouts.removeAll()
        print("⏭️ Ignored all workouts")
    }
    
    // MARK: - Computed Properties
    
    var hasPendingWorkouts: Bool {
        !pendingWorkouts.isEmpty
    }
    
    var pendingCount: Int {
        pendingWorkouts.count
    }
}
