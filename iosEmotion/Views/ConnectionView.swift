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
    @State private var electricPulse: Bool = false
    @State private var sparkOffset: CGFloat = 0
    
    var moodsMatch: Bool { post.moodType == userMood }
    let randomOthers = Int.random(in: 300...1000)
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT GLOW (Centered with content)
            RadialGradient(
                stops: [
                    .init(color: post.themeColor.opacity(0.22), location: 0),
                    .init(color: userMood.color.opacity(0.12), location: 0.5),
                    .init(color: .clear, location: 1.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 180
            )
            .frame(width: 320, height: 320)
            .blur(radius: 60)
            
            VStack(spacing: 0) {
                // TOP BAR
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Text("←")
                                .font(.system(size: 16))
                            Text("back")
                                .font(.custom("DMMono-Regular", size: 9.5))
                        }
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().stroke(Color.white.opacity(0.06), lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // SHAPE VISUALIZATION
                VStack(spacing: 24) {
                    HStack(spacing: 0) {
                        // Artist Shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true)
                                .frame(width: 72, height: 72)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .offset(x: electricPulse ? CGFloat.random(in: -1.5...1.5) : 0, y: electricPulse ? CGFloat.random(in: -1.5...1.5) : 0)
                            
                            Text(post.artist)
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.22))
                        }
                        
                        // Bridge Line with Electric Arcs
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
                            
                            // ELECTRIC SPARK (Arcing effect)
                            if electricPulse {
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: 0))
                                    for i in 1...10 {
                                        path.addLine(to: CGPoint(x: CGFloat(i) * 12, y: CGFloat.random(in: -4...4)))
                                    }
                                }
                                .stroke(Color.white.opacity(0.7), lineWidth: 0.6)
                                .frame(width: 120, height: 1)
                                .transition(.opacity)
                            }
                            
                            // Travelling Dot
                            Circle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 8, height: 8)
                                .offset(x: -60 + (120 * dotPosition))
                                .opacity(dotPosition > 0.05 && dotPosition < 0.95 ? 1 : 0)
                        }
                        .frame(width: 120).padding(.horizontal, 10)
                        
                        // Fan Shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: userMood, color: userMood.color, isLarge: true)
                                .frame(width: 72, height: 72)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .offset(x: electricPulse ? CGFloat.random(in: -1.5...1.5) : 0, y: electricPulse ? CGFloat.random(in: -1.5...1.5) : 0)
                                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.5), value: isBreathing)
                            
                            Text("You")
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.22))
                        }
                    }
                    
                    // Meet Labels
                    HStack {
                        Text(post.mood.uppercased())
                            .font(.custom("DMMono-Regular", size: 8))
                            .kerning(1.2)
                            .foregroundColor(post.themeColor.opacity(0.55))
                        Spacer()
                        Text("meets")
                            .font(.custom("DMMono-Regular", size: 7))
                            .foregroundColor(.white.opacity(0.15))
                        Spacer()
                        Text(userMood.displayName.uppercased())
                            .font(.custom("DMMono-Regular", size: 8))
                            .kerning(1.2)
                            .foregroundColor(userMood.color.opacity(0.55))
                    }
                    .frame(width: 260)
                }
                .padding(.bottom, 40)
                
                // CONNECTION TEXT
                VStack(spacing: 36) {
                    VStack(spacing: 14) {
                        Text("\(post.artist) shared \(post.mood).\nYou felt \(moodsMatch ? "the same" : "something different") —")
                            .font(.custom("Lora-Italic", size: 13.5))
                            .foregroundColor(.white.opacity(0.45))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                        
                        Text("“\(feeling)”")
                            .font(.custom("Lora-Italic", size: 19))
                            .foregroundColor(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 260)
                            .padding(.top, 6)
                        
                        Text("you + \(randomOthers) others felt something \(userMood.displayName) here")
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .kerning(0.8)
                            .foregroundColor(.white.opacity(0.2))
                    }
                    
                    VStack(spacing: 18) {
                        Rectangle().fill(Color.white.opacity(0.08)).frame(width: 44, height: 1)
                        
                        Text(moodsMatch ? "You both felt \(userMood.displayName). You're not alone." : "\(post.artist)'s \(post.mood) unlocked your \(userMood.displayName). That's a real connection.")
                            .font(.custom("Lora-Italic", size: 12.5))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 210)
                    }
                }
                .opacity(textOpacity)
                
                Spacer()
                Spacer() // Extra spacer to push it up slightly from the absolute bottom
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { isBreathing = true }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: false)) { dotPosition = 1.0 }
            withAnimation(.easeIn(duration: 0.8).delay(0.4)) { textOpacity = 1.0 }
            
            // Electric Arc Timer
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if Double.random(in: 0...1) > 0.85 {
                    electricPulse = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { electricPulse = false }
                }
            }
            
            // Dot Reset Loop
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
                dotPosition = 0.0
                withAnimation(.easeInOut(duration: 2.4)) { dotPosition = 1.0 }
            }
        }
    }
}
