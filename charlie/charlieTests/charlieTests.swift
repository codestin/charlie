//
//  charlieTests.swift
//  charlieTests
//
//  Created by C on 8/25/25.
//

import Testing
import Combine
@testable import charlie

struct charlieTests {
    
    @MainActor
    @Test func mockHealthKitStateSetsStepCount() async throws {
        // Test that MockHealthKitState properly manages step count
        let state = MockHealthKitState()
        
        // Test initial state
        #expect(state.stepCount == 7500) // Default value
        
        // Test setting step count
        state.setStepCount(5000)
        #expect(state.stepCount == 5000)
        
        // Test bounds checking
        state.setStepCount(-100)
        #expect(state.stepCount == 0) // Should be clamped to 0
        
        state.setStepCount(60000)
        #expect(state.stepCount == 50000) // Should be clamped to max
    }
    
    @MainActor
    @Test func mockHealthKitManagerSyncsWithState() async throws {
        // Test that MockHealthKitManager reactively binds to state
        let state = MockHealthKitState()
        let manager = MockHealthKitManager()
        
        // Allow binding to establish
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify initial sync
        #expect(manager.todaySteps == state.stepCount)
        
        // Test state change propagation
        state.setStepCount(8000)
        
        // Allow reactive update to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(manager.todaySteps == 8000)
        #expect(manager.todaySteps == state.stepCount)
    }
    
    @MainActor
    @Test func mockHealthKitStatePresetMethods() async throws {
        // Test convenience methods for common scenarios
        let state = MockHealthKitState()
        
        state.simulateNoSteps()
        #expect(state.stepCount == 0)
        
        state.simulatePartialProgress()
        #expect(state.stepCount == 6500)
        
        state.simulateStepGoalReached()
        #expect(state.stepCount == 10500)
    }
    
    @MainActor
    @Test func mockHealthKitStateAuthorizationResponse() async throws {
        // Test authorization response management
        let state = MockHealthKitState()
        
        // Test initial state
        #expect(state.authorizationResponse == DebugAuthorizationResponse.allow)
        
        // Test setting responses
        state.setAuthorizationResponse(DebugAuthorizationResponse.deny)
        #expect(state.authorizationResponse == DebugAuthorizationResponse.deny)
        
        state.setAuthorizationResponse(DebugAuthorizationResponse.delay)
        #expect(state.authorizationResponse == DebugAuthorizationResponse.delay)
    }
    
    @MainActor
    @Test func mockHealthKitManagerAuthorizationSync() async throws {
        // Test that MockHealthKitManager responds to authorization state changes
        let state = MockHealthKitState()
        let manager = MockHealthKitManager()
        
        // Test authorization denial
        state.setAuthorizationResponse(DebugAuthorizationResponse.deny)
        
        do {
            try await manager.requestAuthorization()
            #expect(Bool(false), "Should have thrown authorization denied error")
        } catch HealthKitError.authorizationDenied {
            // Expected error
            #expect(manager.authorizationStatus == HealthAuthorizationStatus.sharingDenied)
        } catch {
            #expect(Bool(false), "Unexpected error type: \(error)")
        }
    }

}
