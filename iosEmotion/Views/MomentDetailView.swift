import SwiftUI

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    var post: Post
    var onResonate: (ResonanceConnection) -> Void
    
    @State private var isBreathing = false
    @State private var showingWriteSheet = false
    @State private var pulses: [UUID: Bool] = [:]
    @State private var floaters: [UUID: Bool] = [:]
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            // Ambient Glow
            Circle()
                .fill(post.themeColor.opacity(0.10))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: -60, y: -80)
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Text("‹ feed")
                            .font(.custom("DMMono-Regular", size: 9))
                            .foregroundColor(.white.opacity(0.28))
                    }
                    Spacer()
                    Text("···")
                        .font(.custom("DMMono-Regular", size: 9))
                        .foregroundColor(.white.opacity(0.2))
                }
                .padding(.horizontal, 24).padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Artist Row
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.04))
                                    .frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                                Text("◎").font(.system(size: 10)).foregroundColor(.white.opacity(0.4))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.artist)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("now · \(post.song)")
                                    .font(.custom("DMMono-Regular", size: 8))
                                    .foregroundColor(.white.opacity(0.22))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24).padding(.bottom, 32)
                        
                        // Feature Mood Shape
                        ZStack {
                            Circle()
                                .fill(post.themeColor.opacity(0.16))
                                .frame(width: 160, height: 160)
                                .blur(radius: 50)
                            
                            MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true)
                                .frame(width: 120, height: 120)
                                .scaleEffect(isBreathing ? 1.05 : 1.0)
                        }
                        .padding(.bottom, 24)
                        
                        Text(post.mood.uppercased())
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(1.9)
                            .foregroundColor(post.themeColor.opacity(0.45))
                            .padding(.bottom, 15)
                        
                        Text(post.quote)
                            .font(.custom("Lora-Italic", size: 15.5))
                            .foregroundColor(.white.opacity(0.82))
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 9)
                        
                        Text(post.song.uppercased())
                            .font(.custom("DMMono-Regular", size: 9))
                            .kerning(0.7)
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.bottom, 26)
                        
                        // RESONANCE SECTION
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Text("resonance")
                                    .font(.custom("DMMono-Regular", size: 7.5))
                                    .kerning(1.2)
                                    .foregroundColor(.white.opacity(0.2))
                                Spacer()
                                Text("\(formatCount(post.resonanceCount)) total")
                                    .font(.custom("DMMono-Regular", size: 7.5))
                                    .foregroundColor(.white.opacity(0.14))
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 7) {
                                // Write Your Own portal
                                Button(action: { showingWriteSheet = true }) {
                                    HStack(spacing: 0) {
                                        Rectangle().fill(Color.white.opacity(0.08)).frame(width: 2.5)
                                        HStack(spacing: 14) {
                                            ZStack {
                                                Circle().stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [2, 2])).frame(width: 22, height: 22)
                                                Text("✦").font(.system(size: 11)).foregroundColor(.white.opacity(0.3))
                                            }
                                            Text("express it in your own words…")
                                                .font(.custom("Lora-Italic", size: 11.5))
                                                .foregroundColor(.white.opacity(0.22))
                                            Spacer()
                                            Text("›").font(.custom("DMMono-Regular", size: 10)).foregroundColor(.white.opacity(0.14))
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 11)
                                    }
                                    .background(Color.white.opacity(0.025))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                }
                                
                                // Custom Resonances
                                ForEach(post.customResonances) { res in
                                    Button(action: { onResonate(ResonanceConnection(post: post, feeling: res.text, userMood: res.mood)) }) {
                                        HStack(spacing: 0) {
                                            Rectangle().fill(res.mood.color).frame(width: 2.5)
                                            HStack(spacing: 12) {
                                                Circle().fill(res.mood.color).frame(width: 6, height: 6).scaleEffect(1.2)
                                                Text("“\(res.text)”").font(.custom("Lora-Italic", size: 11.5)).foregroundColor(.white.opacity(0.65)).lineLimit(1)
                                                Spacer()
                                                MoodShapeView(type: res.mood, color: res.mood.color).frame(width: 18, height: 18)
                                                Text("you").font(.custom("DMMono-Regular", size: 7.5)).foregroundColor(res.mood.color.opacity(0.5))
                                            }
                                            .padding(.horizontal, 12).padding(.vertical, 11)
                                        }
                                        .background(res.mood.color.opacity(0.03))
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(res.mood.color.opacity(0.2), lineWidth: 1))
                                    }
                                }
                                
                                // Preset Rows
                                ForEach(post.resonanceOptions) { option in
                                    ZStack {
                                        if pulses[option.id] ?? false {
                                            RoundedRectangle(cornerRadius: 12).stroke(option.mood.color, lineWidth: 1).modifier(PulseModifier())
                                        }
                                        
                                        ResonanceListRow(option: option) {
                                            triggerPulse(for: option.id)
                                            store.toggleResonance(for: post.id, optionID: option.id)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                onResonate(ResonanceConnection(post: post, feeling: option.text, userMood: option.mood))
                                            }
                                        }
                                        
                                        if floaters[option.id] ?? false {
                                            Text("+1").font(.custom("DMMono-Regular", size: 10)).foregroundColor(option.mood.color).modifier(FloaterModifier())
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear { withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { isBreathing = true } }
        .sheet(isPresented: $showingWriteSheet) {
            WriteResonanceSheet(post: post) { text, mood in
                store.addCustomResonance(for: post.id, text: text, mood: mood)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onResonate(ResonanceConnection(post: post, feeling: text, userMood: mood))
                }
            }
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000 { return String(format: "%.1fk", Double(count) / 1000.0) }
        return "\(count)"
    }
    
    private func triggerPulse(for id: UUID) {
        pulses[id] = true
        floaters[id] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { pulses[id] = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { floaters[id] = false }
    }
}

struct ResonanceListRow: View {
    var option: ResonanceOption
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Rectangle().fill(option.isSelectedByCurrentUser ? option.mood.color : Color.clear).frame(width: 2.5)
                HStack(spacing: 12) {
                    Circle().fill(option.isSelectedByCurrentUser ? option.mood.color : Color.white.opacity(0.1)).frame(width: 6, height: 6).scaleEffect(option.isSelectedByCurrentUser ? 1.2 : 1.0)
                    Text(option.text).font(.custom("Lora-Italic", size: 12)).foregroundColor(.white.opacity(option.isSelectedByCurrentUser ? 0.78 : 0.35)).frame(maxWidth: .infinity, alignment: .leading)
                    MoodShapeView(type: option.mood, color: option.mood.color).frame(width: 18, height: 18).opacity(option.isSelectedByCurrentUser ? 1 : 0)
                    Text("\(option.count)").font(.custom("DMMono-Regular", size: 8.5)).foregroundColor(option.isSelectedByCurrentUser ? option.mood.color.opacity(0.6) : .white.opacity(0.18))
                }
                .padding(.vertical, 11).padding(.horizontal, 12)
            }
            .background(option.isSelectedByCurrentUser ? option.mood.color.opacity(0.04) : Color.white.opacity(0.02))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(option.isSelectedByCurrentUser ? option.mood.color.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1))
        }
    }
}
