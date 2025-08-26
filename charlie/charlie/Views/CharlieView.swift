//
//  CharlieView.swift
//  charlie
//
//  Main view showing Charlie and walking progress
//

import SwiftUI
import CoreData

struct CharlieView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var healthKit = HealthKitManager.shared
    @State private var showingReward = false
    @State private var rewardPhoto: CharliePhoto?
    @State private var lastRewardedSteps = 0
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<Item>
    
    private var currentItem: Item? {
        items.first
    }
    
    private var progress: Double {
        Double(healthKit.todaySteps) / 10000.0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Charlie Image
                    charlieImageSection
                    
                    // Progress Ring
                    ProgressRingView(
                        progress: progress,
                        currentSteps: healthKit.todaySteps
                    )
                    .padding()
                    
                    // Status Message
                    statusMessage
                    
                    // Stats Summary
                    statsSection
                    
                    // Walk Charlie Button (if not authorized)
                    if !healthKit.isAuthorized {
                        authorizeButton
                    }
                }
                .padding()
            }
            .navigationTitle("Charlie")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: StatsView()) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showingReward) {
            if let photo = rewardPhoto {
                RewardView(photo: photo, isPresented: $showingReward)
            }
        }
        .onAppear {
            checkHealthKitAuthorization()
            checkForReward()
        }
        .onChange(of: healthKit.todaySteps) { _ in
            updateProgress()
            checkForReward()
        }
    }
    
    private var charlieImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
            
            VStack {
                Image(systemName: "dog.fill")
                    .font(.system(size: 80))
                    .foregroundColor(progress >= 1.0 ? .green : .blue)
                
                Text("Charlie")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
    }
    
    private var statusMessage: some View {
        Group {
            if progress >= 1.0 {
                Text("Charlie is happy and well-walked today! 🎉")
                    .font(.headline)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
            } else if progress >= 0.7 {
                Text("Almost there! Charlie is excited for the rest of the walk!")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            } else if progress >= 0.3 {
                Text("Good progress! Keep walking with Charlie!")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            } else {
                Text("Charlie needs his walk today!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
    
    private var statsSection: some View {
        HStack(spacing: 40) {
            VStack {
                Text("\(currentItem?.totalSteps ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Total Steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                Text("1")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Day Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                Text("\(currentItem?.photosUnlocked ?? 0)/10")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Photos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var authorizeButton: some View {
        Button(action: {
            Task {
                try? await healthKit.requestAuthorization()
            }
        }) {
            Label("Connect Health App", systemImage: "heart.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private func checkHealthKitAuthorization() {
        if healthKit.authorizationStatus == .notDetermined {
            Task {
                try? await healthKit.requestAuthorization()
            }
        }
    }
    
    private func updateProgress() {
        // Update or create item with today's progress
        if let item = currentItem {
            item.stepCount = Int32(healthKit.todaySteps)
            item.goalMet = healthKit.todaySteps >= 10000
            item.timestamp = Date()
            if item.totalSteps == 0 {
                item.totalSteps = Int64(healthKit.todaySteps)
            }
        } else {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.stepCount = Int32(healthKit.todaySteps)
            newItem.goalMet = healthKit.todaySteps >= 10000
            newItem.totalSteps = Int64(healthKit.todaySteps)
            newItem.photosUnlocked = 0
        }
        
        try? viewContext.save()
    }
    
    private func checkForReward() {
        guard healthKit.todaySteps >= 10000,
              healthKit.todaySteps > lastRewardedSteps else { return }
        
        // Check if we already gave a reward today (simple check)
        if let item = currentItem,
           let timestamp = item.timestamp,
           Calendar.current.isDateInToday(timestamp),
           item.goalMet {
            return
        }
        
        // Get a random photo
        if let photo = PhotoManager.shared.getRandomPhoto() {
            rewardPhoto = photo
            showingReward = true
            lastRewardedSteps = healthKit.todaySteps
            
            // Update item stats
            if let item = currentItem {
                item.photosUnlocked = min((item.photosUnlocked + 1), 10)
            }
            
            try? viewContext.save()
        }
    }
}