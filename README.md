# Calisthenics Tracker

A SwiftUI-based iOS application for tracking daily calisthenics exercises with automatic progression and daily resets.

## Project Overview

Calisthenics Tracker is designed for fitness enthusiasts who want to track their daily calisthenics workouts. The app features a simple checklist interface that allows users to mark exercises as completed, with certain exercises automatically increasing in difficulty as the user progresses.

### Key Features

- **Daily Exercise Checklist**: Track completion of various calisthenics exercises
- **Automatic Progression**: Repetition-based exercises automatically increase in difficulty as you complete them
- **Daily Reset at 4am**: Exercise completion status resets automatically at 4am each day
- **Local Data Persistence**: Your progress is saved locally on your device
- **Visual Progress Tracking**: See your daily completion percentage at a glance
- **Time and Rep-Based Exercises**: Support for both timed exercises (like planks) and repetition-based exercises (like push-ups)

## Setup Instructions

### Requirements

- Xcode 15.0 or later
- iOS 16.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/calisthenics-tracker.git
   ```

2. Open the project in Xcode:
   ```bash
   cd calisthenics-tracker
   open CalisthenicsTracker.xcodeproj
   ```

3. Select your target device or simulator and click the Run button (▶️) in Xcode.

### Building from Source

1. Ensure you have the latest version of Xcode installed.
2. Open the project in Xcode.
3. Select the appropriate target device.
4. Build the project (Command + B).
5. Run the application (Command + R).

## Usage Guide

### Main Screen

The main screen displays your daily exercise checklist with the following information:
- Exercise name
- Current target (repetitions or time)
- Completion status

### Completing Exercises

1. Tap on the circle next to an exercise to mark it as completed.
2. Once completed, repetition-based exercises will automatically increase their target for the next day (up to a maximum value).
3. Tap on a completed exercise to unmark it if needed.

### Progress Tracking

- The progress bar at the top of the screen shows your daily completion percentage.
- The text below the progress bar shows the exact percentage and fraction of completed exercises.

### Reset Options

Access reset options by tapping the ellipsis (⋯) button in the top-right corner:
- **Reset Today's Progress**: Clears completion status for all exercises without affecting progression.
- **Reset All Progression**: Resets all exercise targets to their initial values.

### Automatic Reset

- All exercise completion statuses automatically reset at 4am each day.
- Exercise targets that have been increased due to progression are maintained.

## Technical Implementation Details

### Architecture

The app follows a clean architecture approach with the following components:

- **Models**: Data structures representing exercises and their properties
- **Views**: SwiftUI views for the user interface
- **Services**: Business logic for data persistence and reset functionality

### Key Components

#### Models

- `Exercise.swift`: Defines the Exercise struct with properties for tracking exercise details
- `ExerciseStore.swift`: Implements the ExerciseStore class that manages exercises

#### Views

- `ContentView.swift`: The main view containing the exercise checklist
- `ExerciseRowView.swift`: A reusable view component for displaying individual exercise items

#### Services

- `DataPersistenceService.swift`: Service for handling data persistence using UserDefaults
- `ResetService.swift`: Service for managing the 4am reset functionality

### Background Processing

The app uses iOS background processing capabilities to ensure the 4am reset happens reliably:

1. **BackgroundTasks Framework**: Schedules a background task to run at 4am
2. **Fallback Timer**: Uses an in-app timer when the app is running to ensure reset happens even if background tasks fail
3. **User Notifications**: Optionally notifies the user when exercises have been reset

### Data Persistence

Exercise data is persisted locally using UserDefaults:

1. Exercises are encoded to JSON using Swift's Codable protocol
2. The encoded data is stored in UserDefaults
3. On app launch, data is retrieved and decoded back into Exercise objects

### Exercise Progression

The app implements a progressive overload approach for repetition-based exercises:

1. When an exercise is completed, its target value is incremented by a predefined amount
2. Each exercise has a maximum target value to prevent unrealistic progression
3. Time-based exercises maintain a fixed duration

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- SwiftUI framework for the user interface
- Apple's BackgroundTasks framework for reliable background processing