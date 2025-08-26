//
//  ProgressRingView.swift
//  charlie
//
//  Circular progress indicator for step tracking
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat = 20
    let goalSteps: Int = 10000
    let currentSteps: Int
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.7 {
            return .yellow
        } else if progress >= 0.4 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Center text
            VStack(spacing: 8) {
                Text("\(currentSteps)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("of \(goalSteps) steps")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                if progress >= 1.0 {
                    Text("Goal Reached!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                }
            }
        }
        .frame(width: 250, height: 250)
    }
}