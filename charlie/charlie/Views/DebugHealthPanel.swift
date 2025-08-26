//
//  DebugHealthPanel.swift
//  charlie
//
//  Debug panel for testing HealthKit functionality in development
//  Only available in DEBUG builds
//

import SwiftUI

#if DEBUG
struct DebugHealthPanel: View {
    @StateObject private var mockState = MockHealthKitState.shared
    @State private var mockSteps = ""
    @State private var showingPanel = false
    
    var body: some View {
        VStack {
            // Trigger button (small debug indicator)
            Button("🔧") {
                showingPanel = true
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showingPanel) {
            NavigationView {
                debugPanelContent
                    .navigationTitle("Debug HealthKit")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingPanel = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            // Initialize text field with current step count
            mockSteps = String(mockState.stepCount)
        }
        .onChange(of: mockState.stepCount) { newValue in
            // Update text field when step count changes (e.g., from simulation)
            mockSteps = String(newValue)
        }
    }
    
    private var debugPanelContent: some View {
        Form {
            Section("Mock Step Count") {
                HStack {
                    TextField("Step count", text: $mockSteps)
                        .keyboardType(.numberPad)
                    
                    Button("Set") {
                        if let steps = Int(mockSteps) {
                            mockState.setStepCount(steps)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Button("No Steps (0)") {
                        mockState.simulateNoSteps()
                        mockSteps = "0"
                    }
                    
                    Button("Partial Progress (6,500)") {
                        mockState.simulatePartialProgress()
                        mockSteps = "6500"
                    }
                    
                    Button("Goal Reached (10,500)") {
                        mockState.simulateStepGoalReached()
                        mockSteps = "10500"
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Section("Authorization Testing") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test authorization responses:")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Button("Simulate Allow") {
                        mockState.setAuthorizationResponse(.allow)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Simulate Deny") {
                        mockState.setAuthorizationResponse(.deny)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Simulate Slow Response") {
                        mockState.setAuthorizationResponse(.delay)
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Section("Real-time Updates") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Simulate Step Increments", isOn: $mockState.simulateRealTimeUpdates)
                    
                    if mockState.simulateRealTimeUpdates {
                        Text("⚠️ ACTIVE: Steps automatically increase every 30 seconds (10-50 steps). Manual changes may be overridden.")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    } else {
                        Text("Manual control enabled. Use buttons above to set specific step counts.")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Text("When enabled, step count will gradually increase every 30 seconds to simulate walking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Current State") {
                HStack {
                    Text("Mock Step Count:")
                    Spacer()
                    Text("\(mockState.stepCount)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Authorization Mode:")
                    Spacer()
                    Text(authorizationModeText)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Real-time Simulation:")
                    Spacer()
                    Text(mockState.simulateRealTimeUpdates ? "ON" : "OFF")
                        .fontWeight(.semibold)
                        .foregroundColor(mockState.simulateRealTimeUpdates ? .green : .secondary)
                }
            }
            
            Section("Instructions") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Use this panel to test different HealthKit scenarios")
                    Text("• Changes apply immediately to the mock implementation")
                    Text("• Real-time updates simulate gradual step increases")
                    Text("• Authorization testing lets you simulate user responses")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private var authorizationModeText: String {
        switch mockState.authorizationResponse {
        case .allow:
            return "Allow"
        case .deny:
            return "Deny"
        case .delay:
            return "Slow Response"
        }
    }
}

struct DebugHealthPanel_Previews: PreviewProvider {
    static var previews: some View {
        DebugHealthPanel()
    }
}
#endif