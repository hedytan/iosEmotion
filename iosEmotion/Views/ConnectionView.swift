import SwiftUI

struct ConnectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    var post: Post
    var feeling: String
    var userMood: Post.MoodType
    
    @State private var breathing = false
    @State private var dotOffset: CGFloat = 0
    
    var moodsMatch: Bool { post.moodType == userMood }
    let randomOthers = Int.random(in: 300...1000)
    
    var body: some View {
        GeometryReader { outerGeometry in
            ZStack {
                Color(hex: "07060A").ignoresSafeArea()
                
                // AMBIENT GLOW (Behind everything)
                RadialGradient(
                    colors: [
                        post.themeColor.opacity(0.22),
                        userMood.color.opacity(0.10),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .position(x: outerGeometry.size.width / 2, y: outerGeometry.size.height * 0.35)
                
                // MAIN CONTENT (Vertically Centered)
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // 1. SHAPES + LINE ROW
                        GeometryReader { lineGeo in
                            HStack(spacing: 0) {
                                // Artist Shape
                                VStack(spacing: 12) {
                                    MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true)
                                        .frame(width: 68, height: 68)
                                        .scaleEffect(breathing ? 1.05 : 1.0)
                                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathing)
                                    
                                    Text(post.artist)
                                        .font(.custom("DMMono-Regular", size: 8))
                                        .foregroundColor(.white.opacity(0.2))
                                }
                                
                                // Connection Line with Traveling Dot
                                ZStack(alignment: .leading) {
                                    LinearGradient(
                                        colors: [
                                            post.themeColor.opacity(0.5),
                                            Color.white.opacity(0.05),
                                            userMood.color.opacity(0.5)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(height: 1)
                                    .padding(.horizontal, 12)
                                    
                                    // Traveling Dot
                                    Circle()
                                        .fill(Color.white.opacity(0.55))
                                        .frame(width: 7, height: 7)
                                        .offset(x: dotOffset)
                                        .onAppear {
                                            let lineWidth = lineGeo.size.width - 136 // Subtracting shape widths (68 * 2)
                                            dotOffset = 68 // Start at end of first shape
                                            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: false)) {
                                                dotOffset = 68 + lineWidth
                                            }
                                        }
                                }
                                
                                // Fan Shape
                                VStack(spacing: 12) {
                                    MoodShapeView(type: userMood, color: userMood.color, isLarge: true)
                                        .frame(width: 68, height: 68)
                                        .scaleEffect(breathing ? 1.05 : 1.0)
                                        .animation(.easeInOut(duration: 4).delay(0.5).repeatForever(autoreverses: true), value: breathing)
                                    
                                    Text("You")
                                        .font(.custom("DMMono-Regular", size: 8))
                                        .foregroundColor(.white.opacity(0.2))
                                }
                            }
                        }
                        .frame(height: 88)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                        
                        // 2. MOOD NAMES ROW
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
                        .frame(width: 240)
                        .padding(.bottom, 18)
                        
                        // 3. INTRO TEXT
                        Text("\(post.artist) shared \(post.mood).\nYou felt \(moodsMatch ? "the same" : "something different") —")
                            .font(.custom("Lora-Italic", size: 13))
                            .foregroundColor(.white.opacity(0.42))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.bottom, 12)
                        
                        // 4. FEELING TEXT
                        Text("“\(feeling)”")
                            .font(.custom("Lora-Italic", size: 18))
                            .foregroundColor(.white.opacity(0.88))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 280)
                            .padding(.bottom, 16)
                        
                        // 5. COUNT TEXT
                        Text("you + \(randomOthers) others felt something \(userMood.displayName) here")
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(.white.opacity(0.18))
                            .padding(.bottom, 22)
                        
                        // 6. DIVIDER
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 36, height: 1)
                            .padding(.bottom, 18)
                        
                        // 7. INSIGHT TEXT
                        Text(moodsMatch ? "You both felt \(userMood.displayName). You're not alone." : "\(post.artist)'s \(post.mood) unlocked your \(userMood.displayName). That's a real connection.")
                            .font(.custom("Lora-Italic", size: 12))
                            .foregroundColor(.white.opacity(0.26))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 220)
                    }
                    
                    Spacer()
                }
                
                // GLASS BACK BUTTON (Kept as requested)
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                Circle()
                                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.82))
                                    .offset(x: -1)
                            }
                            .frame(width: 36, height: 36)
                            .shadow(color: .black.opacity(0.3), radius: 12)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 62)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onAppear {
                breathing = true
            }
        }
        .ignoresSafeArea()
    }
}
