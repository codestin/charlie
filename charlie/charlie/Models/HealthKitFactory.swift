//
//  HealthKitManager.swift
//  charlie
//
//  Concrete HealthKit manager that wraps implementation based on environment
//

import Foundation
import Combine

class HealthKitManager: ObservableObject, HealthDataProviding {
    @Published var todaySteps: Int = 0
    @Published var isAuthorized = false
    @Published var authorizationError: HealthKitError?
    @Published var isRequestingAuthorization = false
    
    var authorizationStatus: HealthAuthorizationStatus {
        #if targetEnvironment(simulator)
        return mockManager.authorizationStatus
        #else
        return realManager.authorizationStatus
        #endif
    }
    
    // Environment-specific implementations
    #if targetEnvironment(simulator)
    private let mockManager: MockHealthKitManager
    #else
    private let realManager = RealHealthKitManager()
    #endif
    
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    static var shared: HealthKitManager = {
        return HealthKitManager()
    }()
    
    @MainActor
    private init() {
        #if targetEnvironment(simulator)
        mockManager = MockHealthKitManager()
        #endif
        setupBindings()
    }
    
    @MainActor
    private func setupBindings() {
        #if targetEnvironment(simulator)
        // Bind to mock manager's properties
        mockManager.$todaySteps
            .assign(to: &$todaySteps)
        mockManager.$isAuthorized
            .assign(to: &$isAuthorized)
        mockManager.$authorizationError
            .assign(to: &$authorizationError)
        mockManager.$isRequestingAuthorization
            .assign(to: &$isRequestingAuthorization)
        #else
        // Bind to real manager's properties
        realManager.$todaySteps
            .assign(to: &$todaySteps)
        realManager.$isAuthorized
            .assign(to: &$isAuthorized)
        realManager.$authorizationError
            .assign(to: &$authorizationError)
        realManager.$isRequestingAuthorization
            .assign(to: &$isRequestingAuthorization)
        #endif
    }
    
    func requestAuthorization() async throws {
        #if targetEnvironment(simulator)
        try await mockManager.requestAuthorization()
        #else
        try await realManager.requestAuthorization()
        #endif
    }
    
    func startObservingSteps() {
        #if targetEnvironment(simulator)
        mockManager.startObservingSteps()
        #else
        realManager.startObservingSteps()
        #endif
    }
    
    func fetchTodaySteps() {
        #if targetEnvironment(simulator)
        mockManager.fetchTodaySteps()
        #else
        realManager.fetchTodaySteps()
        #endif
    }
    
    func fetchSteps(for date: Date) async throws -> Int {
        #if targetEnvironment(simulator)
        return try await mockManager.fetchSteps(for: date)
        #else
        return try await realManager.fetchSteps(for: date)
        #endif
    }
}