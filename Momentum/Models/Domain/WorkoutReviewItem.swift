//
//  WorkoutReviewItem.swift
//  Momentum
//  Temporary model for pending HealthKit workouts awaiting user review
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct WorkoutReviewItem: Identifiable {
    let id: UUID
    var healthKitWorkoutId: UUID
    var date: Date
    var type: WorkoutType
    var duration: TimeInterval
    var calories: Int?
    var distance: Double?
    
    // Cardio-specific data
    var averagePace: Double?
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var elevationGain: Double?
    
    // Route data (if available)
    var hasRoute: Bool
    var routeData: Data?
    
    // Metadata
    var detectedAt: Date
    
    init(
        id: UUID = UUID(),
        healthKitWorkoutId: UUID,
        date: Date,
        type: WorkoutType,
        duration: TimeInterval,
        calories: Int? = nil,
        distance: Double? = nil,
        averagePace: Double? = nil,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        elevationGain: Double? = nil,
        hasRoute: Bool = false,
        routeData: Data? = nil,
        detectedAt: Date = Date()
    ) {
        self.id = id
        self.healthKitWorkoutId = healthKitWorkoutId
        self.date = date
        self.type = type
        self.duration = duration
        self.calories = calories
        self.distance = distance
        self.averagePace = averagePace
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.elevationGain = elevationGain
        self.hasRoute = hasRoute
        self.routeData = routeData
        self.detectedAt = detectedAt
    }
}

// MARK: - Helper Extensions

extension WorkoutReviewItem {
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var distanceFormatted: String? {
        guard let distance = distance else { return nil }
        return String(format: "%.2f mi", distance)
    }
    
    var caloriesFormatted: String? {
        guard let calories = calories else { return nil }
        return "\(calories) cal"
    }
    
    var isCardio: Bool {
        let cardioTypes: [WorkoutType] = [.running, .walking, .cycling, .swimming]
        return cardioTypes.contains(type)
    }
    
    // Convert to Workout for saving
    func toWorkout() -> Workout {
        Workout(
            id: UUID(),
            date: date,
            type: type,
            duration: duration,
            calories: calories,
            notes: nil,
            exercises: [],
            source: .healthKit,
            healthKitWorkoutId: healthKitWorkoutId,
            reviewStatus: .approved
        )
    }
    
    // Convert to CardioSession for cardio workouts
    func toCardioSession() -> CardioSession? {
        guard let cardioType = CardioType(rawValue: type.rawValue) else {
            return nil
        }
        
        return CardioSession(
            id: UUID(),
            date: date,
            type: cardioType,
            duration: duration,
            distance: distance,
            calories: calories,
            averagePace: averagePace,
            averageSpeed: nil,
            averageHeartRate: averageHeartRate,
            maxHeartRate: maxHeartRate,
            elevationGain: elevationGain,
            routeData: routeData,
            source: .healthKit,
            healthKitWorkoutId: healthKitWorkoutId
        )
    }
}
