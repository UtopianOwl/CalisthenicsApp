//
//  ExerciseRowView.swift
//  CalisthenicsTracker
//
//  Created on: April 25, 2025
//

import SwiftUI

/// A reusable view component for displaying individual exercise items in the checklist
struct ExerciseRowView: View {
    /// The exercise to display
    @Binding var exercise: Exercise
    
    /// Callback for when the exercise is toggled
    var onToggle: () -> Void
    
    var body: some View {
        HStack {
            // Exercise name and details
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(exercise.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 4) {
                    Text("Target: \(exercise.targetDisplay)")
                        .font(.subheadline)
                    
                    Text(exercise.units)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Completion indicator
            Button(action: onToggle) {
                ZStack {
                    // Different styling for time-based vs rep-based exercises
                    if exercise.isTimeBased {
                        Circle()
                            .stroke(exercise.isCompleted ? Color.green : Color.gray, lineWidth: 2)
                            .frame(width: 28, height: 28)
                        
                        if exercise.isCompleted {
                            Image(systemName: "timer.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 24))
                        } else {
                            Image(systemName: "timer")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                        }
                    } else {
                        Circle()
                            .stroke(exercise.isCompleted ? Color.green : Color.gray, lineWidth: 2)
                            .frame(width: 28, height: 28)
                        
                        if exercise.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 24))
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Make the entire row tappable
        .opacity(exercise.isCompleted ? 0.8 : 1.0)
    }
}

#Preview {
    // Preview with a sample exercise
    struct PreviewWrapper: View {
        @State private var exercise = Exercise.pushUps()
        
        var body: some View {
            List {
                ExerciseRowView(exercise: $exercise) {
                    exercise.isCompleted.toggle()
                }
                
                ExerciseRowView(exercise: .constant(Exercise.crow())) {
                    // No action for preview
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    return PreviewWrapper()
}