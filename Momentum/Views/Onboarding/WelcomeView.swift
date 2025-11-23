//
//  WelcomeView.swift
//  Momentum
//  Welcome screen for onboarding
//
//  Created by Oved Ramirez on 11/23/25.
//

import SwiftUI

struct WelcomeView: View {
    var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // App icon or hero image
            Image(systemName: "flame.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.primary, Theme.Colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, Theme.Spacing.lg)
            
            // Title
            Text("Welcome to")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text("Momentum")
                .font(Theme.Fonts.largeTitle)
                .foregroundColor(Theme.Colors.text)
                .bold()
            
            // Tagline
            Text("Your all-in-one fitness companion")
                .font(Theme.Fonts.title3)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
            
            Spacer()
            
            // Features list
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                FeatureRow(icon: "figure.run", text: "Track workouts and cardio")
                FeatureRow(icon: "fork.knife", text: "Log meals and nutrition")
                FeatureRow(icon: "flame.fill", text: "Build daily streaks")
                FeatureRow(icon: "heart.fill", text: "Sync with Apple Health")
            }
            .padding(.horizontal, Theme.Spacing.xl)
            
            Spacer()
            
            // Get Started button
            Button {
                viewModel.nextStep()
            } label: {
                Text("Get Started")
                    .font(Theme.Fonts.bodyBold)
                    .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.lg)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: Theme.Sizes.iconMedium))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 30)
            
            Text(text)
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.text)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView(viewModel: OnboardingViewModel())
}
