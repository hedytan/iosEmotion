import SwiftUI

struct ConnectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    var post: Post
    var feeling: String
    var userMood: Post.MoodType
    
    @State private var dotPosition: CGFloat = 0.0
    @State private var isBreathing = false
    @State private var textOpacity: Double = 0.0
    
    var moodsMatch: Bool { post.moodType == userMood }
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT GLOW
            RadialGradient(
                stops: [
                    .init(color: post.themeColor.opacity(0.18), location: 0),
                    .init(color: userMood.color.opacity(0.08), location: 0.5),
                    .init(color: .clear, location: 1.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 140
            )
            .frame(width: 280, height: 280)
            .blur(radius: 40)
            
            VStack(spacing: 0) {
                Spacer()
                
                // SHAPE VISUALIZATION
                VStack(spacing: 20) {
                    HStack(spacing: 0) {
                        // Left - Artist
                        VStack(spacing: 12) {
                            MoodShapeView(type: post.moodType, color: post.themeColor, customMood: post.customMood)
                                .frame(width: 64, height: 64)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                            
                            Text(post.artist)
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.2))
                        }
                        
                        // Center - Bridge
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [post.themeColor.opacity(0.5), Color.white.opacity(0.05), userMood.color.opacity(0.5)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                            
                            // Travelling Dot
                            Circle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 7, height: 7)
                                .blur(radius: 1)
                                .offset(x: -50 + (100 * dotPosition))
                                .opacity(dotPosition > 0.08 && dotPosition < 0.92 ? 1 : 0)
                        }
                        .frame(width: 100)
                        .padding(.horizontal, 10)
                        
                        // Right - You
                        VStack(spacing: 12) {
                            MoodShapeView(type: userMood, color: userMood.color)
                                .frame(width: 64, height: 64)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .offset(y: 2)
                            
                            Text("You")
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.2))
                        }
                    }
                    
                    // Meet Labels
                    HStack(spacing: 8) {
                        Text(post.mood.uppercased())
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(post.themeColor.opacity(0.5))
                        
                        Text("meets")
                            .font(.custom("DMMono-Regular", size: 7))
                            .foregroundColor(.white.opacity(0.1))
                        
                        Text(userMood.displayName.uppercased())
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(userMood.color.opacity(0.5))
                    }
                }
                .padding(.bottom, 60)
                
                // CONNECTION TEXT
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("\(post.artist) shared \(post.mood).")
                            .font(.custom("Lora-Italic", size: 12.5))
                            .foregroundColor(.white.opacity(0.42))
                        
                        Text("You felt something \(moodsMatch ? "similar" : "different") —")
                            .font(.custom("Lora-Italic", size: 12.5))
                            .foregroundColor(.white.opacity(0.42))
                        
                        Text("“\(feeling)”")
                            .font(.custom("Lora-Italic", size: 18))
                            .foregroundColor(.white.opacity(0.88))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 230)
                            .padding(.top, 10)
                    }
                    
                    VStack(spacing: 16) {
                        Text("you + \(post.resonanceCount) others felt something \(userMood.displayName) here")
                            .font(.custom("DMMono-Regular", size: 8))
                            .kerning(0.8)
                            .foregroundColor(.white.opacity(0.18))
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 36, height: 1)
                        
                        VStack(spacing: 8) {
                            Text("a moment between you")
                                .font(.custom("DMMono-Regular", size: 7.5))
                                .kerning(1)
                                .textCase(.uppercase)
                                .foregroundColor(.white.opacity(0.14))
                            
                            Text(moodsMatch ? "You both felt \(userMood.displayName). You're not alone." : "His \(post.mood) unlocked your \(userMood.displayName). That's a real connection.")
                                .font(.custom("Lora-Italic", size: 12))
                                .foregroundColor(.white.opacity(0.26))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 190)
                        }
                    }
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Back Button
                Button(action: { dismiss() }) {
                    Text("← back to feed")
                        .font(.custom("DMMono-Regular", size: 9))
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: false)) {
                dotPosition = 1.0
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.4)) {
                textOpacity = 1.0
            }
            // Continuous dot animation
            Timer.scheduledTimer(withTimeInterval: 2.6, repeats: true) { _ in
                dotPosition = 0.0
                withAnimation(.easeInOut(duration: 2.4)) {
                    dotPosition = 1.0
                }
            }
        }
    }
}
