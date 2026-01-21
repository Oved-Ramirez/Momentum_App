//
//  WorkoutReviewView.swift
//  Momentum
//  Strava-style workout review and approval screen
//
//  Created by Oved Ramirez on 1/20/26.
//

import SwiftUI

struct WorkoutReviewView: View {
    @State private var viewModel = WorkoutReviewViewModel()
    @Environment(\.dismiss) private var dismiss
    var onWorkoutsChanged: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading workouts...")
                } else if !viewModel.hasPendingWorkouts {
                    // Empty state
                    emptyStateView
                } else {
                    // Workout list
                    workoutListView
                }
            }
            .navigationTitle("Review Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                       Button("Fetch All") {
                           Task {
                               await viewModel.fetchAllWorkouts()
                           }
                       }
                   }
                
                if viewModel.hasPendingWorkouts {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                Task {
                                    await viewModel.approveAll()
                                }
                            } label: {
                                Label("Approve All", systemImage: "checkmark.circle")
                            }
                            
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.ignoreAll()
                                }
                            } label: {
                                Label("Ignore All", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .task {
                await viewModel.fetchPendingWorkouts()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Theme.Colors.success)
            
            Text("All Caught Up!")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.text)
            
            Text("No new workouts to review")
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.secondaryText)
        }
    }
    
    // MARK: - Workout List
    
    private var workoutListView: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                // Header
                HStack {
                    Text("\(viewModel.pendingCount) new workout\(viewModel.pendingCount == 1 ? "" : "s")")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.sm)
                
                // Workout cards
                ForEach(viewModel.pendingWorkouts) { workout in
                    WorkoutReviewCard(
                        workout: workout,
                        onApprove: {
                            Task {
                                await viewModel.approveWorkout(workout)
                            }
                        },
                        onIgnore: {
                            viewModel.ignoreWorkout(workout)
                        }
                    )
                    .padding(.horizontal, Theme.Spacing.md)
                }
                
                // Bottom spacing
                Color.clear.frame(height: Theme.Spacing.xl)
            }
        }
    }
}

// MARK: - Workout Review Card

struct WorkoutReviewCard: View {
    let workout: WorkoutReviewItem
    let onApprove: () -> Void
    let onIgnore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header with workout type and icon
            HStack {
                Image(systemName: workoutIcon)
                    .font(.system(size: 32))
                    .foregroundColor(workoutColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.type.rawValue)
                        .font(Theme.Fonts.title3)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text(workout.date, style: .date)
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
            }
            
            // Workout stats
            HStack(spacing: Theme.Spacing.lg) {
                // Duration
                StatItem(
                    icon: "clock.fill",
                    value: workout.durationFormatted,
                    label: "Duration"
                )
                
                // Calories (if available)
                if let calories = workout.caloriesFormatted {
                    StatItem(
                        icon: "flame.fill",
                        value: calories,
                        label: "Calories"
                    )
                }
                
                // Distance (if available)
                if let distance = workout.distanceFormatted {
                    StatItem(
                        icon: "location.fill",
                        value: distance,
                        label: "Distance"
                    )
                }
            }
            
            Divider()
            
            // Action buttons
            HStack(spacing: Theme.Spacing.md) {
                // Ignore button
                Button {
                    withAnimation(Theme.Animations.quick) {
                        onIgnore()
                    }
                } label: {
                    Text("Ignore")
                        .font(Theme.Fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                }
                .secondaryButtonStyle()
                
                // Add to Momentum button
                Button {
                    withAnimation(Theme.Animations.quick) {
                        onApprove()
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Momentum")
                    }
                    .font(Theme.Fonts.bodyBold)
                    .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
    
    private var workoutIcon: String {
        switch workout.type {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .strength: return "dumbbell.fill"
        case .hiit: return "flame.fill"
        case .yoga: return "figure.yoga"
        case .stairClimber: return "figure.stairs"
        case .soccer: return "soccerball"
        case .pickleball: return "figure.tennis"
        default: return "figure.walk"
        }
    }
    
    private var workoutColor: Color {
        switch workout.type {
        case .running, .cardio: return Theme.Colors.cardio
        case .strength: return Theme.Colors.strength
        case .yoga: return Theme.Colors.yoga
        case .hiit: return Theme.Colors.hiit
        default: return Theme.Colors.primary
        }
    }
}

// MARK: - Stat Item Component

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text(value)
                .font(Theme.Fonts.bodyBold)
                .foregroundColor(Theme.Colors.text)
            
            Text(label)
                .font(Theme.Fonts.caption)
                .foregroundColor(Theme.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WorkoutReviewView()
}
