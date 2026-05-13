import SwiftUI

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    var post: Post
    var onResonate: (AnyHashable) -> Void
    
    @State private var isBreathing = false
    @State private var selectedOptionID: UUID? = nil
    
    // Custom Echo States
    @State private var isWritingEcho = false
    @State private var customEchoText = ""
    @State private var selectedUserMood: Post.MoodType = .tender
    
    var body: some View {
        ZStack {
            Color(hex: "08070B").ignoresSafeArea()
            
            // ATTACHED IMAGE BACKGROUND
            if let image = post.attachedImage {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .overlay(post.themeColor.opacity(0.35))
                        .opacity(0.4)
                }
                .ignoresSafeArea()
            }
            
            // Ambient Background Glow
            Circle()
                .fill(post.themeColor.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -120, y: -200)
            
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left").font(.system(size: 16)).foregroundColor(.white.opacity(0.4))
                    }
                    Spacer()
                    Text("moment").font(.custom("DMMono-Regular", size: 9)).kerning(1.8).foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Circle().frame(width: 16, height: 16).opacity(0)
                }
                .padding(.horizontal, 24).padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 48) {
                        VStack(spacing: 8) {
                            Text(post.artist).font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.85))
                            Text(post.song).font(.custom("Lora-Italic", size: 12)).foregroundColor(.white.opacity(0.35))
                        }
                        .padding(.top, 24)
                        
                        MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true, customMood: post.customMood)
                            .frame(width: 120, height: 120)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { isBreathing = true }
                            }
                        
                        Text(post.mood.uppercased()).font(.custom("DMMono-Regular", size: 9)).kerning(2).foregroundColor(post.themeColor.opacity(0.45))
                        
                        Text("“\(post.quote)”")
                            .font(.custom("Lora-Italic", size: 24))
                            .italic().multilineTextAlignment(.center).foregroundColor(.white.opacity(0.9)).padding(.horizontal, 40).lineSpacing(6)
                        
                        // RESONANCE SECTION
                        VStack(alignment: .leading, spacing: 20) {
                            Text("RESONANCE").font(.custom("DMMono-Regular", size: 8)).kerning(1.6).foregroundColor(.white.opacity(0.18)).padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                // Dynamic Preset Options
                                ForEach(post.resonanceOptions) { option in
                                    ResonanceRow(
                                        label: option.label,
                                        count: formatCount(option.count),
                                        isSelected: selectedOptionID == option.id,
                                        moodColor: post.themeColor
                                    ) {
                                        selectPreset(option)
                                    }
                                }
                                
                                // THE ECHO COMPOSER
                                if !isWritingEcho {
                                    Button(action: { withAnimation(.spring()) { isWritingEcho = true } }) {
                                        HStack {
                                            Image(systemName: "plus").font(.system(size: 10))
                                            Text("write your own echo...")
                                                .font(.custom("Lora-Italic", size: 12))
                                                .italic()
                                            Spacer()
                                        }
                                        .foregroundColor(post.themeColor.opacity(0.6))
                                        .padding(.horizontal, 24).padding(.vertical, 20)
                                        .background(Color.white.opacity(0.01))
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 18) {
                                        TextField("", text: $customEchoText, prompt: Text("type your feeling...").foregroundColor(.white.opacity(0.15)))
                                            .font(.custom("Lora-Italic", size: 14))
                                            .foregroundColor(.white.opacity(0.85))
                                            .padding(14)
                                            .background(Color.white.opacity(0.03))
                                            .cornerRadius(12)
                                        
                                        // User Mood Selection
                                        HStack(spacing: 16) {
                                            ForEach(Post.MoodType.allCases.filter { $0 != .custom }, id: \.self) { mood in
                                                Button(action: { selectedUserMood = mood }) {
                                                    MoodShapeView(type: mood, color: mood.color)
                                                        .frame(width: 32, height: 32)
                                                        .opacity(selectedUserMood == mood ? 1.0 : 0.25)
                                                        .scaleEffect(selectedUserMood == mood ? 1.2 : 1.0)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        
                                        Button(action: sendCustomResonance) {
                                            Text("RESONATE")
                                                .font(.custom("DMMono-Regular", size: 9))
                                                .kerning(1.5)
                                                .foregroundColor(customEchoText.isEmpty ? .white.opacity(0.2) : .black)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 14)
                                                .background(customEchoText.isEmpty ? post.themeColor.opacity(0.2) : post.themeColor.opacity(0.9))
                                                .cornerRadius(10)
                                        }
                                        .disabled(customEchoText.isEmpty)
                                    }
                                    .padding(24)
                                    .background(Color.white.opacity(0.015))
                                }
                            }
                        }
                        .padding(.top, 24)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
    
    private func selectPreset(_ option: ResonanceOption) {
        withAnimation(.spring()) { selectedOptionID = option.id }
        
        // INCREMENT IN STORE
        store.incrementResonance(for: post.id, optionID: option.id)
        
        let connection = ResonanceConnection(post: post, feeling: option.label, userMood: .tender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onResonate(connection)
        }
    }
    
    private func sendCustomResonance() {
        let connection = ResonanceConnection(post: post, feeling: customEchoText, userMood: selectedUserMood)
        onResonate(connection)
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
            .padding(.horizontal, 24).padding(.vertical, 18)
            .background(isSelected ? moodColor.opacity(0.12) : Color.white.opacity(0.02))
        }
    }
}
