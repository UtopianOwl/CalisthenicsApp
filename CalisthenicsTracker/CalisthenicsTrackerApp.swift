//
//  CalisthenicsTrackerApp.swift
//  CalisthenicsTracker
//
//  Created on: April 25, 2025
//

import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct CalisthenicsTrackerApp: App {
    // Initialize app-level services
    @StateObject private var exerciseStore = ExerciseStore()
    
    // App lifecycle management
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Request notification permissions
        requestNotificationPermissions()
        
        // Set up the reset service
        ResetService.shared.setupResetService()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(exerciseStore)
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    /// Requests permission to send notifications to the user
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    /// Handles app lifecycle changes
    /// - Parameter newPhase: The new scene phase
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // App became active, check if we need to reset exercises
            exerciseStore.resetExercisesIfNeeded()
            
            // Schedule background tasks
            ResetService.shared.scheduleBackgroundReset()
            
        case .background:
            // App went to background, ensure data is saved
            if let exercises = exerciseStore.exercises as? [Exercise] {
                DataPersistenceService.shared.saveExercises(exercises)
            }
            
        case .inactive:
            // App is transitioning between states
            break
            
        @unknown default:
            break
        }
    }
}