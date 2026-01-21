//
//  HealthKitPermissions.swift
//  Momentum
//
//  Manages HealthKit authorization and permissions
//
// Created by Oved Ramirez on 12/22/25.

import Foundation
import HealthKit

final class HealthKitPermissions {
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Availability Check
    
    static var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Data Types
    
    /// Types we want to READ from HealthKit
    private var typesToRead: Set<HKSampleType> {
        var types: Set<HKSampleType> = []
        
        // Activity metrics
        if let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }
        if let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            types.insert(distanceWalkingRunning)
        }
        if let activeEnergyBurned = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergyBurned)
        }
        if let basalEnergyBurned = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) {
            types.insert(basalEnergyBurned)
        }
        if let appleExerciseTime = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) {
            types.insert(appleExerciseTime)
        }
        
        // Heart rate (optional)
        if let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRate)
        }
        if let restingHeartRate = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(restingHeartRate)
        }
        
        // Flights climbed
        if let flightsClimbed = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) {
            types.insert(flightsClimbed)
        }
        
        // Workouts
        types.insert(HKObjectType.workoutType())
        
        return types
    }
    
    /// Types we want to WRITE to HealthKit (optional for now)
    private var typesToWrite: Set<HKSampleType> {
        var types: Set<HKSampleType> = []
        
        // Allow writing workouts back to HealthKit
        types.insert(HKObjectType.workoutType())
        
        return types
    }
    
    // MARK: - Request Authorization
    
    func requestAuthorization() async throws -> Bool {
        guard Self.isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // MARK: - Authorization Status
    
    func getAuthorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: type)
    }
    
    func isAuthorizedForSteps() -> Bool {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return false
        }
        let status = healthStore.authorizationStatus(for: stepType)
        return status == .sharingAuthorized
    }
    
    func isAuthorizedForWorkouts() -> Bool {
        let workoutType = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)
        return status == .sharingAuthorized
    }
    
    // MARK: - Permission Summary
    
    func getPermissionSummary() -> HealthKitPermissionStatus {
        let stepsAuthorized = isAuthorizedForSteps()
        let workoutsAuthorized = isAuthorizedForWorkouts()
        
        if stepsAuthorized && workoutsAuthorized {
            return .fullyAuthorized
        } else if stepsAuthorized || workoutsAuthorized {
            return .partiallyAuthorized
        } else {
            return .notAuthorized
        }
    }
}

// MARK: - Supporting Types

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case notAuthorized
    case queryFailed
    case noData
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .queryFailed:
            return "Failed to query HealthKit data"
        case .noData:
            return "No HealthKit data found"
        }
    }
}

enum HealthKitPermissionStatus {
    case notAuthorized
    case partiallyAuthorized
    case fullyAuthorized
    
    var description: String {
        switch self {
        case .notAuthorized:
            return "Not Authorized"
        case .partiallyAuthorized:
            return "Partially Authorized"
        case .fullyAuthorized:
            return "Fully Authorized"
        }
    }
}
