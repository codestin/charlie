//
//  MockHealthKitManager.swift
//  charlie
//
//  Mock HealthKit implementation for Simulator testing
//  Provides realistic test data and development tools
//

import Foundation
import Combine

class MockHealthKitManager: ObservableObject, HealthDataProviding {
    @Published var todaySteps: Int = 0
    @Published var isAuthorized = false
    @Published var authorizationError: HealthKitError?
    @Published var isRequestingAuthorization = false
    
    var authorizationStatus: HealthAuthorizationStatus {
        if isAuthorized {
            return .sharingAuthorized
        } else if hasUserDeniedAccess {
            return .sharingDenied
        } else {
            return .notDetermined
        }
    }
    
    private var hasUserDeniedAccess = false
    private var cancellables = Set<AnyCancellable>()
    
    // Reactive connection to centralized state
    private let mockState: MockHealthKitState
    
    @MainActor
    init() {
        mockState = MockHealthKitState.shared
        setupReactiveBindings()
    }
    
    @MainActor
    private func setupReactiveBindings() {
        // Reactive binding to centralized state - single source of truth
        mockState.$stepCount
            .receive(on: DispatchQueue.main)
            .assign(to: \.todaySteps, on: self)
            .store(in: &cancellables)
        
        // Bind authorization response for testing
        mockState.$authorizationResponse
            .sink { [weak self] response in
                // Update internal state based on mock configuration
                self?.updateAuthorizationForTesting(response)
            }
            .store(in: &cancellables)
    }
    
    private func updateAuthorizationForTesting(_ response: DebugAuthorizationResponse) {
        switch response {
        case .allow:
            hasUserDeniedAccess = false
        case .deny:
            hasUserDeniedAccess = true
        case .delay:
            hasUserDeniedAccess = false
        }
    }
    
    func requestAuthorization() async throws {
        await MainActor.run {
            self.isRequestingAuthorization = true
            self.authorizationError = nil
        }
        
        // Get current authorization response from centralized state
        let authResponse = await mockState.authorizationResponse
        
        // Simulate network delay
        let delay: TimeInterval
        switch authResponse {
        case .delay:
            delay = 3.0  // Simulate slow authorization
        case .allow, .deny:
            delay = 0.5  // Normal authorization delay
        }
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        await MainActor.run {
            self.isRequestingAuthorization = false
            
            switch authResponse {
            case .allow:
                self.isAuthorized = true
                self.hasUserDeniedAccess = false
                self.startObservingSteps()
                
            case .deny:
                self.isAuthorized = false
                self.hasUserDeniedAccess = true
                self.authorizationError = HealthKitError.authorizationDenied
                
            case .delay:
                // After delay, simulate success
                self.isAuthorized = true
                self.hasUserDeniedAccess = false
                self.startObservingSteps()
            }
        }
        
        // Throw error if denied
        if authResponse == .deny {
            throw HealthKitError.authorizationDenied
        }
    }
    
    func startObservingSteps() {
        fetchTodaySteps()
        // Step simulation is now handled by MockHealthKitState
    }
    
    func fetchTodaySteps() {
        // Data is now reactively bound from MockHealthKitState
        // The reactive binding automatically provides current step count
        // Simulate slight delay for realism
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // No-op - data comes from reactive binding
            self.objectWillChange.send()
        }
    }
    
    func fetchSteps(for date: Date) async throws -> Int {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds
        
        // Generate realistic historical data
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let requestedDate = calendar.startOfDay(for: date)
        
        if calendar.isDate(requestedDate, equalTo: today, toGranularity: .day) {
            return todaySteps
        } else {
            // Generate realistic historical step counts (5000-12000 range)
            let dayOffset = calendar.dateComponents([.day], from: requestedDate, to: today).day ?? 0
            let seed = abs(dayOffset) + Int(date.timeIntervalSince1970 / 86400)
            var generator = SeededRandomNumberGenerator(seed: UInt64(seed))
            return Int.random(in: 5000...12000, using: &generator)
        }
    }
    
}

// MARK: - Utilities

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}