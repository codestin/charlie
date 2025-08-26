//
//  RewardView.swift
//  charlie
//
//  Shows reward photo when daily goal is reached
//

import SwiftUI

struct RewardView: View {
    let photo: CharliePhoto
    @Binding var isPresented: Bool
    @State private var showConfetti = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Confetti overlay
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .zIndex(1)
                }
                
                VStack(spacing: 20) {
                Text("🎉 Congratulations! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("You walked Charlie today!")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                // Photo placeholder - will show actual photo when added
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                    
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(photo.imageName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                Text("Charlie Photo #\(photo.id)")
                    .font(.headline)
                
                Button(action: {
                    sharePhoto()
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button("Continue") {
                    isPresented = false
                }
                .font(.headline)
                .padding()
            }
            }
            .padding()
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showConfetti = true
                }
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    private func sharePhoto() {
        // Placeholder for sharing functionality
        // Will implement when actual photos are added
    }
}

// Preview
struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        RewardView(
            photo: CharliePhoto(id: 1, imageName: "charlie_1"),
            isPresented: .constant(true)
        )
    }
}