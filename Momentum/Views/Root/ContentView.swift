//
//  ContentView.swift
//  Momentum
//
//  Created by Oved Ramirez on 11/20/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                // Main app (will build in Phase 3+)
                MainTabView()
            } else {
                // Show onboarding
                OnboardingContainerView()
            }
        }
    }
}

// Temporary placeholder for main app
struct MainTabView: View {
    var body: some View {
        TabView {
            // Dashboard tab
            Text("Dashboard")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Fitness tab
            Text("Fitness")
                .tabItem {
                    Label("Fitness", systemImage: "dumbbell.fill")
                }
            
            // Cardio tab
            Text("Cardio")
                .tabItem {
                    Label("Cardio", systemImage: "figure.run")
                }
            
            // Meals tab
            Text("Meals")
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
            
            // Profile tab
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Theme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
