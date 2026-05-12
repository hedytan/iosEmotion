import SwiftUI

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    var post: Post
    var onResonate: (String) -> Void
    
    @State private var isBreathing = false
    @State private var selectedOption: String? = nil
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // Ambient Background Glow (Top-Left)
            Circle()
                .fill(post.moodType.color.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -120, y: -200)
            
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button(action: { dismiss() }) {
                        Text("‹ feed")
                            .font(.custom("DMMono-Regular", size: 9))
                            .foregroundColor(.white.opacity(0.25))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 1. Artist Row
                        HStack(spacing: 12) {
                            Circle()
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                .background(Circle().fill(Color.white.opacity(0.04)))
                                .frame(width: 34, height: 34)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.artist)
                                    .font(.system(size: 13, weight: .medium)) // SF Pro
                                    .foregroundColor(.white.opacity(0.82))
                                
                                Text("\(post.daysAgo) days ago · \(post.song)")
                                    .font(.custom("DMMono-Regular", size: 8))
                                    .foregroundColor(.white.opacity(0.22))
                            }
                            Spacer()
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                        
                        // 2. Large Mood Shape
                        MoodShapeView(type: post.moodType, color: post.moodType.color, isLarge: true)
                            .frame(width: 120, height: 120)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                                    isBreathing = true
                                }
                            }
                            .padding(.vertical, 32)
                        
                        // 3. Mood Name
                        Text(post.moodType.displayName.uppercased())
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(0.22 * 9)
                            .foregroundColor(post.moodType.color.opacity(0.45))
                            .padding(.bottom, 18)
                        
                        // 4. Quote
                        Text(post.quote)
                            .font(.custom("Lora-Italic", size: 16))
                            .italic()
                            .foregroundColor(.white.opacity(0.82))
                            .lineSpacing(16 * 1.75 - 16)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        // 5. Song Name
                        Text("\(post.song) · \(post.year)")
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(0.08 * 9)
                            .foregroundColor(.white.opacity(0.20))
                            .padding(.bottom, 32)
                        
                        // 6. Resonance Section
                        VStack(spacing: 12) {
                            Text("how did this feel?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(0.16 * 8)
                                .foregroundColor(.white.opacity(0.15))
                                .padding(.bottom, 12)
                            
                            VStack(spacing: 8) {
                                ResonanceRow(label: "felt this in my chest", count: "1.2k", isSelected: selectedOption == "felt this in my chest", moodColor: post.moodType.color) { select("felt this in my chest") }
                                ResonanceRow(label: "took me somewhere else", count: "890", isSelected: selectedOption == "took me somewhere else", moodColor: post.moodType.color) { select("took me somewhere else") }
                                ResonanceRow(label: "reminds me of someone", count: "654", isSelected: selectedOption == "reminds me of someone", moodColor: post.moodType.color) { select("reminds me of someone") }
                                ResonanceRow(label: "can't explain it", count: "432", isSelected: selectedOption == "can't explain it", moodColor: post.moodType.color) { select("can't explain it") }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func select(_ feeling: String) {
        selectedOption = feeling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onResonate(feeling)
        }
    }
}

struct ResonanceRow: View {
    var label: String
    var count: String
    var isSelected: Bool
    var moodColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Dot
                Circle()
                    .fill(isSelected ? moodColor : Color.white.opacity(0.10))
                    .frame(width: 7, height: 7)
                
                Text(label)
                    .font(.custom("Lora-Italic", size: 12.5))
                    .italic()
                    .foregroundColor(.white.opacity(isSelected ? 0.80 : 0.38))
                
                Spacer()
                
                Text(count)
                    .font(.custom("DMMono-Regular", size: 8.5))
                    .foregroundColor(.white.opacity(isSelected ? 0.60 : 0.15))
                    .foregroundColor(isSelected ? moodColor : .white)
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .background(isSelected ? moodColor.opacity(0.04) : Color.white.opacity(0.02))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? moodColor.opacity(0.50) : Color.white.opacity(0.06), lineWidth: 1)
            )
            .overlay(
                HStack {
                    if isSelected {
                        Rectangle()
                            .fill(moodColor)
                            .frame(width: 2.5)
                            .padding(.vertical, 14)
                    }
                    Spacer()
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
