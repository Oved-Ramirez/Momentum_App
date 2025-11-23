//
//  OnboardingCompleteView.swift
//  Momentum
//  Onboarding completion celebration screen
//
//  Created by Oved Ramirez on 11/23/25.
//

import SwiftUI

struct OnboardingCompleteView: View {
    var viewModel: OnboardingViewModel
    @State private var isAnimated = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Celebration icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.primary, Theme.Colors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimated ? 1 : 0.5)
                    .opacity(isAnimated ? 1 : 0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimated ? 1 : 0.5)
                    .opacity(isAnimated ? 1 : 0)
            }
            .padding(.bottom, Theme.Spacing.lg)
            
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text(viewModel.currentStep.title)
                    .font(Theme.Fonts.title)
                    .foregroundColor(Theme.Colors.text)
                    .opacity(isAnimated ? 1 : 0)
                    .offset(y: isAnimated ? 0 : 20)
                
                Text("Welcome to Momentum, \(viewModel.userName)!")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .opacity(isAnimated ? 1 : 0)
                    .offset(y: isAnimated ? 0 : 20)
            }
            
            Spacer()
            
            // Quick tips
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Quick Tips:")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.text)
                
                TipRow(
                    icon: "flame.fill",
                    text: "Build your streak by staying active daily"
                )
                .opacity(isAnimated ? 1 : 0)
                .offset(x: isAnimated ? 0 : -20)
                
                TipRow(
                    icon: "checkmark.circle.fill",
                    text: "Complete daily tasks to stay on track"
                )
                .opacity(isAnimated ? 1 : 0)
                .offset(x: isAnimated ? 0 : -20)
                
                TipRow(
                    icon: "figure.run",
                    text: "Log workouts or sync from Apple Health"
                )
                .opacity(isAnimated ? 1 : 0)
                .offset(x: isAnimated ? 0 : -20)
            }
            .padding(.horizontal, Theme.Spacing.md)
            
            Spacer()
            
            // Start button
            Button {
                viewModel.completeOnboarding()
            } label: {
                HStack {
                    Text("Start Tracking")
                        .font(Theme.Fonts.bodyBold)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: Theme.Sizes.iconSmall, weight: .bold))
                }
                .frame(maxWidth: .infinity)
            }
            .primaryButtonStyle()
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.lg)
            .opacity(isAnimated ? 1 : 0)
            .offset(y: isAnimated ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                isAnimated = true
            }
        }
    }
}

struct TipRow: View {
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
    OnboardingCompleteView(viewModel: OnboardingViewModel())
}
