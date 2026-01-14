//
//  TypingIndicatorView.swift
//  AgentChat
//
//  Animated typing indicator to show when agent is typing
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animationOffset: [CGFloat] = [0, 0, 0]
    
    private let dotSize: CGFloat = 8
    private let animationDuration: Double = 0.4
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: animationOffset[index])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray5))
            .clipShape(ChatBubbleShape(isFromUser: false))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        for index in 0..<3 {
            withAnimation(
                Animation
                    .easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.15)
            ) {
                animationOffset[index] = -8
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        TypingIndicatorView()
        Spacer()
    }
    .background(Color(.systemBackground))
}
