import SwiftUI

struct ConnectionView: View {
    @Environment(\.dismiss) var dismiss
    var post: Post
    var feeling: String
    
    @State private var isBreathing = false
    @State private var dotPosition: CGFloat = 0.0
    @State private var flashOpacity: Double = 0.0
    @State private var floatOffset: CGFloat = 0.0
    
    let fanMoodColor = Color(hex: "D890B8")
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT GLOW (Centered & Pulsing)
            ZStack {
                RadialGradient(
                    stops: [
                        .init(color: post.themeColor.opacity(isBreathing ? 0.12 : 0.07), location: 0),
                        .init(color: fanMoodColor.opacity(isBreathing ? 0.08 : 0.04), location: 0.6),
                        .init(color: .clear, location: 1.0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: isBreathing ? 160 : 140
                )
                .frame(width: 320, height: 320)
                .blur(radius: 30)
                
                // THE RESONANCE FLASH (Click effect)
                Circle()
                    .fill(Color.white.opacity(flashOpacity))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 60) {
                    // THE CONNECTION BRIDGE
                    HStack(spacing: 0) {
                        // LEFT — Artist shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: post.moodType, color: post.themeColor, customMood: post.customMood)
                                .frame(width: 68, height: 68)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .offset(y: floatOffset)
                            
                            Text(post.artist)
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        
                        // CENTER — The Bridge
                        ZStack {
                            // Static path
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                                .frame(width: 100)
                            
                            // Travelling Dot (The Resonance)
                            Circle()
                                .fill(
                                    LinearGradient(colors: [post.themeColor, fanMoodColor], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: 4, height: 4)
                                .offset(x: -50 + (100 * dotPosition))
                                .blur(radius: 1)
                        }
                        
                        // RIGHT — You shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: .tender, color: fanMoodColor)
                                .frame(width: 68, height: 68)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .offset(y: -floatOffset)
                            
                            Text("You")
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .offset(x: 0)
                    }
                    
                    // STATUS TEXT
                    VStack(spacing: 12) {
                        Text("resonance established")
                            .font(.custom("Lora-Italic", size: 18))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(feeling)
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(0.2 * 9)
                            .foregroundColor(post.themeColor.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // DISMISS BUTTON
                Button(action: { dismiss() }) {
                    Text("return to void")
                        .font(.custom("DMMono-Regular", size: 10))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // THE FLASH
            withAnimation(.easeOut(duration: 0.6)) {
                flashOpacity = 0.6
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 1.2)) {
                    flashOpacity = 0.0
                }
            }
            
            // THE BREATHING & FLOATING
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isBreathing = true
                floatOffset = 8
            }
            
            // THE TRAVELLING RESONANCE
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                dotPosition = 1.0
            }
        }
    }
}
