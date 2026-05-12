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
            RadialGradient(colors: [Color.white.opacity(0.03), .clear], center: .center, startRadius: 0, endRadius: 300)
                .ignoresSafeArea()
            
            VStack(spacing: 80) {
                ZStack {
                    // ROTATING TEXT ORBIT
                    ZStack {
                        ForEach(0..<phrases.count, id: \.self) { index in
                            Text(phrases[index])
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.2)
                                .foregroundColor(.white.opacity(0.15))
                                .offset(y: -140)
                                .rotationEffect(.degrees(Double(index) * (360.0 / Double(phrases.count))))
                        }
                    }
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                    
                    // CENTRAL WELCOME
                    VStack(spacing: 8) {
                        Text("welcome")
                            .font(.custom("Lora-Italic", size: 16))
                            .italic()
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text("resonance")
                            .font(.custom("Lora-Italic", size: 42))
                            .italic()
                            .foregroundColor(.white)
                    }
                }
                
                // START BUTTON
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        store.hasCompletedOnboarding = true
                        selectedTab = 0
                    }
                }) {
                    VStack(spacing: 12) {
                        Text("start new idea")
                            .font(.custom("DMMono-Regular", size: 11))
                            .kerning(1.5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        
                        Text("tap to enter the void")
                            .font(.custom("DMMono-Regular", size: 7))
                            .foregroundColor(.white.opacity(0.12))
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView(selectedTab: .constant(0))
        .environmentObject(PostStore())
}
