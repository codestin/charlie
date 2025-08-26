//
//  ConfettiView.swift
//  charlie
//
//  Celebration animation for goal achievements
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    let confettiCount = 50
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            createConfetti()
        }
    }
    
    private func createConfetti() {
        for i in 0..<confettiCount {
            let piece = ConfettiPiece(
                id: i,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                color: [Color.red, Color.blue, Color.green, Color.yellow, Color.purple, Color.orange].randomElement()!,
                size: CGFloat.random(in: 8...16),
                delay: Double.random(in: 0...0.5)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: Int
    let x: CGFloat
    let color: Color
    let size: CGFloat
    let delay: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var y: CGFloat = -100
    @State private var rotation = Double.random(in: 0...360)
    
    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size * 0.6)
            .rotationEffect(.degrees(rotation))
            .position(x: piece.x, y: y)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: Double.random(in: 2...4))
                        .delay(piece.delay)
                        .repeatForever(autoreverses: false)
                ) {
                    y = UIScreen.main.bounds.height + 100
                    rotation += Double.random(in: 180...720)
                }
            }
    }
}