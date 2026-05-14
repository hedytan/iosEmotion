import SwiftUI

struct ConnectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    var post: Post
    var feeling: String
    var userMood: Post.MoodType
    
    var moodsMatch: Bool { post.moodType == userMood }
    let randomOthers = Int.random(in: 300...1000)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT GLOW (Completely Static)
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
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2.5)
            
            VStack(spacing: 0) {
                Spacer()
                
                // SHAPE VISUALIZATION (Completely Static)
                VStack(spacing: 24) {
                    HStack(spacing: 0) {
                        // Artist Shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true)
                                .frame(width: 72, height: 72)
                            
                            Text(post.artist)
                                .font(.custom("DMMono-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        
                        // Bridge Line (Pure Horizon)
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
                            
                            // Static Connection Point (Centered)
                            Circle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 8, height: 8)
                        }
                        .frame(width: 120).padding(.horizontal, 10)
                        
                        // Fan Shape
                        VStack(spacing: 12) {
                            MoodShapeView(type: userMood, color: userMood.color, isLarge: true)
                                .frame(width: 72, height: 72)
                            
                            Text("You")
                                .font(.custom("DMMono-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.25))
                        }
                    }
                    
                    // Meet Labels
                    HStack {
                        Text(post.mood.uppercased())
                            .font(.custom("DMMono-Regular", size: 10))
                            .kerning(1.2)
                            .foregroundColor(post.themeColor.opacity(0.6))
                        Spacer()
                        Text("meets")
                            .font(.custom("DMMono-Regular", size: 9))
                            .foregroundColor(.white.opacity(0.2))
                        Spacer()
                        Text(userMood.displayName.uppercased())
                            .font(.custom("DMMono-Regular", size: 10))
                            .kerning(1.2)
                            .foregroundColor(userMood.color.opacity(0.6))
                    }
                    .frame(width: 260)
                }
                .padding(.bottom, 40)
                
                // CONNECTION TEXT (Instant Appearance)
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
                            .font(.custom("DMMono-Regular", size: 10.5))
                            .kerning(0.8)
                            .foregroundColor(.white.opacity(0.25))
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
                
                Spacer()
                Spacer()
            }
            
            // GLASS CAPSULE BACK BUTTON
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("feed")
                        .font(.custom("DMMono-Regular", size: 10))
                        .kerning(0.8)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
            }
            .padding(.leading, 16)
            .padding(.top, 54)
        }
        .ignoresSafeArea()
    }
}
