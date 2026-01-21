//
//  HealthKitAutoSync.swift
//  Momentum
//
//  Created by Oved Ramirez on 12/22/25.
//

import Foundation
import HealthKit

final class HealthKitAutoSync {
    
    private let healthStore = HKHealthStore()
    private let dataStore: DataStore
    
    init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
    }
    
    // MARK: - Sync Today's Metrics
    
    func syncTodayMetrics() async throws -> HealthMetrics {
        print("🔵 [SYNC] Starting HealthKit sync...")
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        // Required metrics (will throw if fail)
        print("🔵 [SYNC] Fetching steps...")
        let stepsValue = try await fetchSteps(from: startOfDay, to: now)
        print("✅ [SYNC] Steps: \(stepsValue)")
        
        print("🔵 [SYNC] Fetching distance...")
        let distanceValue = try await fetchDistance(from: startOfDay, to: now)
        print("✅ [SYNC] Distance: \(distanceValue)")
        
        print("🔵 [SYNC] Fetching calories...")
        let activeCaloriesValue = try await fetchActiveCalories(from: startOfDay, to: now)
        let totalCaloriesValue = try await fetchTotalCalories(from: startOfDay, to: now)
        print("✅ [SYNC] Calories: \(activeCaloriesValue)")
        
        print("🔵 [SYNC] Fetching active minutes...")
        let activeMinutesValue = try await fetchActiveMinutes(from: startOfDay, to: now)
        print("✅ [SYNC] Active minutes: \(activeMinutesValue)")
        
        // Optional metrics (won't fail sync if unavailable)
        var heartRateValues: (average: Int?, resting: Int?, max: Int?) = (nil, nil, nil)
        do {
            print("🔵 [SYNC] Fetching heart rate...")
            heartRateValues = try await fetchHeartRateData(from: startOfDay, to: now)
            print("✅ [SYNC] Heart rate: \(heartRateValues.average ?? 0)")
        } catch {
            print("⚠️ [SYNC] Heart rate not available: \(error.localizedDescription)")
        }
        
        var flightsValue: Int? = nil
        do {
            print("🔵 [SYNC] Fetching flights...")
            flightsValue = try await fetchFlightsClimbed(from: startOfDay, to: now)
            print("✅ [SYNC] Flights: \(flightsValue ?? 0)")
        } catch {
            print("⚠️ [SYNC] Flights not available (this is normal)")
        }
        
        print("🔵 [SYNC] Creating metrics object...")
        let metrics = HealthMetrics(
            date: now,
            steps: stepsValue,
            distance: distanceValue,
            activeCalories: activeCaloriesValue,
            totalCalories: totalCaloriesValue,
            activeMinutes: activeMinutesValue,
            averageHeartRate: heartRateValues.average,
            restingHeartRate: heartRateValues.resting,
            maxHeartRate: heartRateValues.max,
            flightsClimbed: flightsValue,
            lastSynced: Date(),
            source: .healthKit
        )
        
        print("🔵 [SYNC] Saving to DataStore...")
        try dataStore.saveHealthMetrics(metrics)
        
        print("✅ [SYNC] COMPLETE! Steps: \(metrics.steps), Calories: \(metrics.activeCalories)")
        
        return metrics
    }
    
    // MARK: - Individual Metric Fetchers
    
    private func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }
        
        let value = try await querySum(for: stepType, from: startDate, to: endDate)
        return Int(value)
    }
    
    private func fetchDistance(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return 0
        }
        
        let meters = try await querySum(for: distanceType, from: startDate, to: endDate)
        let miles = meters / 1609.34 // Convert meters to miles
        return miles
    }
    
    private func fetchActiveCalories(from startDate: Date, to endDate: Date) async throws -> Int {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }
        
        let value = try await querySum(for: activeEnergyType, from: startDate, to: endDate)
        return Int(value)
    }
    
    private func fetchTotalCalories(from startDate: Date, to endDate: Date) async throws -> Int {
        // Total = Active + Basal
        let activeCalories = try await fetchActiveCalories(from: startDate, to: endDate)
        
        guard let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else {
            return activeCalories
        }
        
        let basalCalories = try await querySum(for: basalEnergyType, from: startDate, to: endDate)
        return activeCalories + Int(basalCalories)
    }
    
    private func fetchActiveMinutes(from startDate: Date, to endDate: Date) async throws -> Int {
        guard let exerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            return 0
        }
        
        let seconds = try await querySum(for: exerciseTimeType, from: startDate, to: endDate)
        return Int(seconds / 60) // Convert seconds to minutes
    }
    
    private func fetchHeartRateData(from startDate: Date, to endDate: Date) async throws -> (average: Int?, resting: Int?, max: Int?) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return (nil, nil, nil)
        }
        
        // Fetch all heart rate samples
        let samples = try await querySamples(for: heartRateType, from: startDate, to: endDate)
        
        guard !samples.isEmpty else {
            return (nil, nil, nil)
        }
        
        let heartRates = samples.compactMap { sample -> Double? in
            guard let quantitySample = sample as? HKQuantitySample else { return nil }
            return quantitySample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        }
        
        let average = heartRates.isEmpty ? nil : Int(heartRates.reduce(0, +) / Double(heartRates.count))
        let max = heartRates.isEmpty ? nil : Int(heartRates.max() ?? 0)
        
        // Fetch resting heart rate separately
        var resting: Int? = nil
        if let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            let restingSamples = try await querySamples(for: restingHRType, from: startDate, to: endDate)
            if let lastResting = restingSamples.last as? HKQuantitySample {
                resting = Int(lastResting.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
            }
        }
        
        return (average, resting, max)
    }
    
    private func fetchFlightsClimbed(from startDate: Date, to endDate: Date) async throws -> Int? {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            return nil
        }
        
        do {
            let value = try await querySum(for: flightsType, from: startDate, to: endDate)
            return value > 0 ? Int(value) : nil
        } catch {
            // Flights data not available - this is OK, just return nil
            print("⚠️ [SYNC] Flights data not available (this is normal)")
            return nil
        }
    }
    
    // MARK: - Query Helpers
    
    private func querySum(for quantityType: HKQuantityType, from startDate: Date, to endDate: Date) async throws -> Double {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let unit: HKUnit
                switch quantityType.identifier {
                case HKQuantityTypeIdentifier.stepCount.rawValue:
                    unit = .count()
                case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
                    unit = .meter()
                case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
                     HKQuantityTypeIdentifier.basalEnergyBurned.rawValue:
                    unit = .kilocalorie()
                case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
                    unit = .second()
                case HKQuantityTypeIdentifier.flightsClimbed.rawValue:
                    unit = .count()
                default:
                    unit = .count()
                }
                
                let value = sum.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func querySamples(for quantityType: HKQuantityType, from startDate: Date, to endDate: Date) async throws -> [HKSample] {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: samples ?? [])
            }
            
            healthStore.execute(query)
        }
    }
}
