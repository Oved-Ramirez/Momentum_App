//
//  GoalsView.swift
//  Momentum
//  Goal selection screen for onboarding
//
//  Created by Oved Ramirez on 11/23/25.
//

import SwiftUI

struct GoalsView: View {
    var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text(viewModel.currentStep.title)
                    .font(Theme.Fonts.title)
                    .foregroundColor(Theme.Colors.text)
                
                Text("Select your primary goal")
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .padding(.top, Theme.Spacing.xl)
            
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    // Primary goal selection
                    ForEach(FitnessGoal.allCases, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: viewModel.selectedPrimaryGoal == goal
                        ) {
                            withAnimation(Theme.Animations.quick) {
                                viewModel.selectedPrimaryGoal = goal
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

struct GoalCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                Image(systemName: iconForGoal(goal))
                    .font(.system(size: Theme.Sizes.iconLarge))
                    .foregroundColor(isSelected ? .white : Theme.Colors.primary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Theme.Colors.primary : Theme.Colors.primary.opacity(0.1))
                    )
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(Theme.Fonts.bodyBold)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text(descriptionForGoal(goal))
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: Theme.Sizes.iconMedium))
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
    
    func iconForGoal(_ goal: FitnessGoal) -> String {
        switch goal {
        case .loseWeight: return "arrow.down.circle.fill"
        case .buildMuscle: return "dumbbell.fill"
        case .maintenance: return "heart.fill"
        case .improveEndurance: return "figure.run"
        case .increaseStrength: return "flame.fill"
        case .flexibility: return "figure.yoga"
        }
    }
    
    func descriptionForGoal(_ goal: FitnessGoal) -> String {
        switch goal {
        case .loseWeight: return "Shed pounds and get lean"
        case .buildMuscle: return "Gain strength and size"
        case .maintenance: return "Stay healthy and active"
        case .improveEndurance: return "Run faster, go longer"
        case .increaseStrength: return "Lift heavier weights"
        case .flexibility: return "Increase mobility"
        }
    }
}

#Preview {
    GoalsView(viewModel: OnboardingViewModel())
}
