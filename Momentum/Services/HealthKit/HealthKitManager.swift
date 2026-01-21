//
//  HealthKitManager.swift
//  Momentum
//
//  Main coordinator for all HealthKit operations
//  Created by Oved Ramirez on 12/22/25.
//

import Foundation
import HealthKit
import Combine

@Observable
final class HealthKitManager {
    static let shared = HealthKitManager()
    
    // Sub-services
    private let permissions: HealthKitPermissions
    private let autoSync: HealthKitAutoSync
    private let workoutSync: HealthKitWorkoutSync
    
    // Published state
    var isAuthorized: Bool = false
    var permissionStatus: HealthKitPermissionStatus = .notAuthorized
    var pendingWorkouts: [WorkoutReviewItem] = []
    var lastSyncDate: Date?
    
    private init() {
        self.permissions = HealthKitPermissions()
        self.autoSync = HealthKitAutoSync()
        self.workoutSync = HealthKitWorkoutSync()
        
        // Check initial authorization status
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws -> Bool {
        let success = try await permissions.requestAuthorization()
        
        await MainActor.run {
            self.isAuthorized = success
            self.permissionStatus = permissions.getPermissionSummary()
        }
        
        if success {
            // Enable background delivery for workouts
            workoutSync.enableBackgroundDelivery { success, error in
                if success {
                    print("✅ Background delivery enabled")
                }
            }
            
            // Setup workout observer
            setupWorkoutObserver()
            
            // Perform initial sync
            try? await performInitialSync()
        }
        
        return success
    }
    
    func checkAuthorizationStatus() {
        isAuthorized = permissions.isAuthorizedForSteps() || permissions.isAuthorizedForWorkouts()
        permissionStatus = permissions.getPermissionSummary()
    }
    
    // MARK: - Sync Operations
    
    func performInitialSync() async throws {
        print("🔄 Performing initial HealthKit sync...")
        
        // Sync today's metrics
        let _ = try await autoSync.syncTodayMetrics()
        
        // Fetch any new workouts
        let newWorkouts = try await workoutSync.fetchNewWorkouts()
        
        await MainActor.run {
            self.pendingWorkouts = newWorkouts
            self.lastSyncDate = Date()
        }
        
        print("✅ Initial sync complete")
    }
    
    func syncTodayMetrics() async throws -> HealthMetrics {
        let metrics = try await autoSync.syncTodayMetrics()
        
        await MainActor.run {
            self.lastSyncDate = Date()
        }
        
        return metrics
    }
    
    func syncWorkouts() async throws {
        let newWorkouts = try await workoutSync.fetchNewWorkouts()
        
        await MainActor.run {
            self.pendingWorkouts.append(contentsOf: newWorkouts)
        }
    }
    // MARK: - Fetch Recent Workouts

    func fetchRecentWorkouts(days: Int = 30) async throws {
        let workouts = try await workoutSync.fetchRecentWorkouts(days: days)
        
        await MainActor.run {
            self.pendingWorkouts = workouts
        }
    }
    
    // MARK: - Workout Review
    
    func approveWorkout(_ workout: WorkoutReviewItem) async throws {
        try await workoutSync.approveWorkout(workout)
        
        await MainActor.run {
            self.pendingWorkouts.removeAll { $0.id == workout.id }
        }
    }
    
    func ignoreWorkout(_ workout: WorkoutReviewItem) {
        workoutSync.ignoreWorkout(workout)
        
        pendingWorkouts.removeAll { $0.id == workout.id }
    }
    
    // MARK: - Background Observer
    
    private func setupWorkoutObserver() {
        workoutSync.setupWorkoutObserver { [weak self] newWorkouts in
            self?.pendingWorkouts.append(contentsOf: newWorkouts)
            
            // Notify user if there are pending workouts
            if !newWorkouts.isEmpty {
                print("🔔 \(newWorkouts.count) new workout(s) detected")
                // TODO: Show notification or badge
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    var hasPendingWorkouts: Bool {
        !pendingWorkouts.isEmpty
    }
    
    func clearPendingWorkouts() {
        pendingWorkouts.removeAll()
    }
}
