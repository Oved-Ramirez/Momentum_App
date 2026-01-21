//
//  DashboardView.swift
//  Momentum
//
//  Main dashboard home screen
//  Created by Oved Ramirez on 1/20/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingWorkoutReview = false
    @State private var showingDebugInfo = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Greeting header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.greetingMessage)
                                .font(Theme.Fonts.title2)
                                .foregroundColor(Theme.Colors.text)
                            
                            if let lastSync = viewModel.healthMetrics?.lastSynced {
                                Text("Updated \(lastSync, style: .relative)")
                                    .font(Theme.Fonts.caption)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.sm)
                    
                    // Debug Info Card (if enabled)
                    if showingDebugInfo {
                        DebugInfoCard(viewModel: viewModel)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Streak Card
                    StreakCard(streak: viewModel.streak)
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    // Daily Tasks Card
                    DailyTasksCard(
                        tasks: viewModel.todayTasks,
                        onToggle: { task in
                            viewModel.toggleTask(task)
                        }
                    )
                    .padding(.horizontal, Theme.Spacing.md)
                    
                    // Metrics Grid
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Today's Activity")
                            .font(Theme.Fonts.title3)
                            .foregroundColor(Theme.Colors.text)
                            .padding(.horizontal, Theme.Spacing.md)
                        
                        MetricsGrid(metrics: viewModel.healthMetrics)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    // Recent Workouts
                    RecentWorkoutsCard(workouts: viewModel.recentWorkouts)
                        .padding(.horizontal, Theme.Spacing.md)
                    
                    // Bottom spacing
                    Color.clear.frame(height: Theme.Spacing.lg)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Theme.Colors.background.opacity(0.8))
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Debug button (left side)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingDebugInfo.toggle()
                    } label: {
                        Image(systemName: showingDebugInfo ? "ladybug.fill" : "ladybug")
                            .foregroundColor(showingDebugInfo ? .red : .primary)
                    }
                }
                
                // Manual sync button (left-middle)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task {
                            await performManualSync()
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
                
                // Workout review button (right side)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingWorkoutReview = true
                    } label: {
                        Image(systemName: "figure.run.circle")
                    }
                }
            }
            .task {
                await viewModel.loadDashboardData()
            }
            .sheet(isPresented: $showingWorkoutReview) {
                WorkoutReviewView(onWorkoutsChanged: {
                    Task {
                        await viewModel.loadDashboardData()
                    }
                })
            }
        }
    }
    
    // MARK: - Manual Sync Function
    
    private func performManualSync() async {
        print("🔄 Manual sync triggered")
        await viewModel.refresh()
        print("✅ Manual sync complete")
    }
}

// MARK: - Debug Info Card

struct DebugInfoCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("🐛 Debug Info")
                .font(Theme.Fonts.title3)
                .foregroundColor(.red)
            
            Divider()
            
            Group {
                DebugRow(label: "HealthKit Auth", value: "\(HealthKitManager.shared.isAuthorized)")
                DebugRow(label: "Steps", value: "\(viewModel.healthMetrics?.steps ?? 0)")
                DebugRow(label: "Calories", value: "\(viewModel.healthMetrics?.activeCalories ?? 0)")
                DebugRow(label: "Distance", value: String(format: "%.2f mi", viewModel.healthMetrics?.distance ?? 0))
                DebugRow(label: "Last Synced", value: viewModel.healthMetrics?.lastSynced.formatted(date: .omitted, time: .shortened) ?? "Never")
                
                Divider()
                
                DebugRow(label: "Streak", value: "\(viewModel.streak.currentStreak) days")
                DebugRow(label: "Tasks", value: "\(viewModel.todayTasks.count)")
                DebugRow(label: "Workouts", value: "\(viewModel.recentWorkouts.count)")
                
                Divider()
                
                DebugRow(label: "Loading", value: "\(viewModel.isLoading)")
                DebugRow(label: "Error", value: viewModel.errorMessage ?? "None")
            }
            
            // Test buttons
            HStack(spacing: Theme.Spacing.sm) {
                Button("Force Sync") {
                    Task {
                        await testHealthKitSync()
                    }
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(6)
                
                Button("Load Data") {
                    Task {
                        await viewModel.loadDashboardData()
                    }
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.Colors.success)
                .foregroundColor(.white)
                .cornerRadius(6)
                
                Button("Check DB") {
                    checkDatabase()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.Colors.warning)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.red.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Color.red, lineWidth: 2)
        )
    }
    
    // MARK: - Debug Test Functions
    
    private func testHealthKitSync() async {
        print("\n🔍 ===== DEBUG: FORCE SYNC TEST =====")
        
        do {
            // Test HealthKit sync
            let metrics = try await HealthKitManager.shared.syncTodayMetrics()
            
            print("✅ HealthKit returned:")
            print("   - Steps: \(metrics.steps)")
            print("   - Calories: \(metrics.activeCalories)")
            print("   - Distance: \(metrics.distance)")
            
            // Check what's in DataStore
            if let stored = try? DataStore.shared.fetchTodayHealthMetrics() {
                print("✅ DataStore has:")
                print("   - Steps: \(stored.steps)")
                print("   - Calories: \(stored.activeCalories)")
            } else {
                print("❌ No data in DataStore")
            }
            
            // Reload dashboard
            await viewModel.loadDashboardData()
            
            print("✅ ViewModel now shows:")
            print("   - Steps: \(viewModel.healthMetrics?.steps ?? 0)")
            print("   - Calories: \(viewModel.healthMetrics?.activeCalories ?? 0)")
            
        } catch {
            print("❌ Sync error: \(error)")
        }
        
        print("===== DEBUG TEST COMPLETE =====\n")
    }
    
    private func checkDatabase() {
        print("\n🔍 ===== DEBUG: DATABASE CHECK =====")
        
        do {
            // Check workouts
            let workouts = try DataStore.shared.fetchWorkouts(limit: 10)
            print("📊 Workouts in DB: \(workouts.count)")
            for (index, workout) in workouts.enumerated() {
                print("   \(index + 1). \(workout.type.rawValue) - \(workout.date.formatted(date: .abbreviated, time: .shortened))")
            }
            
            // Check tasks
            let tasks = try DataStore.shared.fetchTasksForToday()
            print("✅ Tasks in DB: \(tasks.count)")
            
            // Check health metrics
            if let metrics = try DataStore.shared.fetchTodayHealthMetrics() {
                print("📊 Today's metrics in DB:")
                print("   - Steps: \(metrics.steps)")
                print("   - Calories: \(metrics.activeCalories)")
            } else {
                print("❌ No metrics in DB for today")
            }
            
        } catch {
            print("❌ Database error: \(error)")
        }
        
        print("===== DATABASE CHECK COMPLETE =====\n")
    }
}

struct DebugRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .bold()
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    DashboardView()
}
