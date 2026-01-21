//
//  StreakCard.swift
//  Momentum
//
// Displays user's current streak
//
//Created by Oved Ramirez on 1/20/26.


import SwiftUI

struct StreakCard: View {
    let streak: Streak
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                // Fire icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.streakFire, Theme.Colors.streakGold],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Spacer()
                
                // Streak number
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(streak.currentStreak)")
                        .font(Theme.Fonts.metricLarge)
                        .foregroundColor(Theme.Colors.text)
                        .bold()
                    
                    Text("day streak")
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            // Motivational message
            Text(streak.motivationalMessage)
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Longest streak (if different from current)
            if streak.longestStreak > streak.currentStreak && streak.longestStreak > 0 {
                Divider()
                
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(Theme.Colors.streakGold)
                    
                    Text("Longest streak: \(streak.longestStreak) days")
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Spacer()
                }
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakCard(streak: Streak(currentStreak: 7, longestStreak: 14))
        StreakCard(streak: Streak(currentStreak: 1, longestStreak: 1))
        StreakCard(streak: Streak(currentStreak: 30, longestStreak: 30))
    }
    .padding()
}
