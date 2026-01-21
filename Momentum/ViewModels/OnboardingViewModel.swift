//
//  OnboardingViewModel.swift
//  Momentum
//  Manages the onboarding flow and user profile creation
//
//  Created by Oved Ramirez on 11/23/25.
//

import Foundation
import SwiftUI

@Observable
final class OnboardingViewModel {
    
    // MARK: - Onboarding State
    
    var currentStep: OnboardingStep = .welcome
    var isOnboardingComplete: Bool = false
    
    // MARK: - User Profile Data (Being Built)
    
    var userName: String = ""
    var age: String = ""
    var weight: String = ""
    var height: String = ""
    var useMetric: Bool = false
    
    // Goals
    var selectedPrimaryGoal: FitnessGoal = .maintenance
    var selectedSecondaryGoals: Set<FitnessGoal> = []
    
    // Habits
    var activityLevel: ActivityLevel = .moderate
    var workoutFrequency: Int = 3
    var selectedWorkoutTypes: Set<WorkoutType> = []
    
    // HealthKit
    var healthKitAuthorized: Bool = false
    var isInitialSyncComplete: Bool = false
    var syncProgress: Double = 0.0
    
    // MARK: - Dependencies
    
    private let dataStore: DataStore
    private let healthKitManager: HealthKitManager
    
    init(dataStore: DataStore = .shared, healthKitManager: HealthKitManager = .shared) {
        self.dataStore = dataStore
        self.healthKitManager = healthKitManager
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        guard let nextStep = currentStep.next else {
            completeOnboarding()
            return
        }
        
        withAnimation(Theme.Animations.standard) {
            currentStep = nextStep
        }
    }
    
    func previousStep() {
        guard let previousStep = currentStep.previous else { return }
        
        withAnimation(Theme.Animations.standard) {
            currentStep = previousStep
        }
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .goals:
            return true // At least primary goal is always selected
        case .habits:
            return true // Activity level always has default
        case .bodyStats:
            return !userName.isEmpty && !age.isEmpty
        case .healthKitPermission:
            return true // Can skip HealthKit
        case .initialSync:
            return isInitialSyncComplete
        case .complete:
            return true
        }
    }
    
    // MARK: - HealthKit Permission (REAL IMPLEMENTATION)
    
    func requestHealthKitPermission() async {
        print("🔵 Starting HealthKit permission request...")
        
        // Check if HealthKit is available
        guard HealthKitPermissions.isHealthKitAvailable else {
            print("❌ HealthKit is NOT available on this device")
            await MainActor.run {
                self.healthKitAuthorized = false
            }
            return
        }
        
        print("✅ HealthKit is available")
        
        do {
            print("🔵 Requesting authorization...")
            let authorized = try await healthKitManager.requestAuthorization()
            
            print("✅ Authorization result: \(authorized)")
            
            await MainActor.run {
                self.healthKitAuthorized = authorized
            }
            
            if authorized {
                print("✅ HealthKit authorized successfully")
            } else {
                print("⚠️ HealthKit not fully authorized")
            }
        } catch {
            print("❌ HealthKit authorization error: \(error.localizedDescription)")
            await MainActor.run {
                self.healthKitAuthorized = false
            }
        }
    }
    
    func skipHealthKit() {
        healthKitAuthorized = false
        nextStep()
    }
    
    // MARK: - Initial Sync
    
    func performInitialSync() async {
        guard healthKitAuthorized else {
            await MainActor.run {
                isInitialSyncComplete = true
            }
            return
        }
        
        // Start progress animation
        await MainActor.run {
            syncProgress = 0.0
        }
        
        // Perform actual HealthKit sync
        do {
            // Show progress while syncing
            let syncTask = Task {
                try await healthKitManager.performInitialSync()
            }
            
            // Animate progress bar
            while !syncTask.isCancelled && syncProgress < 0.95 {
                try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 seconds
                await MainActor.run {
                    syncProgress += 0.1
                }
            }
            
            // Wait for sync to complete
            try await syncTask.value
            
            // Complete to 100%
            await MainActor.run {
                syncProgress = 1.0
            }
            
            // Small delay so user can see 100%
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            await MainActor.run {
                isInitialSyncComplete = true
            }
            
            print("✅ Initial sync complete at 100%")
            
        } catch {
            print("❌ Sync error: \(error)")
            
            // Still complete to 100% even if error
            await MainActor.run {
                syncProgress = 1.0
                isInitialSyncComplete = true
            }
        }
    }
    
    // MARK: - Complete Onboarding
    
    func completeOnboarding() {
        // Create UserProfile from collected data
        let profile = UserProfile(
            name: userName,
            age: Int(age),
            weight: Double(weight),
            height: Double(height),
            useMetric: useMetric,
            primaryGoal: selectedPrimaryGoal,
            secondaryGoals: Array(selectedSecondaryGoals),
            activityLevel: activityLevel,
            workoutFrequency: workoutFrequency,
            preferredWorkouts: Array(selectedWorkoutTypes)
        )
        
        // Save to DataStore
        do {
            try dataStore.saveUserProfile(profile)
            
            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            isOnboardingComplete = true
            
            print("✅ Onboarding complete! Profile saved.")
        } catch {
            print("❌ Error saving profile: \(error)")
        }
    }
    
    // MARK: - Validation Helpers
    
    var isAgeValid: Bool {
        guard let ageInt = Int(age) else { return false }
        return ageInt >= 13 && ageInt <= 120
    }
    
    var isWeightValid: Bool {
        guard let weightDouble = Double(weight) else { return false }
        return weightDouble > 0 && weightDouble < 1000
    }
    
    var isHeightValid: Bool {
        guard let heightDouble = Double(height) else { return false }
        return heightDouble > 0 && heightDouble < 300
    }
}

// MARK: - Onboarding Steps

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case goals = 1
    case habits = 2
    case bodyStats = 3
    case healthKitPermission = 4
    case initialSync = 5
    case complete = 6
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Momentum"
        case .goals:
            return "What are your goals?"
        case .habits:
            return "Tell us about your habits"
        case .bodyStats:
            return "Your body stats"
        case .healthKitPermission:
            return "Sync with Apple Health"
        case .initialSync:
            return "Syncing your data"
        case .complete:
            return "You're all set!"
        }
    }
    
    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }
    
    var previous: OnboardingStep? {
        guard rawValue > 0 else { return nil }
        return OnboardingStep(rawValue: rawValue - 1)
    }
    
    var progress: Double {
        Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
}
