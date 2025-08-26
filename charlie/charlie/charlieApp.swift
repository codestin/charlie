//
//  charlieApp.swift
//  charlie
//
//  Created by C on 8/25/25.
//

import SwiftUI

@main
struct charlieApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var notifications = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            CharlieView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(notifications)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Request notification permissions
        Task {
            try? await notifications.requestAuthorization()
        }
    }
}
