//
//  StatsView.swift
//  charlie
//
//  Shows accumulated stats and history
//

import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<Item>
    
    private var currentItem: Item? {
        items.first
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Stats Card
                overallStatsCard
                
                // Photo Collection
                photoCollectionCard
                
                // Recent Activity
                recentActivityCard
            }
            .padding()
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var overallStatsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Overall Progress")
                .font(.headline)
            
            HStack {
                statItem(
                    title: "Total Steps",
                    value: "\(currentItem?.totalSteps ?? 0)",
                    icon: "figure.walk",
                    color: .blue
                )
                
                Spacer()
                
                statItem(
                    title: "Current Streak",
                    value: "1 days",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            HStack {
                statItem(
                    title: "Photos Unlocked",
                    value: "\(currentItem?.photosUnlocked ?? 0)/10",
                    icon: "photo.fill",
                    color: .purple
                )
                
                Spacer()
                
                statItem(
                    title: "Days with Charlie",
                    value: "1",
                    icon: "calendar",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var photoCollectionCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Photo Collection")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1...10, id: \.self) { index in
                        photoThumbnail(index: index)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.headline)
            
            if let item = currentItem {
                HStack {
                    Text(item.timestamp ?? Date(), style: .date)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(item.stepCount) steps")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if item.goalMet {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 5)
            } else {
                Text("No activity yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
    
    private func photoThumbnail(index: Int) -> some View {
        let photosUnlocked = currentItem?.photosUnlocked ?? 0
        let isUnlocked = index <= photosUnlocked
        
        return ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isUnlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
            
            if isUnlocked {
                VStack {
                    Image(systemName: "photo.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("#\(index)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
    }
}