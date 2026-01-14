//
//  HomeView.swift
//  AgentChat
//
//  Home page with navigation to chat
//

import SwiftUI

struct HomeView: View {
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                backgroundGradient
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo/Icon
                    logoSection
                    
                    // Welcome Text
                    welcomeText
                    
                    Spacer()
                    
                    // Start Chat Button
                    startChatButton
                    
                    // Footer
                    footerText
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            // Animated gradient circles
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: -100, y: -200)
                    .blur(radius: 60)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.25), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 350, height: 350)
                    .offset(x: 150, y: 300)
                    .blur(radius: 50)
                    .scaleEffect(isAnimating ? 0.9 : 1.1)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: 100, y: -100)
                    .blur(radius: 40)
                    .scaleEffect(isAnimating ? 1.05 : 0.95)
            }
            .animation(
                Animation.easeInOut(duration: 4)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
        )
        .onAppear {
            isAnimating = true
        }
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 20)
            
            // Icon Container
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.2, blue: 0.35),
                                Color(red: 0.1, green: 0.1, blue: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "message.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .scaleEffect(isAnimating ? 1.02 : 0.98)
        .animation(
            Animation.easeInOut(duration: 2)
                .repeatForever(autoreverses: true),
            value: isAnimating
        )
    }
    
    // MARK: - Welcome Text
    private var welcomeText: some View {
        VStack(spacing: 16) {
            Text("Agent Chat")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("Your intelligent assistant is ready to help.\nStart a conversation now.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Start Chat Button
    private var startChatButton: some View {
        NavigationLink(destination: ChatView()) {
            HStack(spacing: 12) {
                Text("Start Conversation")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    // Background gradient
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.blue.opacity(0.8),
                                    Color.purple.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Glass overlay
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.4), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .blue.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PressableButtonStyle())
    }
    
    // MARK: - Footer Text
    private var footerText: some View {
        Text("Powered by AI • Available 24/7")
            .font(.caption)
            .foregroundColor(.gray.opacity(0.6))
    }
}

// MARK: - Pressable Button Style
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
