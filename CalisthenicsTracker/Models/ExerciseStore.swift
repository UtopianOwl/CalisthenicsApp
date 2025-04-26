//
//  ExerciseStore.swift
//  CalisthenicsTracker
//
//  Created on: April 25, 2025
//

import Foundation
import Combine

/// Manages the collection of exercises and handles persistence, progression, and reset functionality
class ExerciseStore: ObservableObject {
    /// Published collection of exercises that will notify observers when changed
    @Published var exercises: [Exercise]
    
    /// Key used for storing exercises in UserDefaults
    private let storeKey = "com.calisthenicsTracker.exercises"
    
    /// Timer for checking if exercises need to be reset
    private var resetTimer: Timer?
    
    /// Initializes the exercise store with default exercises or loads from persistence
    init() {
        // Try to load exercises from UserDefaults
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let savedExercises = try? JSONDecoder().decode([Exercise].self, from: data) {
            self.exercises = savedExercises
        } else {
            // Create default exercises if none are saved
            self.exercises = [
                .pushUps(),
                .pullUps(),
                .crow(),
                .handstand(),
                .leverPulls(),
                .frontLever()
            ]
        }
        
        // Start the reset timer
        setupResetTimer()
    }
    
    /// Saves the current exercises to UserDefaults
    private func saveExercises() {
        if let encodedData = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encodedData, forKey: storeKey)
        }
    }
    
    /// Marks an exercise as completed and handles progression
    func completeExercise(at index: Int) {
        guard index >= 0 && index < exercises.count else { return }
        
        // Mark as completed
        exercises[index].markCompleted()
        
        // Increment target for exercises that progress
        exercises[index].incrementTarget()
        
        // Save changes
        saveExercises()
    }
    
    /// Uncompletes an exercise (for user corrections)
    func uncompleteExercise(at index: Int) {
        guard index >= 0 && index < exercises.count else { return }
        
        exercises[index].resetCompletionStatus()
        saveExercises()
    }
    
    /// Sets up a timer to check for resets at regular intervals
    private func setupResetTimer() {
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
            resetExercisesIfNeeded(currentDate: now)
        }
    }
    
    /// Resets exercises if they were completed on a previous day
    func resetExercisesIfNeeded(currentDate: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        
        for i in 0..<exercises.count {
            // If the exercise is completed and was completed before today, reset it
            if exercises[i].isCompleted,
               let completionDate = exercises[i].lastCompletedDate,
               calendar.startOfDay(for: completionDate) < today {
                exercises[i].resetCompletionStatus()
            }
        }
        
        // Save changes if any exercises were reset
        saveExercises()
    }
    
    /// Forces a reset of all exercises (for testing or manual reset)
    func resetAllExercises() {
        for i in 0..<exercises.count {
            exercises[i].resetCompletionStatus()
        }
        saveExercises()
    }
    
    /// Resets exercise progression to initial values
    func resetProgression() {
        exercises = [
            .pushUps(),
            .pullUps(),
            .crow(),
            .handstand(),
            .leverPulls(),
            .frontLever()
        ]
        saveExercises()
    }
    
    /// Deinitializer to clean up timer
    deinit {
        resetTimer?.invalidate()
    }
}