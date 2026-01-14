//
//  TypingIndicatorView.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var shimmerOffset: CGFloat = -100
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Agent Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.35, blue: 0.95),
                                Color(red: 0.45, green: 0.25, blue: 0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("Thinking...")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.8),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 60)
                        .offset(x: shimmerOffset)
                        .onAppear {
                            // Reset state first
                            shimmerOffset = -100
                            
                            // Create animation
                            withAnimation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                            ) {
                                shimmerOffset = geometry.size.width + 20
                            }
                        }
                    }
                )
                .mask(
                    Text("Thinking...")
                        .font(.system(size: 15, weight: .medium))
                )
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    TypingIndicatorView()
        .background(Color(.systemBackground))
}
