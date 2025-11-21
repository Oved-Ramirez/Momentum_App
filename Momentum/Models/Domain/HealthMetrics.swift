//
//  HealthMetrics.swift
//  Momentum
//  Domain model for daily health metrics from HealthKit
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct HealthMetrics: Identifiable, Codable {
    let id: UUID
    var date: Date
    
    // Activity Metrics
    var steps: Int
    var distance: Double // miles or km
    var activeCalories: Int
    var totalCalories: Int
    var activeMinutes: Int
    
    // Heart Rate
    var averageHeartRate: Int?
    var restingHeartRate: Int?
    var maxHeartRate: Int?
    
    // Other
    var flightsClimbed: Int?
    
    // Metadata
    var lastSynced: Date
    var source: MetricSource
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        steps: Int = 0,
        distance: Double = 0,
        activeCalories: Int = 0,
        totalCalories: Int = 0,
        activeMinutes: Int = 0,
        averageHeartRate: Int? = nil,
        restingHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        flightsClimbed: Int? = nil,
        lastSynced: Date = Date(),
        source: MetricSource = .healthKit
    ) {
        self.id = id
        self.date = date
        self.steps = steps
        self.distance = distance
        self.activeCalories = activeCalories
        self.totalCalories = totalCalories
        self.activeMinutes = activeMinutes
        self.averageHeartRate = averageHeartRate
        self.restingHeartRate = restingHeartRate
        self.maxHeartRate = maxHeartRate
        self.flightsClimbed = flightsClimbed
        self.lastSynced = lastSynced
        self.source = source
    }
}

// MARK: - Supporting Types

enum MetricSource: String, Codable {
    case healthKit = "HealthKit"
    case manual = "Manual"
    case appleWatch = "Apple Watch"
}

// MARK: - Helper Extensions

extension HealthMetrics {
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var formattedSteps: String {
        steps.formatted(.number)
    }
    
    var formattedDistance: String {
        String(format: "%.2f mi", distance)
    }
    
    var formattedCalories: String {
        "\(activeCalories) cal"
    }
}
