//
//  MomentumApp.swift
//  Momentum
//
//  Created by Oved Ramirez on 11/20/25.
//

import SwiftUI
import SwiftData

@main
struct MomentumApp: App {

    // Initialize services
    @State private var dataStore = DataStore.shared
    @State private var healthKitManager = HealthKitManager.shared

    // Track app lifecycle
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataStore)
                .environment(healthKitManager)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
        }
    }

    // MARK: - Scene Phase Handling

    private func handleScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // App became active (opened or came back from background)
            print("🟢 App became active")
            
            // Only sync if we were in background (not on first launch)
            if oldPhase == .background {
                print("🔄 Returning from background - syncing...")
                Task {
                    try? await healthKitManager.syncTodayMetrics()
                }
            }
            
        case .background:
            print("🔵 App entered background")
            
        case .inactive:
            print("⚪️ App became inactive (but not background yet)")
            
        @unknown default:
            break
        }
    }
}
