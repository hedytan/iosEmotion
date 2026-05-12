import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: PostStore
    @Binding var selectedTab: Int
    @State private var rotation: Double = 0
    
    let phrases = [
        "echoes of shared solitude",
        "where distance dissolves",
        "vibrating at the same frequency",
        "the silence between notes",
        "artist and fan, one soul"
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // BACKGROUND AMBIENT GLOW
            RadialGradient(colors: [Color.white.opacity(0.04), .clear], center: .center, startRadius: 0, endRadius: 350)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    // ROTATING TEXT ORBIT
                    ZStack {
                        ForEach(0..<phrases.count, id: \.self) { index in
                            Text(phrases[index])
                                .font(.custom("DMMono-Regular", size: 11))
                                .kerning(1.5)
                                .foregroundColor(.white.opacity(0.18))
                                .offset(y: -160) // Slightly larger orbit
                                .rotationEffect(.degrees(Double(index) * (360.0 / Double(phrases.count))))
                        }
                    }
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                    
                    // CENTRAL WELCOME
                    VStack(spacing: 12) {
                        Text("welcome")
                            .font(.custom("Lora-Italic", size: 22))
                            .italic()
                            .foregroundColor(.white.opacity(0.45))
                        
                        Text("resonance")
                            .font(.custom("Lora-Italic", size: 52))
                            .italic()
                            .foregroundColor(.white)
                    }
                }
                .offset(y: 40) // Move the entire animation down
                
                Spacer()
                
                // START BUTTON
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        store.hasCompletedOnboarding = true
                        selectedTab = 0
                    }
                }) {
                    VStack(spacing: 16) {
                        Text("start new idea")
                            .font(.custom("DMMono-Regular", size: 11.5))
                            .kerning(1.6)
                            .foregroundColor(.white)
                            .padding(.horizontal, 44)
                            .padding(.vertical, 15)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                        
                        Text("tap to enter the void")
                            .font(.custom("DMMono-Regular", size: 9.5))
                            .foregroundColor(.white.opacity(0.15))
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    OnboardingView(selectedTab: .constant(0))
        .environmentObject(PostStore())
}
