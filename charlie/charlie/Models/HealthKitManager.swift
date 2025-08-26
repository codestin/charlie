//
//  HealthKitManager.swift
//  charlie
//
//  Created for Charlie - Your Virtual Walking Companion
//

import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    @Published var todaySteps: Int = 0
    @Published var isAuthorized = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = healthStore.authorizationStatus(for: stepType)
        isAuthorized = authorizationStatus == .sharingAuthorized
    }
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.healthDataNotAvailable
        }
        
        let types: Set = [stepType]
        
        try await healthStore.requestAuthorization(toShare: [], read: types)
        
        await MainActor.run {
            checkAuthorizationStatus()
            if isAuthorized {
                startObservingSteps()
            }
        }
    }
    
    func startObservingSteps() {
        fetchTodaySteps()
        
        // Set up background delivery for step updates
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                self?.fetchTodaySteps()
            }
        }
        
        healthStore.execute(query)
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
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            
            DispatchQueue.main.async {
                self?.todaySteps = steps
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
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
}

enum HealthKitError: Error {
    case healthDataNotAvailable
    case authorizationFailed
}