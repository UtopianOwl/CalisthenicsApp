//
//  ResetService.swift
//  CalisthenicsTracker
//
//  Created on: April 25, 2025
//

import Foundation
import BackgroundTasks
import UserNotifications

/// A service specifically for managing the 4am reset functionality
class ResetService {
    /// Shared singleton instance
    static let shared = ResetService()
    
    /// Background task identifier for the daily reset
    private let resetTaskIdentifier = "com.calisthenicsTracker.dailyReset"
    
    /// Timer for checking if exercises need to be reset when app is running
    private var resetTimer: Timer?
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Sets up the reset service with both background tasks and foreground timer
    func setupResetService() {
        // Register for background tasks
        registerBackgroundTasks()
        
        // Schedule the next background task
        scheduleBackgroundReset()
        
        // Set up foreground timer as a fallback
        setupResetTimer()
    }
    
    /// Registers background tasks with the system
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: resetTaskIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundReset(task: task)
        }
    }
    
    /// Schedules the next background reset task
    func scheduleBackgroundReset() {
        let request = BGAppRefreshTaskRequest(identifier: resetTaskIdentifier)
        
        // Set the earliest begin date to 4am tomorrow
        request.earliestBeginDate = getNext4AM()
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background reset: \(error.localizedDescription)")
        }
    }
    
    /// Handles the background reset task execution
    /// - Parameter task: The background task
    private func handleBackgroundReset(task: BGTask) {
        // Schedule the next reset before doing anything else
        scheduleBackgroundReset()
        
        // Create a task to perform the reset
        Task {
            await performDailyReset()
            task.setTaskCompleted(success: true)
        }
    }
    
    /// Sets up a timer to check for resets at regular intervals when app is in foreground
    private func setupResetTimer() {
        // Invalidate any existing timer
        resetTimer?.invalidate()
        
        // Check every minute if we need to reset
        resetTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkForReset()
        }
        
        // Also check immediately on startup
        checkForReset()
    }
    
    /// Checks if exercises should be reset based on the current time
    private func checkForReset() {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the current hour in 24-hour format
        let hour = calendar.component(.hour, from: now)
        
        // If it's 4am, reset all exercises that were completed yesterday or earlier
        if hour == 4 {
            Task {
                await performDailyReset()
            }
        }
    }
    
    /// Performs the daily reset of exercises
    @MainActor
    func performDailyReset() async {
        // Load exercises from persistence
        guard var exercises = DataPersistenceService.shared.loadExercises() else {
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var didReset = false
        
        // Reset completion status for exercises completed before today
        for i in 0..<exercises.count {
            if exercises[i].isCompleted,
               let completionDate = exercises[i].lastCompletedDate,
               calendar.startOfDay(for: completionDate) < today {
                exercises[i].resetCompletionStatus()
                didReset = true
            }
        }
        
        // Save changes if any exercises were reset
        if didReset {
            DataPersistenceService.shared.saveExercises(exercises)
            
            // Optionally notify the user about the reset
            scheduleResetNotification()
        }
    }
    
    /// Manually triggers a reset of all exercises (for testing purposes)
    @MainActor
    func manualReset() async {
        guard var exercises = DataPersistenceService.shared.loadExercises() else {
            return
        }
        
        // Reset all exercises
        for i in 0..<exercises.count {
            exercises[i].resetCompletionStatus()
        }
        
        // Save changes
        DataPersistenceService.shared.saveExercises(exercises)
    }
    
    /// Calculates the next 4am time
    /// - Returns: Date representing the next occurrence of 4am
    private func getNext4AM() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 4
        components.minute = 0
        components.second = 0
        
        // Get 4am today
        guard let fourAM = calendar.date(from: components) else {
            return Date()
        }
        
        // If it's already past 4am, get 4am tomorrow
        if Date() >= fourAM {
            return calendar.date(byAdding: .day, value: 1, to: fourAM) ?? Date()
        }
        
        return fourAM
    }
    
    /// Schedules a local notification to inform the user about the reset
    private func scheduleResetNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Exercises Reset"
        content.body = "Your daily exercises have been reset. Ready for a new day!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Cleans up resources when the service is no longer needed
    func cleanup() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
}