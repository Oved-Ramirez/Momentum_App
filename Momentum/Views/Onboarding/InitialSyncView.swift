//
//  InitialSyncView.swift
//  Momentum
//  Initial HealthKit sync screen
//
//  Created by Oved Ramirez on 11/23/25.
//

import SwiftUI

struct InitialSyncView: View {
    var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Animated sync icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.Colors.primary)
                    .rotationEffect(.degrees(viewModel.syncProgress * 360))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: viewModel.syncProgress)
            }
            .padding(.bottom, Theme.Spacing.lg)
            
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text(viewModel.currentStep.title)
                    .font(Theme.Fonts.title)
                    .foregroundColor(Theme.Colors.text)
                
                if viewModel.isInitialSyncComplete {
                    Text("Sync complete!")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.success)
                } else {
                    Text("This will only take a moment...")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            // Progress bar
            VStack(spacing: Theme.Spacing.sm) {
                ProgressView(value: viewModel.syncProgress)
                    .tint(Theme.Colors.primary)
                    .frame(maxWidth: 200)
                
                Text("\(Int(viewModel.syncProgress * 100))%")
                    .font(Theme.Fonts.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            // Continue button (appears when complete)
            if viewModel.isInitialSyncComplete {
                Button {
                    viewModel.nextStep()
                } label: {
                    Text("Continue")
                        .font(Theme.Fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.lg)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .task {
            if !viewModel.isInitialSyncComplete {
                await viewModel.performInitialSync()
            }
        }
    }
}

#Preview {
    InitialSyncView(viewModel: OnboardingViewModel())
}
