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
            
            // AMBIENT GLOW
            RadialGradient(
                stops: [
                    .init(color: post.themeColor.opacity(0.22), location: 0),
                    .init(color: userMood.color.opacity(0.12), location: 0.5),
                    .init(color: .clear, location: 1.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 140
            )
            .frame(width: 280, height: 280)
            .blur(radius: 40)
            .offset(y: -UIScreen.main.bounds.height/6)
            
            VStack(spacing: 0) {
                Spacer()
                
                // SHAPE VISUALIZATION
                VStack(spacing: 20) {
                    HStack(spacing: 0) {
                        // Artist Shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true)
                                .frame(width: 64, height: 64)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .offset(x: electricPulse ? CGFloat.random(in: -1...1) : 0, y: electricPulse ? CGFloat.random(in: -1...1) : 0)
                            
                            Text(post.artist)
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.2))
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
                                        path.addLine(to: CGPoint(x: CGFloat(i) * 10, y: CGFloat.random(in: -3...3)))
                                    }
                                }
                                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                                .frame(width: 100, height: 1)
                                .offset(x: sparkOffset)
                                .transition(.opacity)
                            }
                            
                            // Travelling Dot
                            Circle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 7, height: 7)
                                .offset(x: -50 + (100 * dotPosition))
                                .opacity(dotPosition > 0.1 && dotPosition < 0.9 ? 1 : 0)
                        }
                        .frame(width: 100).padding(.horizontal, 10)
                        
                        // Fan Shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: userMood, color: userMood.color, isLarge: true)
                                .frame(width: 64, height: 64)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .offset(x: electricPulse ? CGFloat.random(in: -1...1) : 0, y: electricPulse ? CGFloat.random(in: -1...1) : 0)
                                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.5), value: isBreathing)
                            
                            Text("You")
                                .font(.custom("DMMono-Regular", size: 8))
                                .foregroundColor(.white.opacity(0.2))
                        }
                    }
                    
                    // Meet Labels
                    HStack {
                        Text(post.mood.uppercased())
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(post.themeColor.opacity(0.5))
                        Spacer()
                        Text("meets")
                            .font(.custom("DMMono-Regular", size: 7))
                            .foregroundColor(.white.opacity(0.1))
                        Spacer()
                        Text(userMood.displayName.uppercased())
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(userMood.color.opacity(0.5))
                    }
                    .frame(width: 240).padding(.bottom, 18)
                }
                
                // CONNECTION TEXT
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("\(post.artist) shared \(post.mood).\nYou felt \(moodsMatch ? "the same" : "something different") —")
                            .font(.custom("Lora-Italic", size: 13))
                            .foregroundColor(.white.opacity(0.42))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("“\(feeling)”")
                            .font(.custom("Lora-Italic", size: 18))
                            .foregroundColor(.white.opacity(0.88))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 230)
                            .padding(.top, 10)
                        
                        Text("you + \(randomOthers) others felt something \(userMood.displayName) here")
                            .font(.custom("DMMono-Regular", size: 8))
                            .kerning(0.8)
                            .foregroundColor(.white.opacity(0.18))
                            .padding(.top, 4)
                    }
                    
                    VStack(spacing: 16) {
                        Rectangle().fill(Color.white.opacity(0.06)).frame(width: 36, height: 1)
                        
                        Text(moodsMatch ? "You both felt \(userMood.displayName). You're not alone." : "\(post.artist)'s \(post.mood) unlocked your \(userMood.displayName). That's a real connection.")
                            .font(.custom("Lora-Italic", size: 12))
                            .foregroundColor(.white.opacity(0.26))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 190)
                    }
                }
                .opacity(textOpacity)
                
                Spacer()
                
                // Back Button (Repositioned Higher)
                Button(action: { dismiss() }) {
                    Text("← back to feed")
                        .font(.custom("DMMono-Regular", size: 9))
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .background(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .padding(.bottom, 120) // Elevated above the tab bar
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { isBreathing = true }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: false)) { dotPosition = 1.0 }
            withAnimation(.easeIn(duration: 0.8).delay(0.4)) { textOpacity = 1.0 }
            
            // Electric Arc Timer
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if Double.random(in: 0...1) > 0.8 {
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
