//
//  Theme.swift
//  Momentum
//  Design system: colors, fonts, spacing, and styling
//
//  Created by Oved Ramirez on 11/21/25.
//

import UIKit
import SwiftUI

struct Theme {
    
    // MARK: - Colors
    
    struct Colors {
        // Primary brand colors - Vibrant and high contrast
        static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // Bright blue
        static let secondary = Color(red: 0.55, green: 0.27, blue: 0.91) // Purple
        static let accent = Color(red: 1.0, green: 0.35, blue: 0.0) // Orange
        
        // Semantic colors
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35) // Green
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0) // Orange
        static let error = Color(red: 1.0, green: 0.23, blue: 0.19) // Red
        static let info = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
        
        // Background colors (adapts to dark/light mode)
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
        
        // Text colors (adapts to dark/light mode)
        static let text = Color(uiColor: .label)
        static let secondaryText = Color(uiColor: .secondaryLabel)
        static let tertiaryText = Color(uiColor: .tertiaryLabel)
        
        // Card colors
        static let cardBackground = Color(uiColor: .secondarySystemBackground)
        static let cardBorder = Color(uiColor: .separator)
        
        // Category colors (for tasks, workouts, etc.)
        static let fitness = Color(red: 0.0, green: 0.48, blue: 1.0) // Blue
        static let nutrition = Color(red: 0.2, green: 0.78, blue: 0.35) // Green
        static let wellness = Color(red: 1.0, green: 0.18, blue: 0.33) // Pink
        static let hydration = Color(red: 0.0, green: 0.78, blue: 0.75) // Cyan
        static let sleep = Color(red: 0.55, green: 0.27, blue: 0.91) // Purple
        static let mindfulness = Color(red: 0.35, green: 0.34, blue: 0.84) // Indigo
        
        // Workout type colors
        static let strength = Color(red: 1.0, green: 0.23, blue: 0.19) // Red
        static let cardio = Color(red: 1.0, green: 0.35, blue: 0.0) // Orange
        static let yoga = Color(red: 0.55, green: 0.27, blue: 0.91) // Purple
        static let hiit = Color(red: 1.0, green: 0.18, blue: 0.33) // Pink
        
        // Streak colors
        static let streakFire = Color(red: 1.0, green: 0.35, blue: 0.0) // Orange
        static let streakGold = Color(red: 1.0, green: 0.8, blue: 0.0) // Gold
    }
    
    // MARK: - Typography
    
    struct Fonts {
        // Headlines
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // Body text
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        
        // Small text
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        
        // Numbers (for metrics)
        static let metricLarge = Font.system(size: 48, weight: .bold, design: .rounded)
        static let metricMedium = Font.system(size: 32, weight: .bold, design: .rounded)
        static let metricSmall = Font.system(size: 24, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // Specific use cases
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 12
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let circle: CGFloat = 999
    }
    
    // MARK: - Shadows
    
    struct Shadows {
        static let card = Shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 2
        )
        
        static let button = Shadow(
            color: Color.black.opacity(0.15),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let floating = Shadow(
            color: Color.black.opacity(0.2),
            radius: 12,
            x: 0,
            y: 4
        )
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Animations
    
    struct Animations {
        static let quick = Animation.easeInOut(duration: 0.2)
        static let standard = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)
        static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
    
    // MARK: - Sizes
    
    struct Sizes {
        // Icons
        static let iconSmall: CGFloat = 16
        static let iconMedium: CGFloat = 24
        static let iconLarge: CGFloat = 32
        static let iconXL: CGFloat = 48
        
        // Buttons
        static let buttonHeight: CGFloat = 50
        static let smallButtonHeight: CGFloat = 40
        
        // Cards
        static let cardMinHeight: CGFloat = 80
        
        // Images
        static let thumbnailSize: CGFloat = 60
        static let avatarSize: CGFloat = 80
    }
}

// MARK: - View Extensions for Easy Styling

extension View {
    // Card styling
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y
            )
    }
    
    // Primary button styling - NOW WITH VIBRANT BLUE
    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Sizes.buttonHeight)
            .background(
                LinearGradient(
                    colors: [Theme.Colors.primary, Theme.Colors.primary.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Colors.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    // Secondary button styling
    func secondaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Sizes.buttonHeight)
            .background(Theme.Colors.cardBackground)
            .foregroundColor(Theme.Colors.primary)
            .fontWeight(.semibold)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1.5)
            )
    }
    
    // Section styling
    func sectionStyle() -> some View {
        self
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
    }
}

// MARK: - SF Symbols Icons (Commonly Used)

extension Theme {
    struct Icons {
        // Navigation
        static let home = "house.fill"
        static let fitness = "figure.strengthtraining.traditional"
        static let cardio = "figure.run"
        static let meals = "fork.knife"
        static let profile = "person.fill"
        
        // Actions
        static let add = "plus.circle.fill"
        static let edit = "pencil"
        static let delete = "trash"
        static let checkmark = "checkmark.circle.fill"
        static let close = "xmark"
        
        // Metrics
        static let steps = "figure.walk"
        static let calories = "flame.fill"
        static let distance = "location.fill"
        static let heartRate = "heart.fill"
        static let time = "clock.fill"
        
        // Streak
        static let fire = "flame.fill"
        static let star = "star.fill"
        static let trophy = "trophy.fill"
        
        // Workout types
        static let strength = "dumbbell.fill"
        static let running = "figure.run"
        static let cycling = "bicycle"
        static let yoga = "figure.yoga"
        static let swimming = "figure.pool.swim"
        
        // Other
        static let settings = "gear"
        static let sync = "arrow.triangle.2.circlepath"
        static let chart = "chart.bar.fill"
        static let calendar = "calendar"
    }
}
