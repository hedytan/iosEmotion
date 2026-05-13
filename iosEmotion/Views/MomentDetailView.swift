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
            Color(hex: "08070B").ignoresSafeArea()
            
            // Background Image (Full Bleed Tinted)
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
            
            VStack(spacing: 0) {
                // Top Bar
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
                        // Header Content
                        VStack(spacing: 8) {
                            Text(post.artist).font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.85))
                            Text(post.song).font(.custom("Lora-Italic", size: 12)).foregroundColor(.white.opacity(0.35))
                        }
                        .padding(.top, 24)
                        
                        MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true, customMood: post.customMood)
                            .frame(width: 120, height: 120)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                            .onAppear { withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { isBreathing = true } }
                        
                        Text(post.mood.uppercased()).font(.custom("DMMono-Regular", size: 9)).kerning(2).foregroundColor(post.themeColor.opacity(0.45))
                        
                        Text("“\(post.quote)”")
                            .font(.custom("Lora-Italic", size: 24))
                            .italic().multilineTextAlignment(.center).foregroundColor(.white.opacity(0.9)).padding(.horizontal, 40).lineSpacing(6)
                        
                        // RESONANCE SECTION
                        VStack(alignment: .leading, spacing: 20) {
                            // Section Header
                            HStack {
                                Text("resonance")
                                    .font(.custom("DMMono-Regular", size: 7.5))
                                    .kerning(1.2)
                                    .textCase(.uppercase)
                                    .foregroundColor(.white.opacity(0.2))
                                Spacer()
                                Text("\(formatCount(post.resonanceCount)) total")
                                    .font(.custom("DMMono-Regular", size: 7.5))
                                    .foregroundColor(.white.opacity(0.15))
                            }
                            .padding(.horizontal, 24)
                            
                            // 5 Resonance Rows
                            VStack(spacing: 7) {
                                ForEach(post.resonanceOptions) { option in
                                    ZStack {
                                        // Pulse Ring
                                        if pulses[option.id] ?? false {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(option.mood.color, lineWidth: 1)
                                                .modifier(PulseModifier())
                                        }
                                        
                                        ResonanceListRow(option: option) {
                                            triggerPulse(for: option.id)
                                            store.toggleResonance(for: post.id, optionID: option.id)
                                            if !option.isSelectedByCurrentUser {
                                                let conn = ResonanceConnection(post: post, feeling: option.label, userMood: option.mood)
                                                onResonate(conn)
                                            }
                                        }
                                        
                                        // Floater +1
                                        if floaters[option.id] ?? false {
                                            Text("+1")
                                                .font(.custom("DMMono-Regular", size: 10))
                                                .foregroundColor(option.mood.color)
                                                .modifier(FloaterModifier())
                                        }
                                    }
                                }
                                
                                // Custom Resonances
                                ForEach(post.customResonances) { res in
                                    CustomResonanceRow(resonance: res)
                                }
                                
                                // Write Your Own Button
                                Button(action: { showingWriteSheet = true }) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                .frame(width: 22, height: 22)
                                            Text("✦").font(.system(size: 12)).foregroundColor(.white.opacity(0.25))
                                        }
                                        Text("express it in your own words…")
                                            .font(.custom("Lora-Italic", size: 11.5))
                                            .foregroundColor(.white.opacity(0.22))
                                        Spacer()
                                    }
                                    .padding(.vertical, 11).padding(.horizontal, 14)
                                    .background(Color.white.opacity(0.01))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 4])))
                                }
                                .padding(.top, 4)
                                
                                Text("choose your mood · write a sentence · see the connection")
                                    .font(.custom("DMMono-Regular", size: 7))
                                    .foregroundColor(.white.opacity(0.12))
                                    .padding(.top, 4)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .sheet(isPresented: $showingWriteSheet) {
            WriteResonanceSheet(post: post) { text, mood in
                store.addCustomResonance(for: post.id, text: text, mood: mood)
                let conn = ResonanceConnection(post: post, feeling: text, userMood: mood)
                onResonate(conn)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { pulses[id] = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { floaters[id] = false }
    }
}

struct ResonanceListRow: View {
    var option: ResonanceOption
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Accent Bar
                Rectangle()
                    .fill(option.isSelectedByCurrentUser ? option.mood.color : Color.clear)
                    .frame(width: 2.5)
                
                // Dot
                Circle()
                    .fill(option.isSelectedByCurrentUser ? option.mood.color : Color.white.opacity(0.1))
                    .frame(width: 6, height: 6)
                    .scaleEffect(option.isSelectedByCurrentUser ? 1.2 : 1.0)
                
                // Text
                Text(option.label)
                    .font(.custom("Lora-Italic", size: 12))
                    .foregroundColor(.white.opacity(option.isSelectedByCurrentUser ? 0.78 : 0.35))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Icon
                MoodShapeView(type: option.mood, color: option.mood.color)
                    .frame(width: 18, height: 18)
                    .opacity(option.isSelectedByCurrentUser ? 1.0 : 0)
                
                // Count
                Text(String(format: "%d", option.count))
                    .font(.custom("DMMono-Regular", size: 8.5))
                    .foregroundColor(option.isSelectedByCurrentUser ? option.mood.color.opacity(0.6) : .white.opacity(0.18))
            }
            .padding(.vertical, 11).padding(.trailing, 12)
            .background(option.isSelectedByCurrentUser ? option.mood.color.opacity(0.04) : Color.white.opacity(0.02))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(option.isSelectedByCurrentUser ? option.mood.color.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1))
        }
    }
}

struct CustomResonanceRow: View {
    var resonance: CustomResonance
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(resonance.mood.color).frame(width: 2.5)
            Circle().fill(resonance.mood.color).frame(width: 6, height: 6).scaleEffect(1.2)
            Text(resonance.text).font(.custom("Lora-Italic", size: 11)).foregroundColor(.white.opacity(0.65)).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
            Text("you").font(.custom("DMMono-Regular", size: 7.5)).foregroundColor(resonance.mood.color.opacity(0.5))
        }
        .padding(.vertical, 11).padding(.trailing, 12)
        .background(resonance.mood.color.opacity(0.04))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(resonance.mood.color.opacity(0.2), lineWidth: 1))
    }
}

struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    func body(content: Content) -> some View {
        content.scaleEffect(scale).opacity(opacity).onAppear {
            withAnimation(.easeOut(duration: 0.5)) { scale = 2.5; opacity = 0 }
        }
    }
}

struct FloaterModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    func body(content: Content) -> some View {
        content.offset(y: offset).opacity(opacity).onAppear {
            withAnimation(.easeOut(duration: 0.8)) { offset = -30; opacity = 0 }
        }
    }
}
