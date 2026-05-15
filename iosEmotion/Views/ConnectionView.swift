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
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT GLOW (Floating behind content)
            RadialGradient(
                colors: [
                    post.themeColor.opacity(0.20),
                    userMood.color.opacity(0.10),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 180
            )
            .frame(width: 320, height: 320)
            .blur(radius: 40)
            .offset(y: -140) // Aligning roughly behind the shapes row
            
            VStack(spacing: 0) {
                Spacer()
                
                // 1. SHAPES + LINE ROW
                HStack(spacing: 0) {
                    // Artist Side
                    VStack(spacing: 12) {
                        MoodShape(type: post.moodType)
                            .fill(
                                RadialGradient(
                                    colors: [post.themeColor.opacity(0.20), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 44
                                )
                            )
                            .overlay(
                                MoodShape(type: post.moodType)
                                    .stroke(post.themeColor.opacity(0.55), lineWidth: 1.1)
                            )
                            .frame(width: 68, height: 68)
                            .scaleEffect(breathing ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathing)
                        
                        Text(post.artist)
                            .font(.custom("DMMono-Regular", size: 11))
                            .foregroundColor(.white.opacity(0.25))
                    }
                    
                    // Connection Bridge
                    ZStack {
                        GeometryReader { lineGeo in
                            let lineWidth = lineGeo.size.width
                            
                            ZStack {
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
                                .position(x: lineWidth/2, y: lineGeo.size.height/2)
                                
                                // Traveling Spark
                                Circle()
                                    .fill(Color.white.opacity(0.55))
                                    .frame(width: 7, height: 7)
                                    .position(x: lineWidth/2, y: lineGeo.size.height/2)
                                    .offset(x: dotOffset)
                                    .onAppear {
                                        dotOffset = -lineWidth/2
                                        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: false)) {
                                            dotOffset = lineWidth/2
                                        }
                                    }
                            }
                        }
                    }
                    .frame(height: 68)
                    
                    // Fan Side
                    VStack(spacing: 12) {
                        MoodShape(type: userMood)
                            .fill(
                                RadialGradient(
                                    colors: [userMood.color.opacity(0.20), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 44
                                )
                            )
                            .overlay(
                                MoodShape(type: userMood)
                                    .stroke(userMood.color.opacity(0.55), lineWidth: 1.1)
                            )
                            .frame(width: 68, height: 68)
                            .scaleEffect(breathing ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 4).delay(0.5).repeatForever(autoreverses: true), value: breathing)
                        
                        Text("You")
                            .font(.custom("DMMono-Regular", size: 11))
                            .foregroundColor(.white.opacity(0.25))
                    }
                }
                .padding(.bottom, 20)
                
                // 2. MOOD NAMES ROW
                HStack {
                    Text(post.mood.uppercased())
                        .font(.custom("DMMono-Regular", size: 11))
                        .foregroundColor(post.themeColor.opacity(0.6))
                    Spacer()
                    Text("meets")
                        .font(.custom("DMMono-Regular", size: 10))
                        .foregroundColor(.white.opacity(0.2))
                    Spacer()
                    Text(userMood.displayName.uppercased())
                        .font(.custom("DMMono-Regular", size: 11))
                        .foregroundColor(userMood.color.opacity(0.6))
                }
                .frame(width: 240)
                .padding(.bottom, 18)
                
                // 3. INTRO TEXT
                Text("\(post.artist) shared \(post.mood).\nYou felt \(moodsMatch ? "the same" : "something different") —")
                    .font(.custom("Lora-Italic", size: 16))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.bottom, 16)
                
                // 4. FEELING TEXT
                Text("“\(feeling)”")
                    .font(.custom("Lora-Italic", size: 24))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
                    .padding(.bottom, 16)
                
                // 5. COUNT TEXT
                Text("you + \(randomOthers) others felt something \(userMood.displayName) here")
                    .font(.custom("DMMono-Regular", size: 11))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.bottom, 26)
                
                // 6. DIVIDER
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 1)
                    .padding(.bottom, 22)
                
                // 7. INSIGHT TEXT
                Text(moodsMatch ? "You both felt \(userMood.displayName). You're not alone." : "\(post.artist)'s \(post.mood) unlocked your \(userMood.displayName). That's a real connection.")
                    .font(.custom("Lora-Italic", size: 15))
                    .foregroundColor(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 220)
                
                Spacer()
            }
            .padding(.horizontal, 28)
            
            // GLASS BACK BUTTON
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
                    .padding(.top, 16)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            breathing = true
        }
        .navigationBarBackButtonHidden(true)
    }
}
