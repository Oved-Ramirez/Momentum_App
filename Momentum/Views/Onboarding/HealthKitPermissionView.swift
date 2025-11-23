//
//  HealthKitPermissionView.swift
//  Momentum
//  HealthKit permission request screen
//
//  Created by Oved Ramirez on 11/23/25.
//

import SwiftUI

struct HealthKitPermissionView: View {
    var viewModel: OnboardingViewModel
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text(viewModel.currentStep.title)
                    .font(Theme.Fonts.title)
                    .foregroundColor(Theme.Colors.text)
                
                Text("Automatically track your fitness data")
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
            
            Spacer()
            
            // What we sync
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("What we'll sync:")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.text)
                    .padding(.horizontal, Theme.Spacing.md)
                
                PermissionItem(
                    icon: "figure.walk",
                    title: "Steps & Distance",
                    description: "Automatically tracked",
                    color: .blue
                )
                
                PermissionItem(
                    icon: "flame.fill",
                    title: "Calories Burned",
                    description: "Automatically tracked",
                    color: .orange
                )
                
                PermissionItem(
                    icon: "heart.fill",
                    title: "Heart Rate",
                    description: "Optional data",
                    color: .red
                )
                
                PermissionItem(
                    icon: "figure.run",
                    title: "Workouts",
                    description: "Review before adding",
                    color: .green
                )
            }
            .padding(.horizontal, Theme.Spacing.md)
            
            Spacer()
            
            // Buttons
            VStack(spacing: Theme.Spacing.md) {
                Button {
                    isRequesting = true
                    Task {
                        await viewModel.requestHealthKitPermission()
                        isRequesting = false
                        viewModel.nextStep()
                    }
                } label: {
                    if isRequesting {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Enable Health Sync")
                            .font(Theme.Fonts.bodyBold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .primaryButtonStyle()
                .disabled(isRequesting)
                
                Button {
                    viewModel.skipHealthKit()
                } label: {
                    Text("Skip for Now")
                        .font(Theme.Fonts.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                .padding(.vertical, Theme.Spacing.sm)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.lg)
        }
    }
}

struct PermissionItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: Theme.Sizes.iconMedium))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Fonts.bodyBold)
                    .foregroundColor(Theme.Colors.text)
                
                Text(description)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

#Preview {
    HealthKitPermissionView(viewModel: OnboardingViewModel())
}
