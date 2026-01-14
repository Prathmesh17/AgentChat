//
//  HomeView.swift
//  AgentChat
//
//  Created by Prathmesh Parteki on 14/01/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Logo/Icon
                Image(systemName: "message.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                // Welcome Text
                VStack(spacing: 12) {
                    Text("Agent Chat")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your intelligent assistant is ready to help.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Start Chat Button
                NavigationLink(destination: ChatView()) {
                    Text("Start Conversation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                // Footer
                Text("Powered by AI")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
