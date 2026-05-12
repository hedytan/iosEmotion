import SwiftUI

struct ConnectionView: View {
    @Environment(\.dismiss) var dismiss
    var artistName: String
    var artistMood: String
    var artistMoodType: Post.MoodType
    var artistMoodColor: Color
    var fanFeeling: String
    var fanMoodType: Post.MoodType = .tender
    var fanMoodColor: Color = Color(hex: "d890b8")
    
    @State private var isBreathing = false
    @State private var dotPosition: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Color(hex: "07060a").ignoresSafeArea()
            
            RadialGradient(
                stops: [
                    .init(color: artistMoodColor.opacity(0.06), location: 0),
                    .init(color: fanMoodColor.opacity(0.04), location: 0.5),
                    .init(color: .clear, location: 1.0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 110
            )
            .frame(width: 220, height: 220)
            .blur(radius: 30)
            
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    VStack(spacing: 12) {
                        MoodShapeView(type: artistMoodType, color: artistMoodColor)
                            .frame(width: 56, height: 56)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                        
                        Text(artistName)
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        artistMoodColor.opacity(0.4),
                                        .white.opacity(0.06),
                                        fanMoodColor.opacity(0.4)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 100, height: 1)
                        
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .offset(x: -50 + (100 * dotPosition))
                            .opacity(dotPosition < 0.1 || dotPosition > 0.9 ? 0 : 1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 12) {
                        MoodShapeView(type: fanMoodType, color: fanMoodColor)
                            .frame(width: 56, height: 56)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.5), value: isBreathing)
                        
                        Text("You")
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(.white.opacity(0.2))
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        isBreathing = true
                    }
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        dotPosition = 1.0
                    }
                }
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("\(artistName) shared a moment of \(artistMood). You felt —")
                        .font(.custom("Lora-Italic", size: 13))
                        .italic()
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                    
                    Text(fanFeeling)
                        .font(.custom("Lora-Italic", size: 15))
                        .italic()
                        .foregroundColor(.white.opacity(0.82))
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                    
                    Text("1,247 others felt the same way")
                        .font(.custom("DMMono-Regular", size: 8))
                        .kerning(1.0)
                        .foregroundColor(.white.opacity(0.18))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 40, height: 1)
                
                Spacer()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("WANT TO SHARE YOURS?")
                            .font(.custom("DMMono-Regular", size: 8))
                            .kerning(1.4)
                            .foregroundColor(.white.opacity(0.15))
                        
                        Text("What does this moment unlock in you?")
                            .font(.custom("Lora-Italic", size: 12))
                            .italic()
                            .foregroundColor(.white.opacity(0.3))
                            .frame(maxWidth: 180)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("← back to feed")
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(1.2)
                            .foregroundColor(.white.opacity(0.25))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
    }
}
