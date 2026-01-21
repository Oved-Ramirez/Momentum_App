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
                // Main app with real dashboard
                MainTabView()
            } else {
                // Show onboarding
                OnboardingContainerView()
            }
        }
    }
}

// Main tab view with Dashboard
struct MainTabView: View {
    var body: some View {
        TabView {
            // Dashboard tab - NOW WITH REAL DATA
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Fitness tab (placeholder for now)
            PlaceholderView(title: "Fitness", icon: "dumbbell.fill")
                .tabItem {
                    Label("Fitness", systemImage: "dumbbell.fill")
                }
            
            // Cardio tab (placeholder for now)
            PlaceholderView(title: "Cardio", icon: "figure.run")
                .tabItem {
                    Label("Cardio", systemImage: "figure.run")
                }
            
            // Meals tab (placeholder for now)
            PlaceholderView(title: "Meals", icon: "fork.knife")
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
            
            // Profile tab (placeholder for now)
            PlaceholderView(title: "Profile", icon: "person.fill")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Theme.Colors.primary)
    }
}

// Simple placeholder for tabs we haven't built yet
struct PlaceholderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primary.opacity(0.5))
                
                Text("\(title) Coming Soon")
                    .font(Theme.Fonts.title2)
                    .foregroundColor(Theme.Colors.text)
                
                Text("This feature will be available in the next phase")
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView()
}
