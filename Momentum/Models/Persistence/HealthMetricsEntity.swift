//
//  HealthMeticsEntity.swift
//  Momentum
//  SwiftData persistence model for HealthMetrics
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class HealthMetricsEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    
    var steps: Int
    var distance: Double
    var activeCalories: Int
    var totalCalories: Int
    var activeMinutes: Int
    
    var averageHeartRate: Int?
    var restingHeartRate: Int?
    var maxHeartRate: Int?
    var flightsClimbed: Int?
    
    var lastSynced: Date
    var sourceRaw: String
    
    init(from metrics: HealthMetrics) {
        self.id = metrics.id
        self.date = metrics.date
        self.steps = metrics.steps
        self.distance = metrics.distance
        self.activeCalories = metrics.activeCalories
        self.totalCalories = metrics.totalCalories
        self.activeMinutes = metrics.activeMinutes
        self.averageHeartRate = metrics.averageHeartRate
        self.restingHeartRate = metrics.restingHeartRate
        self.maxHeartRate = metrics.maxHeartRate
        self.flightsClimbed = metrics.flightsClimbed
        self.lastSynced = metrics.lastSynced
        self.sourceRaw = metrics.source.rawValue
    }
    
    func toDomain() -> HealthMetrics {
        HealthMetrics(
            id: id,
            date: date,
            steps: steps,
            distance: distance,
            activeCalories: activeCalories,
            totalCalories: totalCalories,
            activeMinutes: activeMinutes,
            averageHeartRate: averageHeartRate,
            restingHeartRate: restingHeartRate,
            maxHeartRate: maxHeartRate,
            flightsClimbed: flightsClimbed,
            lastSynced: lastSynced,
            source: MetricSource(rawValue: sourceRaw) ?? .healthKit
        )
    }
}
