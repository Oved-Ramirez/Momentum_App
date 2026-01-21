//
//  MetricsCard.swift
//  Momentum
// Displays individual health metric (steps, calories, etc.)
//
//  Created by Oved Ramirez on 1/20/26.
//

import SwiftUI

struct MetricsCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let progress: Double?
    
    init(icon: String, title: String, value: String, color: Color, progress: Double? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
        self.progress = progress
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: Theme.Sizes.iconLarge))
                .foregroundColor(color)
            
            Spacer()
            
            // Value
            Text(value)
                .font(Theme.Fonts.metricMedium)
                .foregroundColor(Theme.Colors.text)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Title
            Text(title)
                .font(Theme.Fonts.caption)
                .foregroundColor(Theme.Colors.secondaryText)
            
            // Optional progress bar
            if let progress = progress {
                ProgressView(value: progress)
                    .tint(color)
                    .scaleEffect(x: 1, y: 0.5)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

struct MetricsGrid: View {
    let metrics: HealthMetrics?
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
            // Steps
            MetricsCard(
                icon: "figure.walk",
                title: "Steps",
                value: metrics?.steps.formatted() ?? "0",
                color: Theme.Colors.primary,
                progress: calculateStepProgress()
            )
            
            // Calories
            MetricsCard(
                icon: "flame.fill",
                title: "Calories",
                value: "\(metrics?.activeCalories ?? 0)",
                color: Theme.Colors.streakFire
            )
            
            // Distance
            MetricsCard(
                icon: "location.fill",
                title: "Distance",
                value: {
                    if let metrics = metrics {
                        return String(format: "%.1f mi", metrics.distance)
                    } else {
                        return "0.0 mi"
                    }
                }(),
                color: Theme.Colors.success
            )
            
            // Active Minutes
            MetricsCard(
                icon: "clock.fill",
                title: "Active",
                value: "\(metrics?.activeMinutes ?? 0) min",
                color: Theme.Colors.secondary
            )
        }
    }
    
    private func calculateStepProgress() -> Double {
        guard let steps = metrics?.steps else { return 0 }
        let goal = 10000.0
        return min(Double(steps) / goal, 1.0)
    }
}

#Preview {
    VStack {
        MetricsCard(
            icon: "figure.walk",
            title: "Steps",
            value: "8,432",
            color: .blue,
            progress: 0.84
        )
        
        MetricsGrid(
            metrics: HealthMetrics(
                steps: 8432,
                distance: 3.8,
                activeCalories: 420,
                totalCalories: 1850,
                activeMinutes: 45
            )
        )
    }
    .padding()
}
