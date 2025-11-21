//
//  CardioSession.swift
//  Momentum
//  Domain model for cardio-specific workouts
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct CardioSession: Identifiable, Codable {
    let id: UUID
    var date: Date
    var type: CardioType
    var duration: TimeInterval // in seconds
    var distance: Double? // miles or km
    var calories: Int?
    
    // Performance Metrics
    var averagePace: Double? // minutes per mile/km
    var averageSpeed: Double? // mph or km/h
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var elevationGain: Double? // feet or meters
    
    // Route data (for future map integration)
    var routeData: Data? // Encoded route coordinates
    
    // Source tracking
    var source: WorkoutSource
    var healthKitWorkoutId: UUID?
    
    // Metadata
    var createdAt: Date
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        type: CardioType,
        duration: TimeInterval = 0,
        distance: Double? = nil,
        calories: Int? = nil,
        averagePace: Double? = nil,
        averageSpeed: Double? = nil,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        elevationGain: Double? = nil,
        routeData: Data? = nil,
        source: WorkoutSource = .manual,
        healthKitWorkoutId: UUID? = nil,
        createdAt: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.duration = duration
        self.distance = distance
        self.calories = calories
        self.averagePace = averagePace
        self.averageSpeed = averageSpeed
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.elevationGain = elevationGain
        self.routeData = routeData
        self.source = source
        self.healthKitWorkoutId = healthKitWorkoutId
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Supporting Enums

enum CardioType: String, Codable, CaseIterable {
    case running = "Running"
    case walking = "Walking"
    case cycling = "Cycling"
    case hiking = "Hiking"
    case swimming = "Swimming"
    case rowing = "Rowing"
    case elliptical = "Elliptical"
    case stairClimber = "Stair Climber"
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .hiking: return "figure.hiking"
        case .swimming: return "figure.pool.swim"
        case .rowing: return "figure.rowing"
        case .elliptical: return "figure.elliptical"
        case .stairClimber: return "figure.stairs"
        }
    }
}

// MARK: - Helper Extensions

extension CardioSession {
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var distanceFormatted: String? {
        guard let distance = distance else { return nil }
        return String(format: "%.2f mi", distance)
    }
    
    var paceFormatted: String? {
        guard let pace = averagePace else { return nil }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d/mi", minutes, seconds)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
