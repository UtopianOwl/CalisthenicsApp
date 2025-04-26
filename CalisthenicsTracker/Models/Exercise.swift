//
//  Exercise.swift
//  CalisthenicsTracker
//
//  Created on: April 25, 2025
//

import Foundation

/// Represents a calisthenics exercise with tracking capabilities
struct Exercise: Identifiable, Codable {
    /// Unique identifier for the exercise
    var id = UUID()
    
    /// Name of the exercise
    var name: String
    
    /// Current target count (for repetition-based exercises) or duration in seconds (for time-based exercises)
    var currentTarget: Int
    
    /// Amount to increment the target by after completion (0 for fixed exercises)
    var increment: Int
    
    /// Maximum allowed target value (same as currentTarget for fixed exercises)
    var maxTarget: Int
    
    /// Whether the exercise is measured in time (minutes) rather than repetitions
    var isTimeBased: Bool
    
    /// Whether the exercise has been completed for the current day
    var isCompleted: Bool = false
    
    /// Date when the exercise was last completed
    var lastCompletedDate: Date?
    
    /// Formatted display string for the target (either reps or time)
    var targetDisplay: String {
        if isTimeBased {
            let minutes = currentTarget / 60
            let seconds = currentTarget % 60
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return "\(currentTarget)"
        }
    }
    
    /// Units label (either "reps" or "minutes")
    var units: String {
        return isTimeBased ? "minutes" : "reps"
    }
    
    /// Increments the target value if applicable, respecting the maximum
    mutating func incrementTarget() {
        // Only increment if the exercise has an increment value
        if increment > 0 {
            currentTarget = min(currentTarget + increment, maxTarget)
        }
    }
    
    /// Marks the exercise as completed and records the completion date
    mutating func markCompleted() {
        isCompleted = true
        lastCompletedDate = Date()
    }
    
    /// Resets the completion status but maintains the current target
    mutating func resetCompletionStatus() {
        isCompleted = false
    }
}

// MARK: - Factory methods for creating standard exercises

extension Exercise {
    /// Creates a push-ups exercise with standard progression
    static func pushUps() -> Exercise {
        Exercise(
            name: "Push-ups",
            currentTarget: 80,
            increment: 5,
            maxTarget: 100,
            isTimeBased: false
        )
    }
    
    /// Creates a pull-ups exercise with standard progression
    static func pullUps() -> Exercise {
        Exercise(
            name: "Pull-ups",
            currentTarget: 40,
            increment: 2,
            maxTarget: 50,
            isTimeBased: false
        )
    }
    
    /// Creates a crow pose exercise (fixed duration)
    static func crow() -> Exercise {
        Exercise(
            name: "Crow",
            currentTarget: 120, // 2 minutes in seconds
            increment: 0,
            maxTarget: 120,
            isTimeBased: true
        )
    }
    
    /// Creates a handstand exercise (fixed duration)
    static func handstand() -> Exercise {
        Exercise(
            name: "Handstand",
            currentTarget: 120, // 2 minutes in seconds
            increment: 0,
            maxTarget: 120,
            isTimeBased: true
        )
    }
    
    /// Creates a lever pulls exercise (fixed repetitions)
    static func leverPulls() -> Exercise {
        Exercise(
            name: "Lever Pulls",
            currentTarget: 20,
            increment: 0,
            maxTarget: 20,
            isTimeBased: false
        )
    }
    
    /// Creates a front lever exercise (fixed duration)
    static func frontLever() -> Exercise {
        Exercise(
            name: "Front Lever",
            currentTarget: 120, // 2 minutes in seconds
            increment: 0,
            maxTarget: 120,
            isTimeBased: true
        )
    }
}