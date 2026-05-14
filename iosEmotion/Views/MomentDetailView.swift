import SwiftUI

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    var post: Post
    var onResonate: (ResonanceConnection) -> Void
    
    @State private var selectedOption: ResonanceOption?
    @State private var showWriteSheet = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT MOOD GLOW
            RadialGradient(colors: [post.themeColor.opacity(0.12), .clear], center: .top, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // TOP BAR (Metadata only now)
                HStack {
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 58)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // ARTIST & SONG
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.artist)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                            Text("now · \(post.song)")
                                .font(.custom("DMMono-Regular", size: 11.5))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        Spacer()
                        
                        // LARGE MOOD SHAPE
                        HStack {
                            Spacer()
                            MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true, drawing: post.customShape)
                                .frame(width: 180, height: 180)
                                .blur(radius: 1)
                                .overlay(
                                    MoodShapeView(type: post.moodType, color: post.themeColor, isLarge: true, drawing: post.customShape)
                                        .frame(width: 180, height: 180)
                                        .opacity(0.4)
                                        .blur(radius: 20)
                                )
                            Spacer()
                        }
                        .padding(.vertical, 20)
                        
                        // QUOTE
                        VStack(alignment: .center, spacing: 16) {
                            Text((post.customShapeName ?? post.mood).uppercased())
                                .font(.custom("DMMono-Regular", size: 11))
                                .kerning(2)
                                .foregroundColor(post.themeColor.opacity(0.7))
                            
                            Text("“\(post.quote)”")
                                .font(.custom("Lora-Italic", size: 22))
                                .italic()
                                .lineSpacing(8)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                            
                            Text(post.song)
                                .font(.custom("DMMono-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.15))
                        }
                        .padding(.horizontal, 20)
                        
                        // RESONANCE SECTION
                        VStack(spacing: 24) {
                            HStack {
                                Text("resonance")
                                    .font(.custom("DMMono-Regular", size: 13))
                                    .kerning(1.2)
                                    .foregroundColor(.white.opacity(0.45))
                                Spacer()
                                Text("\(post.resonanceCount) total")
                                    .font(.custom("DMMono-Regular", size: 13))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            
                            VStack(spacing: 12) {
                                // Write your own
                                Button(action: { showWriteSheet = true }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14))
                                        Text("express it in your own words...")
                                            .font(.custom("Lora-Italic", size: 14))
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.system(size: 10))
                                    }
                                    .padding(20)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                    .foregroundColor(.white.opacity(0.4))
                                }
                                                                // CUSTOM RESONANCES (Fan created)
                                ForEach(post.customResonances) { option in
                                    Button(action: { 
                                        let connection = ResonanceConnection(post: post, feeling: option.text, userMood: option.mood)
                                        onResonate(connection)
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(option.mood.color.opacity(0.8))
                                                .frame(width: 6, height: 6)
                                            Text(option.text)
                                                .font(.custom("Lora-Italic", size: 14))
                                            Spacer()
                                            Text(option.count > 0 ? "\(option.count)" : "")
                                                .font(.custom("DMMono-Regular", size: 11))
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                        .padding(20)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                                        .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                // PRESET RESONANCES
                                ForEach(post.resonanceOptions) { option in
                                    Button(action: { 
                                        let connection = ResonanceConnection(post: post, feeling: option.text, userMood: option.mood)
                                        onResonate(connection)
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(option.mood.color.opacity(0.8))
                                                .frame(width: 6, height: 6)
                                            Text(option.text)
                                                .font(.custom("Lora-Italic", size: 14))
                                            Spacer()
                                            Text(option.count > 0 ? "\(option.count)" : "")
                                                .font(.custom("DMMono-Regular", size: 11))
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                        .padding(20)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                                        .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }
            
            // CIRCULAR GLASS BACK BUTTON
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                    Circle()
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.82))
                        .offset(x: -1)
                }
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.3), radius: 12)
            }
            .padding(.leading, 20)
            .padding(.top, 16)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showWriteSheet) {
            WriteResonanceSheet(post: post) { feeling, moodType in
                store.addCustomResonance(for: post.id, text: feeling, mood: moodType)
                let connection = ResonanceConnection(post: post, feeling: feeling, userMood: moodType)
                onResonate(connection)
            }
        }
    }
}
