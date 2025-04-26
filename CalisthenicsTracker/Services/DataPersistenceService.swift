//
//  DataPersistenceService.swift
//  CalisthenicsTracker
//
//  Created on: April 25, 2025
//

import Foundation

/// A dedicated service for handling all data persistence operations related to exercises
class DataPersistenceService {
    /// Shared singleton instance
    static let shared = DataPersistenceService()
    
    /// Key used for storing exercises in UserDefaults
    private let exercisesStoreKey = "com.calisthenicsTracker.exercises"
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Saves the provided exercises to UserDefaults
    /// - Parameter exercises: Array of exercises to save
    /// - Returns: Boolean indicating whether the save operation was successful
    @discardableResult
    func saveExercises(_ exercises: [Exercise]) -> Bool {
        do {
            let encodedData = try JSONEncoder().encode(exercises)
            UserDefaults.standard.set(encodedData, forKey: exercisesStoreKey)
            return true
        } catch {
            print("Error saving exercises: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Loads exercises from UserDefaults
    /// - Returns: Array of exercises if available, nil otherwise
    func loadExercises() -> [Exercise]? {
        guard let data = UserDefaults.standard.data(forKey: exercisesStoreKey) else {
            return nil
        }
        
        do {
            let exercises = try JSONDecoder().decode([Exercise].self, from: data)
            return exercises
        } catch {
            print("Error loading exercises: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Creates and returns default exercises
    /// - Returns: Array of default exercises
    func createDefaultExercises() -> [Exercise] {
        return [
            .pushUps(),
            .pullUps(),
            .crow(),
            .handstand(),
            .leverPulls(),
            .frontLever()
        ]
    }
    
    /// Clears all saved exercise data
    /// - Returns: Boolean indicating whether the clear operation was successful
    @discardableResult
    func clearSavedData() -> Bool {
        UserDefaults.standard.removeObject(forKey: exercisesStoreKey)
        return !UserDefaults.standard.contains(key: exercisesStoreKey)
    }
    
    /// Updates a specific exercise in the saved collection
    /// - Parameters:
    ///   - exercise: The updated exercise
    ///   - exercises: The current array of exercises
    /// - Returns: Updated array of exercises with the change applied
    func updateExercise(_ exercise: Exercise, in exercises: [Exercise]) -> [Exercise] {
        var updatedExercises = exercises
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            updatedExercises[index] = exercise
            saveExercises(updatedExercises)
        }
        return updatedExercises
    }
    
    /// Checks if there is any saved exercise data
    /// - Returns: Boolean indicating whether saved data exists
    func hasSavedData() -> Bool {
        return UserDefaults.standard.data(forKey: exercisesStoreKey) != nil
    }
}