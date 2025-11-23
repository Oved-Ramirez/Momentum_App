//
//  HabitsView.swift
//  Momentum
//  Activity habits screen for onboarding
//
//  Created by Oved Ramirez on 11/23/25.
//

import SwiftUI

struct HabitsView: View {
    var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text(viewModel.currentStep.title)
                    .font(Theme.Fonts.title)
                    .foregroundColor(Theme.Colors.text)
                
                Text("Help us personalize your experience")
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .padding(.top, Theme.Spacing.xl)
            
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Activity Level Section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Current Activity Level")
                            .font(Theme.Fonts.title3)
                            .foregroundColor(Theme.Colors.text)
                        
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            ActivityLevelCard(
                                level: level,
                                isSelected: viewModel.activityLevel == level
                            ) {
                                withAnimation(Theme.Animations.quick) {
                                    viewModel.activityLevel = level
                                }
                            }
                        }
                    }
                    
                    // Workout Frequency Section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Workouts per Week")
                            .font(Theme.Fonts.title3)
                            .foregroundColor(Theme.Colors.text)
                        
                        HStack {
                            Text("\(viewModel.workoutFrequency)")
                                .font(Theme.Fonts.metricMedium)
                                .foregroundColor(Theme.Colors.primary)
                                .frame(width: 60)
                            
                            Slider(
                                value: Binding(
                                    get: { Double(viewModel.workoutFrequency) },
                                    set: { viewModel.workoutFrequency = Int($0) }
                                ),
                                in: 0...7,
                                step: 1
                            )
                            .tint(Theme.Colors.primary)
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                    
                    // Preferred Workout Types
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Favorite Workout Types")
                            .font(Theme.Fonts.title3)
                            .foregroundColor(Theme.Colors.text)
                        
                        Text("Select all that apply")
                            .font(Theme.Fonts.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.sm) {
                            ForEach([WorkoutType.strength, .cardio, .hiit, .yoga, .running, .cycling], id: \.self) { type in
                                WorkoutTypeChip(
                                    type: type,
                                    isSelected: viewModel.selectedWorkoutTypes.contains(type)
                                ) {
                                    if viewModel.selectedWorkoutTypes.contains(type) {
                                        viewModel.selectedWorkoutTypes.remove(type)
                                    } else {
                                        viewModel.selectedWorkoutTypes.insert(type)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
            
            // Navigation buttons
            HStack(spacing: Theme.Spacing.md) {
                Button {
                    viewModel.previousStep()
                } label: {
                    Text("Back")
                        .font(Theme.Fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                }
                .secondaryButtonStyle()
                
                Button {
                    viewModel.nextStep()
                } label: {
                    Text("Continue")
                        .font(Theme.Fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.lg)
        }
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(Theme.Fonts.bodyBold)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text(descriptionForLevel(level))
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
    
    func descriptionForLevel(_ level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return "Little to no exercise"
        case .light: return "1-2 days per week"
        case .moderate: return "3-4 days per week"
        case .veryActive: return "5-6 days per week"
        case .extreme: return "Daily intense training"
        }
    }
}

struct WorkoutTypeChip: View {
    let type: WorkoutType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForType(type))
                    .font(.system(size: Theme.Sizes.iconSmall))
                
                Text(type.rawValue)
                    .font(Theme.Fonts.caption)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? Theme.Colors.primary : Theme.Colors.cardBackground)
            .foregroundColor(isSelected ? .white : Theme.Colors.text)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
    
    func iconForType(_ type: WorkoutType) -> String {
        switch type {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .hiit: return "flame.fill"
        case .yoga: return "figure.yoga"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        default: return "figure.walk"
        }
    }
}

#Preview {
    HabitsView(viewModel: OnboardingViewModel())
}
