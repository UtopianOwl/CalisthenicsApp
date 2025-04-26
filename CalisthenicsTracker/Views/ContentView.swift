//
//  ContentView.swift
//  CalisthenicsTracker
//
//  Created on: April 25, 2025
//

import SwiftUI

/// The main view containing the exercise checklist and app-level UI elements
struct ContentView: View {
    /// The store that manages all exercises
    @StateObject private var exerciseStore = ExerciseStore()
    
    /// Computed property to calculate completion percentage
    private var completionPercentage: Double {
        guard !exerciseStore.exercises.isEmpty else { return 0 }
        let completedCount = exerciseStore.exercises.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(exerciseStore.exercises.count)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: completionPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .padding(.horizontal)
                
                // Progress text
                HStack {
                    Text("\(Int(completionPercentage * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(exerciseStore.exercises.filter { $0.isCompleted }.count)/\(exerciseStore.exercises.count) Exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Exercise list
                List {
                    Section(header: Text("Today's Exercises")) {
                        ForEach(exerciseStore.exercises.indices, id: \.self) { index in
                            ExerciseRowView(
                                exercise: Binding(
                                    get: { exerciseStore.exercises[index] },
                                    set: { exerciseStore.exercises[index] = $0 }
                                )
                            ) {
                                if exerciseStore.exercises[index].isCompleted {
                                    exerciseStore.uncompleteExercise(at: index)
                                } else {
                                    exerciseStore.completeExercise(at: index)
                                }
                            }
                        }
                    }
                    
                    Section(footer: infoFooter) {
                        // Empty section for footer spacing
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Calisthenics Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            exerciseStore.resetAllExercises()
                        }) {
                            Label("Reset Today's Progress", systemImage: "arrow.counterclockwise")
                        }
                        
                        Button(role: .destructive, action: {
                            exerciseStore.resetProgression()
                        }) {
                            Label("Reset All Progression", systemImage: "gobackward")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    /// Color for the progress bar based on completion percentage
    private var progressColor: Color {
        switch completionPercentage {
        case 0..<0.33:
            return .red
        case 0.33..<0.66:
            return .orange
        case 0.66..<1.0:
            return .yellow
        case 1.0:
            return .green
        default:
            return .blue
        }
    }
    
    /// Informational footer view
    private var infoFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Progress automatically resets at 4:00 AM")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Repetition-based exercises will increase in difficulty as you complete them")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}