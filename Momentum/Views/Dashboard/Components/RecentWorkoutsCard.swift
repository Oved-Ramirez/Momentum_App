//
//  RecentWorkoutsCard.swift
//  Momentum
//  Displays recent workout history
//
//  Created by Oved Ramirez on 1/20/26.
//

import SwiftUI

struct RecentWorkoutsCard: View {
    let workouts: [Workout]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header
            HStack {
                Text("Recent Workouts")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.text)
                
                Spacer()
                
                if !workouts.isEmpty {
                    Text("See All")
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            
            // Workouts list
            if workouts.isEmpty {
                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Text("No workouts yet")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Text("Start logging your workouts!")
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.lg)
            } else {
                VStack(spacing: Theme.Spacing.sm) {
                    ForEach(workouts.prefix(5)) { workout in
                        WorkoutRow(workout: workout)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Workout icon
            Image(systemName: iconForWorkout(workout.type))
                .font(.system(size: 24))
                .foregroundColor(colorForWorkout(workout.type))
                .frame(width: 40, height: 40)
                .background(colorForWorkout(workout.type).opacity(0.1))
                .clipShape(Circle())
            
            // Workout info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type.rawValue)
                    .font(Theme.Fonts.bodyBold)
                    .foregroundColor(Theme.Colors.text)
                
                HStack(spacing: Theme.Spacing.xs) {
                    // Date
                    Text(workout.date, style: .date)
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Text("•")
                        .foregroundColor(Theme.Colors.tertiaryText)
                    
                    // Duration
                    Text(workout.durationFormatted)
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            Spacer()
            
            // Calories (if available)
            if let calories = workout.calories {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(calories)")
                        .font(Theme.Fonts.bodyBold)
                        .foregroundColor(Theme.Colors.streakFire)
                    
                    Text("cal")
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
    
    private func iconForWorkout(_ type: WorkoutType) -> String {
        switch type {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .hiit: return "flame.fill"
        case .yoga: return "figure.yoga"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .walking: return "figure.walk"
        case .swimming: return "figure.pool.swim"
        default: return "figure.walk"
        }
    }
    
    private func colorForWorkout(_ type: WorkoutType) -> Color {
        switch type {
        case .strength: return Theme.Colors.strength
        case .cardio: return Theme.Colors.cardio
        case .running: return Theme.Colors.cardio
        case .yoga: return Theme.Colors.yoga
        case .hiit: return Theme.Colors.hiit
        default: return Theme.Colors.primary
        }
    }
}

#Preview {
    VStack {
        RecentWorkoutsCard(workouts: [
            Workout(type: .running, duration: 1800, calories: 250),
            Workout(type: .strength, duration: 2400, calories: 180),
            Workout(type: .yoga, duration: 3600)
        ])
        
        RecentWorkoutsCard(workouts: [])
    }
    .padding()
}
