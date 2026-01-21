//
//  DashboardViewModel.swift
//  Momentum
//
// Manages dashboard data and state
//  Created by Oved Ramirez on 1/20/26.
//

import Foundation
import SwiftUI
import Combine

final class DashboardViewModel: ObservableObject {
    
    // MARK: - Published State
    
     @Published var healthMetrics: HealthMetrics?
     @Published var streak: Streak = Streak()
     @Published var todayTasks: [DailyTask] = []
     @Published var recentWorkouts: [Workout] = []
     @Published var userProfile: UserProfile?
     
     @Published var isLoading: Bool = false
     @Published var isRefreshing: Bool = false
     @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let dataStore: DataStore
    private let healthKitManager: HealthKitManager
    private let streakService: StreakService
    
    init(
        dataStore: DataStore = .shared,
        healthKitManager: HealthKitManager = .shared,
        streakService: StreakService = StreakService()
    ) {
        self.dataStore = dataStore
        self.healthKitManager = healthKitManager
        self.streakService = streakService
    }
    
    // MARK: - Load Dashboard Data
    
    @MainActor
    func loadDashboardData() async {
        isLoading = true
        errorMessage = nil
        
        print("🔵 Loading dashboard data...")
        
        do {
            // Load user profile first (can fail gracefully)
            do {
                self.userProfile = try await loadUserProfile()
                print("✅ Loaded user profile: \(userProfile?.name ?? "Unknown")")
            } catch {
                print("⚠️ No user profile yet: \(error)")
                self.userProfile = nil
            }
            
            // Load health metrics (critical)
            do {
                self.healthMetrics = try await loadHealthMetrics()
                print("✅ Loaded health metrics: \(healthMetrics?.steps ?? 0) steps")
            } catch {
                print("❌ Failed to load health metrics: \(error)")
                self.healthMetrics = nil
            }
            
            // Load tasks (can fail gracefully)
            do {
                self.todayTasks = try await loadTodayTasks()
                print("✅ Loaded \(todayTasks.count) tasks")
            } catch {
                print("⚠️ Failed to load tasks: \(error)")
                self.todayTasks = []
            }
            
            // Load workouts (can fail gracefully)
            do {
                self.recentWorkouts = try await loadRecentWorkouts()
                print("✅ Loaded \(recentWorkouts.count) workouts")
            } catch {
                print("⚠️ Failed to load workouts: \(error)")
                self.recentWorkouts = []
            }
            
            // Update streak (doesn't throw)
            self.streak = streakService.updateStreak()
            print("✅ Updated streak: \(streak.currentStreak) days")
            
            print("✅ Dashboard loaded successfully")
            
        } catch {
            print("❌ Critical error loading dashboard: \(error)")
            errorMessage = "Failed to load dashboard data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Refresh Data
    
    @MainActor
    func refresh() async {
        isRefreshing = true
        errorMessage = nil
        
        print("🔄 Refreshing dashboard...")
        
        do {
            // Sync latest HealthKit data
            let metrics = try await healthKitManager.syncTodayMetrics()
            self.healthMetrics = metrics
            
            print("✅ Refreshed metrics: \(metrics.steps) steps, \(metrics.activeCalories) cal")
            
            // Reload tasks and workouts
            self.todayTasks = try await loadTodayTasks()
            self.recentWorkouts = try await loadRecentWorkouts()
            
            print("✅ Loaded \(self.recentWorkouts.count) workouts")
            
            // Update streak
            self.streak = streakService.updateStreak()
            
            print("✅ Dashboard refreshed successfully")
        } catch {
            print("❌ Error refreshing: \(error.localizedDescription)")
            errorMessage = "Failed to refresh data"
        }
        
        isRefreshing = false
    }
    
    // MARK: - Individual Data Loaders
    
    private func loadHealthMetrics() async throws -> HealthMetrics? {
        print("🔵 Loading health metrics...")
        
        // Try to get from DataStore first
        do {
            if let cached = try dataStore.fetchTodayHealthMetrics() {
                print("✅ Found cached metrics: \(cached.steps) steps")
                return cached
            }
        } catch {
            print("⚠️ No cached metrics: \(error)")
        }
        
        // If no cached data, sync from HealthKit
        if healthKitManager.isAuthorized {
            print("🔵 No cached data, syncing from HealthKit...")
            do {
                let synced = try await healthKitManager.syncTodayMetrics()
                print("✅ Synced from HealthKit: \(synced.steps) steps")
                return synced
            } catch {
                print("❌ HealthKit sync failed: \(error)")
                // Return empty metrics instead of throwing
                return HealthMetrics(
                    steps: 0,
                    distance: 0,
                    activeCalories: 0,
                    totalCalories: 0,
                    activeMinutes: 0
                )
            }
        }
        
        print("⚠️ No HealthKit authorization, returning empty metrics")
        return HealthMetrics(
            steps: 0,
            distance: 0,
            activeCalories: 0,
            totalCalories: 0,
            activeMinutes: 0
        )
    }
    
    private func loadTodayTasks() async throws -> [DailyTask] {
        print("🔵 Loading today's tasks...")
        do {
            let tasks = try dataStore.fetchTasksForToday()
            print("✅ Loaded \(tasks.count) tasks")
            return tasks
        } catch {
            print("⚠️ Failed to load tasks: \(error)")
            return [] // Return empty array instead of throwing
        }
    }
    
    private func loadRecentWorkouts() async throws -> [Workout] {
        print("🔵 Loading recent workouts...")
        do {
            let workouts = try dataStore.fetchWorkouts(limit: 5)
            print("✅ Loaded \(workouts.count) workouts")
            return workouts
        } catch {
            print("⚠️ Failed to load workouts: \(error)")
            return [] // Return empty array instead of throwing
        }
    }
    private func loadUserProfile() async throws -> UserProfile? {
        print("🔵 Loading user profile...")
        do {
            let profile = try dataStore.fetchUserProfile()
            if let profile = profile {
                print("✅ Loaded profile: \(profile.name)")
            } else {
                print("⚠️ No user profile found")
            }
            return profile
        } catch {
            print("⚠️ Failed to load profile: \(error)")
            return nil
        }
    }
    // MARK: - Task Management
    
    @MainActor
    func toggleTask(_ task: DailyTask) {
        var updatedTask = task
        updatedTask.toggle()
        
        do {
            try dataStore.saveDailyTask(updatedTask)
            
            // Update in local array
            if let index = todayTasks.firstIndex(where: { $0.id == task.id }) {
                todayTasks[index] = updatedTask
            }
            
            // Update streak if task was completed
            if updatedTask.isCompleted {
                streak = streakService.updateStreak()
            }
        } catch {
            print("❌ Error toggling task: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    
    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userProfile?.name ?? "there"
        
        switch hour {
        case 0..<12:
            return "Good morning, \(name)!"
        case 12..<17:
            return "Good afternoon, \(name)!"
        case 17..<22:
            return "Good evening, \(name)!"
        default:
            return "Hello, \(name)!"
        }
    }
    
    var tasksCompletedToday: Int {
        todayTasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksToday: Int {
        todayTasks.count
    }
    
    var taskCompletionPercentage: Double {
        guard totalTasksToday > 0 else { return 0 }
        return Double(tasksCompletedToday) / Double(totalTasksToday)
    }
    
    var hasHealthData: Bool {
        healthMetrics != nil
    }
    
    var stepGoalProgress: Double {
        guard let steps = healthMetrics?.steps else { return 0 }
        let goal = 10000.0 // Default step goal
        return min(Double(steps) / goal, 1.0)
    }
    
    var calorieGoalProgress: Double {
        guard let calories = healthMetrics?.activeCalories else { return 0 }
        let goal = Double(userProfile?.dailyCalorieGoal ?? 500)
        return min(Double(calories) / goal, 1.0)
    }
}
