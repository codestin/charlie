//
//  HealthDataProviding.swift
//  charlie
//
//  Protocol abstraction for HealthKit data access
//  Enables testing and mock implementations
//

import Foundation
import Combine

protocol HealthDataProviding: ObservableObject {
    var todaySteps: Int { get }
    var isAuthorized: Bool { get }
    var authorizationStatus: HealthAuthorizationStatus { get }
    var authorizationError: HealthKitError? { get }
    var isRequestingAuthorization: Bool { get }
    
    func requestAuthorization() async throws
    func startObservingSteps()
    func fetchTodaySteps()
    func fetchSteps(for date: Date) async throws -> Int
}

enum HealthAuthorizationStatus {
    case notDetermined
    case sharingDenied
    case sharingAuthorized
    case unavailable
}

enum HealthKitError: Error, LocalizedError {
    case healthDataNotAvailable
    case authorizationFailed
    case authorizationDenied
    case dataFetchFailed
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            return "HealthKit is not available on this device"
        case .authorizationFailed:
            return "Failed to authorize HealthKit access"
        case .authorizationDenied:
            return "HealthKit access was denied. Please enable in Settings > Health > Data Access & Devices"
        case .dataFetchFailed:
            return "Failed to fetch health data"
        case .unknownError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .authorizationDenied:
            return "Open Settings app → Health → Data Access & Devices → Charlie → Turn on Step Count"
        case .healthDataNotAvailable:
            return "HealthKit requires a physical iOS device and may not work in the Simulator"
        default:
            return "Please try again or restart the app"
        }
    }
}