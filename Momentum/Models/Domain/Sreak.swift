//
//  Sreak.swift
//  Momentum
//  Domain model for tracking user activity streaks
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct Streak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var streakStartDate: Date?
    
    // History of streak milestones
    var milestones: [StreakMilestone]
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActiveDate: Date? = nil,
        streakStartDate: Date? = nil,
        milestones: [StreakMilestone] = []
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDate = lastActiveDate
        self.streakStartDate = streakStartDate
        self.milestones = milestones
    }
}

// MARK: - Streak Milestone

struct StreakMilestone: Identifiable, Codable {
    let id: UUID
    var days: Int
    var achievedDate: Date
    var type: MilestoneType
    
    init(
        id: UUID = UUID(),
        days: Int,
        achievedDate: Date = Date(),
        type: MilestoneType
    ) {
        self.id = id
        self.days = days
        self.achievedDate = achievedDate
        self.type = type
    }
}

enum MilestoneType: String, Codable {
    case current = "Current Streak"
    case longest = "Longest Streak"
    case special = "Special Achievement"
}

// MARK: - Helper Extensions

extension Streak {
    var isActiveToday: Bool {
        guard let lastActive = lastActiveDate else { return false }
        return Calendar.current.isDateInToday(lastActive)
    }
    
    var needsActivity: Bool {
        guard let lastActive = lastActiveDate else { return true }
        
        // Check if last active was yesterday or today
        let calendar = Calendar.current
        if calendar.isDateInToday(lastActive) {
            return false // Already active today
        }
        
        if calendar.isDateInYesterday(lastActive) {
            return true // Need to be active today to maintain streak
        }
        
        // Streak is broken if more than 1 day passed
        return false
    }
    
    var streakBroken: Bool {
        guard let lastActive = lastActiveDate else { return false }
        
        let calendar = Calendar.current
        let daysSinceActive = calendar.dateComponents([.day], from: lastActive, to: Date()).day ?? 0
        
        // Streak is broken if more than 1 day has passed
        return daysSinceActive > 1
    }
    
    mutating func incrementStreak() {
        currentStreak += 1
        lastActiveDate = Date()
        
        if streakStartDate == nil {
            streakStartDate = Date()
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        // Add milestone for significant achievements
        if currentStreak % 7 == 0 { // Weekly milestones
            let milestone = StreakMilestone(
                days: currentStreak,
                achievedDate: Date(),
                type: .current
            )
            milestones.append(milestone)
        }
    }
    
    mutating func resetStreak() {
        currentStreak = 0
        streakStartDate = nil
    }
    
    var motivationalMessage: String {
        switch currentStreak {
        case 0:
            return "Start your streak today! 🔥"
        case 1:
            return "Great start! Keep it going! 💪"
        case 2...6:
            return "Building momentum! 🚀"
        case 7:
            return "One week strong! 🎉"
        case 8...13:
            return "You're on fire! 🔥"
        case 14:
            return "Two weeks! Incredible! 🌟"
        case 15...29:
            return "Unstoppable! Keep pushing! 💥"
        case 30:
            return "30 days! You're a legend! 👑"
        default:
            return "Amazing consistency! 🏆"
        }
    }
}
