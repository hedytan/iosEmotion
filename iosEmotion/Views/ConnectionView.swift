import SwiftUI

struct ConnectionView: View {
    @Environment(\.dismiss) var dismiss
    var post: Post
    var feeling: String
    
    @State private var isBreathing = false
    @State private var dotPosition: CGFloat = 0.0
    
    let fanMoodColor = Color(hex: "D890B8") // Tender pink for fan connection
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT GLOW (Centered)
            RadialGradient(
                stops: [
                    .init(color: post.moodType.color.opacity(0.07), location: 0),
                    .init(color: fanMoodColor.opacity(0.04), location: 0.6),
                    .init(color: .clear, location: 1.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 140
            )
            .frame(width: 280, height: 280)
            .blur(radius: 30)
            
            VStack(spacing: 0) {
                Spacer()
                
                // SECTION 1 — Visual connection
                HStack(spacing: 0) {
                    // LEFT — Artist shape
                    VStack(spacing: 12) {
                        MoodShapeView(type: post.moodType, color: post.moodType.color)
                            .frame(width: 68, height: 68)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                        
                        Text(post.artist)
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(.white.opacity(0.20))
                    }
                    
                    // CENTER — Connection line
                    ZStack {
                        // Gradient Line
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        post.moodType.color.opacity(0.45),
                                        .white.opacity(0.06),
                                        fanMoodColor.opacity(0.45)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                        
                        // Animated dot
                        Circle()
                            .fill(Color.white.opacity(0.55))
                            .frame(width: 7, height: 7)
                            .offset(x: -50 + (100 * dotPosition)) // Approximate but works for visual
                            .opacity(dotPosition < 0.1 || dotPosition > 0.9 ? 0 : 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    
                    // RIGHT — Fan shape (You)
                    VStack(spacing: 12) {
                        MoodShapeView(type: .tender, color: fanMoodColor)
                            .frame(width: 68, height: 68)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.6), value: isBreathing)
                        
                        Text("You")
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(.white.opacity(0.20))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        isBreathing = true
                    }
                    withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: false)) {
                        dotPosition = 1.0
                    }
                }
                
                // SECTION 2 — Text
                VStack(spacing: 0) {
                    Text("\(post.artist) shared a moment of \(post.moodType.displayName). You felt —")
                        .font(.custom("Lora-Italic", size: 13))
                        .italic()
                        .foregroundColor(.white.opacity(0.45))
                        .lineSpacing(13 * 1.7 - 13)
                        .frame(maxWidth: 220)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 14)
                    
                    Text("\"\(feeling)\"")
                        .font(.custom("Lora-Italic", size: 19))
                        .italic()
                        .foregroundColor(.white.opacity(0.88))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    Text("1,247 others felt the same way")
                        .font(.custom("DMMono-Regular", size: 8.5))
                        .kerning(0.1 * 8.5)
                        .foregroundColor(.white.opacity(0.18))
                        .padding(.bottom, 28)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 36, height: 1)
                        .padding(.bottom, 26)
                }
                
                // SECTION 3 — Nudge
                VStack(spacing: 0) {
                    Text("WANT TO SHARE YOURS?")
                        .font(.custom("DMMono-Regular", size: 7.5))
                        .kerning(0.16 * 7.5)
                        .foregroundColor(.white.opacity(0.14))
                        .padding(.bottom, 10)
                    
                    Text("What does this moment unlock in you?")
                        .font(.custom("Lora-Italic", size: 12.5))
                        .italic()
                        .foregroundColor(.white.opacity(0.28))
                        .lineSpacing(12.5 * 1.65 - 12.5)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                    
                    Button(action: { 
                        // In a real app, this would pop to root
                        dismiss() 
                    }) {
                        Text("← back to feed")
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(0.1 * 9)
                            .foregroundColor(.white.opacity(0.25))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 26)
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar) // Hide tab bar on this screen
    }
}
