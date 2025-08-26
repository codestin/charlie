# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Charlie** is a SwiftUI iOS fitness companion app that gamifies daily walking through step tracking and photo rewards. The app encourages users to reach a 10,000-step daily goal by unlocking adorable Charlie photos as rewards, creating a delightful and motivating fitness experience.

### Core Concept
- **Fitness Gamification**: Transform daily walking into an engaging game
- **Visual Progress**: Beautiful circular progress ring with color-coded states
- **Photo Rewards**: Unlock Charlie photos when reaching step goals
- **HealthKit Integration**: Real-time step tracking with professional iOS integration
- **Persistence**: Core Data stores progress, achievements, and unlocked rewards

## Commands

### Build and Run
- **Build**: `xcodebuild build -project charlie/charlie.xcodeproj -scheme charlie -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Clean**: `xcodebuild clean -project charlie/charlie.xcodeproj -scheme charlie`

### Testing
- **Run all tests**: `xcodebuild test -project charlie/charlie.xcodeproj -scheme charlie -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Run specific test**: `xcodebuild test -project charlie/charlie.xcodeproj -scheme charlie -only-testing:charlieTests/charlieTests/testName -destination 'platform=iOS Simulator,name=iPhone 16'`

### Development Workflow
1. **Simulator Testing**: Use debug panel (🔧 button) to simulate different step counts
2. **Real Device**: Connect to iPhone Health app for actual step tracking
3. **Mock Testing**: Enable/disable real-time simulation for various test scenarios

## Architecture

### Design Patterns
- **Protocol-Based Dependency Injection**: HealthDataProviding abstraction enables testing
- **Single Source of Truth**: MockHealthKitState eliminates split-brain state issues
- **Reactive Programming**: SwiftUI + Combine for real-time UI updates
- **MainActor Concurrency**: Swift 6 compliant with proper actor isolation
- **Environment-Aware**: Automatic Simulator vs Device implementation switching

### Core Components

#### 1. **charlieApp.swift** - App Entry Point
- SwiftUI @main app with Core Data and notification setup
- Environment injection for persistence and notifications
- App-level initialization and permission requests

#### 2. **CharlieView.swift** - Main Interface
- Primary UI with Charlie character, progress ring, and stats
- Real-time step tracking with HealthKit integration
- Reward system that unlocks photos at goal completion
- Authorization flows with professional error handling
- Debug panel integration for development testing

#### 3. **ProgressRingView.swift** - Visual Progress Indicator
- Animated circular progress ring (0-10,000 steps)
- Color-coded states: blue → orange → yellow → green
- Real-time animations with SwiftUI transitions
- Accessibility-ready with proper labels

#### 4. **HealthKit Architecture**
Professional health data integration with multiple implementation layers:

**Protocol Layer (HealthDataProviding.swift):**
```swift
protocol HealthDataProviding: ObservableObject {
    var todaySteps: Int { get }
    var isAuthorized: Bool { get }
    var authorizationStatus: HealthAuthorizationStatus { get }
    func requestAuthorization() async throws
    func startObservingSteps()
    func fetchSteps(for date: Date) async throws -> Int
}
```

**Factory Layer (HealthKitFactory.swift):**
- HealthKitManager: Environment-aware factory
- Automatic Simulator vs Device implementation switching
- Reactive property binding between implementations

**Implementation Layers:**
- **RealHealthKitManager**: Actual HealthKit integration for physical devices
- **MockHealthKitManager**: Simulator-compatible testing implementation
- **MockHealthKitState**: Centralized observable state for consistent testing

### Mock Testing Infrastructure

#### MockHealthKitState - Single Source of Truth
- **Centralized State**: Eliminates split-brain synchronization issues
- **Real-time Simulation**: Optional timer-based step increments (30-second intervals)
- **Manual Control**: Debug panel integration for precise testing scenarios
- **Reactive Bindings**: Automatic UI synchronization via Combine publishers

#### DebugHealthPanel - Development Tool
- **Step Count Control**: Manual input and preset scenarios (0, 6500, 10500)
- **Authorization Testing**: Simulate allow/deny/delay responses
- **Real-time Simulation**: Toggle automatic step increments with clear warnings
- **State Visibility**: Current step count, authorization mode, simulation status
- **Professional UX**: Color-coded indicators and helpful instructions

### Core Data Model

**Item Entity:**
- `timestamp`: Date - Progress tracking date
- `stepCount`: Int32 - Daily step count
- `goalMet`: Boolean - 10,000+ step achievement
- `totalSteps`: Int64 - Cumulative step history
- `photosUnlocked`: Int32 - Reward progression (0-10)

### Photo Reward System

**PhotoManager.swift:**
- 10 Charlie photos (charlie_1.png through charlie_10.png)
- Reward unlocking logic tied to step goal completion
- Random photo selection for variety
- SwiftUI integration with Image assets

### Notification System

**NotificationManager.swift:**
- Push notification permissions and scheduling
- Motivational messages for goal achievement
- Background processing capabilities
- User preference management

## Testing Strategy

### Unit Tests (charlieTests.swift)
Uses Apple's modern Testing framework with @Test macros:
- **MockHealthKitState Testing**: Step count management and bounds checking
- **Reactive Synchronization**: MockHealthKitManager binding verification
- **Authorization Testing**: Permission flow simulation and error handling
- **Preset Scenarios**: Common testing patterns (no steps, partial, goal reached)

### UI Tests (charlieUITests.swift)
End-to-end user experience validation:
- Navigation flows and user interactions
- HealthKit authorization scenarios
- Progress tracking accuracy
- Reward system functionality

### Development Testing Workflow
1. **Manual Testing**: Use debug panel for specific step count scenarios
2. **Real-time Testing**: Enable simulation to test dynamic updates
3. **Authorization Testing**: Simulate various permission responses
4. **Error Handling**: Test network failures, denied permissions, device limitations

## Key Features

### 🎯 **Step Goal Tracking**
- 10,000 step daily goal with visual progress
- Color-coded progress states for motivation
- Real-time updates via HealthKit integration
- Historical progress persistence

### 🏆 **Photo Reward System**
- Unlock Charlie photos by reaching daily goals
- 10 unique reward photos with delightful animations
- Progress tracking with visual indicators
- Confetti celebrations for achievements

### 📱 **Professional UX**
- Intuitive SwiftUI interface with smooth animations
- Loading states and error handling throughout
- Accessibility compliance with proper labels
- Dark mode support with adaptive colors

### 🔧 **Development Tools**
- Comprehensive debug panel for testing scenarios
- Mock implementations for reliable Simulator development
- Real-time simulation with configurable parameters
- Professional logging and state inspection

## Troubleshooting

### HealthKit Issues
- **Simulator**: HealthKit data is limited - use mock implementations via debug panel
- **Authorization Denied**: Guide users through Settings > Health > Data Access & Devices > Charlie
- **No Step Data**: Ensure iPhone is carried and motion permissions are granted

### Development Issues
- **Build Failures**: Ensure iPhone 16 simulator is available and selected
- **Test Timeouts**: Some tests involve async operations - allow adequate time
- **State Synchronization**: Use debug panel to verify mock state consistency

### Common Solutions
- **Reset Mock State**: Toggle real-time simulation off/on to reset step counts
- **Clear Simulator Data**: Device > Erase All Content and Settings
- **Health Permissions**: Delete and reinstall app to reset authorization

## Security & Privacy

### HealthKit Integration
- Step data only - no sensitive health information accessed
- User-controlled authorization with clear permission flows
- Data stays on device - no cloud storage or external transmission
- Compliance with Apple HealthKit guidelines

### Core Data Persistence
- Local device storage only
- No user account requirements or cloud sync
- Automatic data cleanup and management
- Privacy-first design principles

## Future Roadmap

### Potential Enhancements
- **Social Features**: Share achievements with friends
- **Additional Metrics**: Distance, calories, active minutes
- **Customization**: Personalized step goals and themes
- **Apple Watch**: Native watchOS companion app
- **Streak Tracking**: Multi-day achievement systems
- **Challenges**: Weekly/monthly step challenges

### Technical Improvements
- **CloudKit Integration**: Multi-device synchronization
- **Widgets**: Home screen progress widgets
- **Shortcuts**: Siri integration for quick progress checks
- **Background Processing**: Enhanced real-time updates