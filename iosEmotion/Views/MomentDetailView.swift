import SwiftUI

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    var post: Post
    var onResonate: (String) -> Void
    
    @State private var isBreathing = false
    @State private var selectedOption: String? = nil
    
    var body: some View {
        ZStack {
            Color(hex: "08070B").ignoresSafeArea()
            
            // Ambient Background Glow (Top-Left)
            Circle()
                .fill(post.themeColor.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -120, y: -200)
            
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Spacer()
                    Text("moment")
                        .font(.custom("DMMono-Regular", size: 9))
                        .kerning(0.2 * 9)
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Circle().frame(width: 16, height: 16).opacity(0) // Balance
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 48) {
                        
                        // 1. Artist & Song Header
                        VStack(spacing: 8) {
                            Text(post.artist)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                            
                            Text(post.song)
                                .font(.custom("Lora-Italic", size: 12))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .padding(.top, 24)
                        
                        // 2. Large Mood Shape
                        MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true, customMood: post.customMood)
                            .frame(width: 120, height: 120)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                    isBreathing = true
                                }
                            }
                        
                        // 3. Mood Name
                        Text(post.mood.uppercased())
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(0.22 * 9)
                            .foregroundColor(post.themeColor.opacity(0.45))
                        
                        // 4. The Quote
                        Text("“\(post.quote)”")
                            .font(.custom("Lora-Italic", size: 24))
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 40)
                            .lineSpacing(6)
                        
                        // 5. Resonance Interaction
                        VStack(alignment: .leading, spacing: 20) {
                            Text("RESONANCE")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(0.2 * 8)
                                .foregroundColor(.white.opacity(0.18))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ResonanceRow(label: "felt this in my chest", count: "1.2k", isSelected: selectedOption == "felt this in my chest", moodColor: post.themeColor) { select("felt this in my chest") }
                                ResonanceRow(label: "took me somewhere else", count: "890", isSelected: selectedOption == "took me somewhere else", moodColor: post.themeColor) { select("took me somewhere else") }
                                ResonanceRow(label: "reminds me of someone", count: "654", isSelected: selectedOption == "reminds me of someone", moodColor: post.themeColor) { select("reminds me of someone") }
                                ResonanceRow(label: "can't explain it", count: "432", isSelected: selectedOption == "can't explain it", moodColor: post.themeColor) { select("can't explain it") }
                            }
                        }
                        .padding(.top, 24)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }
    
    private func select(_ label: String) {
        withAnimation(.spring()) {
            selectedOption = label
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onResonate(label)
        }
    }
}

struct ResonanceRow: View {
    let label: String
    let count: String
    let isSelected: Bool
    let moodColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.custom("DMMono-Regular", size: 10))
                    .foregroundColor(.white.opacity(isSelected ? 0.9 : 0.45))
                
                Spacer()
                
                Text(count)
                    .font(.custom("DMMono-Regular", size: 9))
                    .foregroundColor(isSelected ? moodColor : .white.opacity(0.15))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(isSelected ? moodColor.opacity(0.12) : Color.white.opacity(0.02))
        }
    }
}
