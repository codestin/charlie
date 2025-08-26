# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application named "charlie" that uses Core Data for persistence. It's a standard Xcode project with a simple list-based interface for managing timestamped items.

## Commands

### Build and Run
- **Build**: Open project in Xcode and press Cmd+B, or use `xcodebuild build -project charlie/charlie.xcodeproj -scheme charlie`
- **Run**: Open project in Xcode and press Cmd+R, or use `xcodebuild test -project charlie/charlie.xcodeproj -scheme charlie -destination 'platform=iOS Simulator,name=iPhone 15'`
- **Clean**: `xcodebuild clean -project charlie/charlie.xcodeproj -scheme charlie`

### Testing
- **Run all tests**: `xcodebuild test -project charlie/charlie.xcodeproj -scheme charlie -destination 'platform=iOS Simulator,name=iPhone 15'`
- **Run specific test**: Use Xcode's Test Navigator or `xcodebuild test -project charlie/charlie.xcodeproj -scheme charlie -only-testing:charlieTests/charlieTests/testName`
- **UI Tests**: `xcodebuild test -project charlie/charlie.xcodeproj -scheme charlie -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:charlieUITests`

## Architecture

### Core Components

1. **charlieApp.swift**: Main app entry point using SwiftUI's @main attribute. Initializes the Core Data persistence controller and provides it to the view hierarchy.

2. **ContentView.swift**: Primary UI component implementing a NavigationView with:
   - List view displaying Core Data items sorted by timestamp
   - Add/delete functionality for items
   - SwiftUI toolbar with EditButton and Add Item button
   - Date formatter for displaying timestamps

3. **Persistence.swift**: Core Data stack management with:
   - Singleton shared instance for production
   - Preview instance with sample data for SwiftUI previews
   - In-memory store option for testing
   - Automatic merging of changes from parent context

4. **Core Data Model** (charlie.xcdatamodeld):
   - Single entity: `Item` with `timestamp` attribute (Date, optional)
   - Code generation handled automatically by Xcode

### Testing Structure
- **charlieTests**: Uses Apple's new Testing framework (import Testing) with @Test macros
- **charlieUITests**: Standard XCTest UI testing setup

### Key Patterns
- MVVM-like structure with SwiftUI property wrappers (@Environment, @FetchRequest)
- Core Data integration using NSManagedObjectContext environment value
- Preview support with dedicated in-memory Core Data stack
- Error handling currently uses fatalError (should be replaced in production)