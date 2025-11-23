//
//  OnboardingContainerView.swift
//  Momentum
//  Container for the onboarding flow
//
//  Created by Oved Ramirez on 11/23/25.
//

import Foundation
import SwiftUI

struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Theme.Colors.primary.opacity(0.1), Theme.Colors.secondary.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .welcome && viewModel.currentStep != .complete {
                    ProgressView(value: viewModel.currentStep.progress)
                        .tint(Theme.Colors.primary)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.top, Theme.Spacing.sm)
                }
                
                // Current step view
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeView(viewModel: viewModel)
                    case .goals:
                        GoalsView(viewModel: viewModel)
                    case .habits:
                        HabitsView(viewModel: viewModel)
                    case .bodyStats:
                        BodyStatsView(viewModel: viewModel)
                    case .healthKitPermission:
                        HealthKitPermissionView(viewModel: viewModel)
                    case .initialSync:
                        InitialSyncView(viewModel: viewModel)
                    case .complete:
                        OnboardingCompleteView(viewModel: viewModel)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .onChange(of: viewModel.isOnboardingComplete) { _, isComplete in
            if isComplete {
                dismiss()
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
}
