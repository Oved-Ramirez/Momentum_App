//
//  CardioSessionEntity.swift
//  Momentum
//  SwiftData persistence model for CardioSession
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class CardioSessionEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var typeRaw: String
    var duration: TimeInterval
    var distance: Double?
    var calories: Int?
    
    var averagePace: Double?
    var averageSpeed: Double?
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var elevationGain: Double?
    
    @Attribute(.externalStorage)
    var routeData: Data?
    
    var sourceRaw: String
    var healthKitWorkoutId: UUID?
    
    var createdAt: Date
    var lastUpdated: Date
    
    init(from session: CardioSession) {
        self.id = session.id
        self.date = session.date
        self.typeRaw = session.type.rawValue
        self.duration = session.duration
        self.distance = session.distance
        self.calories = session.calories
        self.averagePace = session.averagePace
        self.averageSpeed = session.averageSpeed
        self.averageHeartRate = session.averageHeartRate
        self.maxHeartRate = session.maxHeartRate
        self.elevationGain = session.elevationGain
        self.routeData = session.routeData
        self.sourceRaw = session.source.rawValue
        self.healthKitWorkoutId = session.healthKitWorkoutId
        self.createdAt = session.createdAt
        self.lastUpdated = session.lastUpdated
    }
    
    func toDomain() -> CardioSession {
        CardioSession(
            id: id,
            date: date,
            type: CardioType(rawValue: typeRaw) ?? .running,
            duration: duration,
            distance: distance,
            calories: calories,
            averagePace: averagePace,
            averageSpeed: averageSpeed,
            averageHeartRate: averageHeartRate,
            maxHeartRate: maxHeartRate,
            elevationGain: elevationGain,
            routeData: routeData,
            source: WorkoutSource(rawValue: sourceRaw) ?? .manual,
            healthKitWorkoutId: healthKitWorkoutId,
            createdAt: createdAt,
            lastUpdated: lastUpdated
        )
    }
}
