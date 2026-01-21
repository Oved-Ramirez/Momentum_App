//
//  StreakService.swift
//  Momentum
//
//  Created by Oved Ramirez on 1/20/26.
//

import Foundation

final class StreakService {
    
    private let dataStore: DataStore
    private let streakKey = "userStreak"
    
    init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
    }
    
    // MARK: - Get Current Streak
    
    func getCurrentStreak() -> Streak {
        // Try to load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let streak = try? JSONDecoder().decode(Streak.self, from: data) {
            return streak
        }
        
        // Return new streak if none exists
        return Streak()
    }
    
    // MARK: - Update Streak
    
    func updateStreak() -> Streak {
        var streak = getCurrentStreak()
        
        // Check if user was active today
        let wasActiveToday = checkIfActiveToday()
        
        if wasActiveToday {
            if streak.isActiveToday {
                // Already counted today, just return current streak
                return streak
            } else if streak.needsActivity {
                // Was active yesterday, increment streak
                streak.incrementStreak()
                saveStreak(streak)
            } else if streak.streakBroken {
                // Streak was broken, start new one
                streak.resetStreak()
                streak.incrementStreak()
                saveStreak(streak)
            } else {
                // First day of streak
                streak.incrementStreak()
                saveStreak(streak)
            }
        } else {
            // Not active today yet
            if streak.streakBroken {
                // Streak is broken, reset it
                streak.resetStreak()
                saveStreak(streak)
            }
        }
        
        return streak
    }
    
    // MARK: - Check Activity
    
    private func checkIfActiveToday() -> Bool {
        // Check if user has any activity today:
        // 1. Completed any tasks
        // 2. Logged any workouts
        // 3. Has significant step count (>1000 steps)
        
        do {
            // Check for completed tasks today
            let tasks = try dataStore.fetchTasksForToday()
            let hasCompletedTasks = tasks.contains { $0.isCompleted }
            
            // Check for workouts today
            let workouts = try dataStore.fetchWorkoutsForToday()
            let hasWorkouts = !workouts.isEmpty
            
            // Check for step count
            let metrics = try dataStore.fetchTodayHealthMetrics()
            let hasSignificantSteps = (metrics?.steps ?? 0) >= 1000
            
            return hasCompletedTasks || hasWorkouts || hasSignificantSteps
        } catch {
            print("❌ Error checking activity: \(error)")
            return false
        }
    }
    
    // MARK: - Save/Load
    
    private func saveStreak(_ streak: Streak) {
        if let data = try? JSONEncoder().encode(streak) {
            UserDefaults.standard.set(data, forKey: streakKey)
        }
    }
    
    func resetStreak() {
        var streak = getCurrentStreak()
        streak.resetStreak()
        saveStreak(streak)
    }
    
    // MARK: - Helper Methods
    
    func getStreakMessage() -> String {
        let streak = getCurrentStreak()
        return streak.motivationalMessage
    }
    
    func shouldCelebrateMilestone() -> Bool {
        let streak = getCurrentStreak()
        // Celebrate at 7, 14, 30, 60, 100 days
        let milestones = [7, 14, 30, 60, 100]
        return milestones.contains(streak.currentStreak)
    }
}
