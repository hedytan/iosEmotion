import SwiftUI

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    var post: Post
    var onResonate: (String) -> Void
    
    @State private var isBreathing = false
    @State private var selectedOption: Int = 1
    
    var body: some View {
        ZStack {
            Color(hex: "07060a").ignoresSafeArea()
            
            // Ambient Background Glow (Top-Left)
            Circle()
                .fill(post.moodColor.opacity(0.06))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button(action: { dismiss() }) {
                        Text("← back")
                            .font(.custom("DMMono-Regular", size: 9))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        // 1. Artist Row
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.artist)
                                    .font(.custom("DMMono-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("3 days ago · \(post.song)")
                                    .font(.custom("DMMono-Regular", size: 8))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.top, 24)
                        
                        // 2. Large Mood Shape with Breathing Animation
                        ZStack {
                            Circle()
                                .fill(post.moodColor.opacity(0.2))
                                .frame(width: 140, height: 140)
                                .blur(radius: 40)
                            
                            MoodShapeView(type: post.moodType, color: post.moodColor)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                                .frame(width: 110, height: 110)
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                                isBreathing = true
                            }
                        }
                        
                        // 3. Mood Name
                        Text(post.mood.uppercased())
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(2.5)
                            .foregroundColor(post.moodColor.opacity(0.5))
                            .padding(.top, -10)
                        
                        // 4. Quote
                        Text(post.quote)
                            .font(.custom("Lora-Italic", size: 15))
                            .italic()
                            .foregroundColor(.white.opacity(0.82))
                            .lineSpacing(10)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                        
                        // 5. Song Name
                        Text("\(post.song) · 2008")
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(.gray)
                            .padding(.top, -10)
                        
                        // 6. Resonance Section
                        VStack(spacing: 20) {
                            Text("how did this feel?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.5)
                                .foregroundColor(.gray)
                            
                            VStack(spacing: 12) {
                                Button(action: { onResonate("felt this in my chest") }) {
                                    ResonanceOptionRow(label: "felt this in my chest", count: "1.2k", isSelected: selectedOption == 1, moodColor: post.moodColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { onResonate("took me somewhere else") }) {
                                    ResonanceOptionRow(label: "took me somewhere else", count: "890", isSelected: selectedOption == 2, moodColor: post.moodColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { onResonate("reminds me of someone") }) {
                                    ResonanceOptionRow(label: "reminds me of someone", count: "654", isSelected: selectedOption == 3, moodColor: post.moodColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: { onResonate("can't explain it") }) {
                                    ResonanceOptionRow(label: "can't explain it", count: "432", isSelected: selectedOption == 4, moodColor: post.moodColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ResonanceOptionRow: View {
    var label: String
    var count: String
    var isSelected: Bool
    var moodColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(isSelected ? moodColor : Color.white.opacity(0.2))
                .frame(width: 6, height: 6)
            
            Text(label)
                .font(.custom("Lora-Italic", size: 11))
                .italic()
                .foregroundColor(.white.opacity(isSelected ? 0.78 : 0.4))
            
            Spacer()
            
            Text(count)
                .font(.custom("DMMono-Regular", size: 8))
                .foregroundColor(isSelected ? moodColor.opacity(0.6) : .gray)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(isSelected ? moodColor.opacity(0.04) : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? moodColor.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
        )
        .overlay(
            HStack {
                if isSelected {
                    Rectangle()
                        .fill(moodColor)
                        .frame(width: 2)
                        .padding(.vertical, 12)
                }
                Spacer()
            }
        )
    }
}
