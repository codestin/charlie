//
//  HealthKitManager.swift
//  charlie
//
//  Real HealthKit implementation for device testing
//

import Foundation
import HealthKit
import Combine

class RealHealthKitManager: ObservableObject, HealthDataProviding {
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    @Published var todaySteps: Int = 0
    @Published var isAuthorized = false
    @Published var authorizationError: HealthKitError?
    @Published var isRequestingAuthorization = false
    
    var authorizationStatus: HealthAuthorizationStatus {
        switch healthStore.authorizationStatus(for: stepType) {
        case .notDetermined:
            return .notDetermined
        case .sharingDenied:
            return .sharingDenied
        case .sharingAuthorized:
            return .sharingAuthorized
        @unknown default:
            return .unavailable
        }
    }
    
    private var observerQuery: HKObserverQuery?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        updateAuthorizationStatus()
        if isAuthorized {
            startObservingSteps()
        }
    }
    
    deinit {
        if let query = observerQuery {
            healthStore.stop(query)
        }
    }
    
    private func updateAuthorizationStatus() {
        let status = healthStore.authorizationStatus(for: stepType)
        DispatchQueue.main.async {
            self.isAuthorized = status == .sharingAuthorized
            self.authorizationError = nil
        }
    }
    
    func requestAuthorization() async throws {
        DispatchQueue.main.async {
            self.isRequestingAuthorization = true
            self.authorizationError = nil
        }
        
        defer {
            DispatchQueue.main.async {
                self.isRequestingAuthorization = false
            }
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = HealthKitError.healthDataNotAvailable
            DispatchQueue.main.async {
                self.authorizationError = error
            }
            throw error
        }
        
        let types: Set = [stepType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: types)
            
            await MainActor.run {
                updateAuthorizationStatus()
                
                if !isAuthorized && authorizationStatus == .sharingDenied {
                    authorizationError = HealthKitError.authorizationDenied
                }
                
                if isAuthorized {
                    startObservingSteps()
                }
            }
            
        } catch {
            let healthError = HealthKitError.unknownError(error)
            DispatchQueue.main.async {
                self.authorizationError = healthError
            }
            throw healthError
        }
    }
    
    func startObservingSteps() {
        fetchTodaySteps()
        
        // Stop existing observer
        if let existingQuery = observerQuery {
            healthStore.stop(existingQuery)
        }
        
        // Set up background delivery for step updates
        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                self?.fetchTodaySteps()
            }
        }
        
        if let query = observerQuery {
            healthStore.execute(query)
            
            // Enable background delivery
            healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
                if let error = error {
                    print("Failed to enable background delivery: \(error)")
                }
            }
        }
    }
    
    func fetchTodaySteps() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            if let error = error {
                print("Error fetching today's steps: \(error)")
                return
            }
            
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            
            DispatchQueue.main.async {
                self?.todaySteps = Int(steps)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchSteps(for date: Date) async throws -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.unknownError(error))
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
}