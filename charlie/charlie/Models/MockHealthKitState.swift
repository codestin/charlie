//
//  MockHealthKitState.swift
//  charlie
//
//  Centralized observable state for mock HealthKit data
//  Single source of truth that eliminates split-brain state issues
//

import Foundation
import Combine

@MainActor
class MockHealthKitState: ObservableObject {
    // Single source of truth for step count
    @Published var stepCount: Int = 0
    
    // Authorization testing state
    @Published var authorizationResponse: DebugAuthorizationResponse = .allow
    
    // Real-time simulation settings (disabled by default to avoid interference with manual testing)
    @Published var simulateRealTimeUpdates: Bool = false
    
    static let shared = MockHealthKitState()
    
    private var timer: Timer?
    private var isSimulating = false
    
    init() {
        // Start real-time simulation if enabled
        if simulateRealTimeUpdates {
            startStepSimulation()
        }
        
        // React to simulation toggle changes
        $simulateRealTimeUpdates
            .sink { [weak self] enabled in
                if enabled {
                    self?.startStepSimulation()
                } else {
                    self?.stopStepSimulation()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Interface
    
    func setStepCount(_ count: Int) {
        stepCount = max(0, min(count, 50000)) // Reasonable bounds
    }
    
    func setAuthorizationResponse(_ response: DebugAuthorizationResponse) {
        authorizationResponse = response
    }
    
    func toggleRealTimeUpdates() {
        simulateRealTimeUpdates.toggle()
    }
    
    // MARK: - Convenience Methods for Debug Panel
    
    func simulateNoSteps() {
        setStepCount(0)
    }
    
    func simulatePartialProgress() {
        setStepCount(6500)
    }
    
    func simulateStepGoalReached() {
        setStepCount(10500)
    }
    
    // MARK: - Step Simulation
    
    private func startStepSimulation() {
        guard !isSimulating else { return }
        isSimulating = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                // Add 10-50 steps every 30 seconds to simulate walking
                let increment = Int.random(in: 10...50)
                let newStepCount = min(self.stepCount + increment, 15000)
                self.stepCount = newStepCount
            }
        }
    }
    
    private func stopStepSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulating = false
    }
    
    deinit {
        timer?.invalidate()
    }
}

enum DebugAuthorizationResponse {
    case allow
    case deny
    case delay  // Simulate slow authorization
}