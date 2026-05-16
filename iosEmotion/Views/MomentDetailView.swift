import SwiftUI

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    var post: Post
    var onResonate: (ResonanceConnection) -> Void
    
    @State private var selectedOption: ResonanceOption?
    @State private var showWriteSheet = false
    @State private var isNavigatingToResonance = false
    
    var currentPost: Post {
        store.posts.first(where: { $0.id == post.id }) ?? post
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "07060A").ignoresSafeArea()
            
            // AMBIENT MOOD GLOW
            RadialGradient(colors: [currentPost.themeColor.opacity(0.12), .clear], center: .top, startRadius: 0, endRadius: 400)
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
                            Text(currentPost.artist)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                            Text("now · \(currentPost.song)")
                                .font(.custom("DMMono-Regular", size: 11.5))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        
                        VStack(spacing: 24) {
                            // LARGE MOOD SHAPE
                        HStack {
                            Spacer()
                            MoodShapeView(type: currentPost.moodType, color: currentPost.themeColor, isLarge: true, drawing: currentPost.customShape)
                                .frame(width: 180, height: 180)
                                .blur(radius: 1)
                                .overlay(
                                    MoodShapeView(type: currentPost.moodType, color: currentPost.themeColor, isLarge: true, drawing: currentPost.customShape)
                                        .frame(width: 180, height: 180)
                                        .opacity(0.4)
                                        .blur(radius: 20)
                                )
                            Spacer()
                        }
                        .padding(.vertical, 20)
                        
                        // QUOTE
                        VStack(alignment: .center, spacing: 16) {
                            Text((currentPost.customShapeName ?? currentPost.mood).uppercased())
                                .font(.custom("DMMono-Regular", size: 11))
                                .kerning(2)
                                .foregroundColor(currentPost.themeColor.opacity(0.7))
                            
                            Text("“\(currentPost.quote.trimmingCharacters(in: .whitespacesAndNewlines))”")
                                .font(.custom("Lora-Italic", size: 22))
                                .italic()
                                .lineSpacing(8)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                            
                            Text(currentPost.song)
                                .font(.custom("DMMono-Regular", size: 10))
                                .foregroundColor(.white.opacity(0.15))
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        } // End of Wrapper VStack
                        .background(
                            Group {
                                if let img = currentPost.attachedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        // A square-ish frame slightly larger than the content
                                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 400)
                                        .blur(radius: 5)
                                        .opacity(0.7)
                                        .mask(
                                            RadialGradient(
                                                gradient: Gradient(colors: [.black, .black.opacity(0.8), .clear]),
                                                center: .center,
                                                startRadius: 120,
                                                endRadius: 280
                                            )
                                        )
                                        // Slight vertical offset to center better behind the shape
                                        .offset(y: -20)
                                }
                            }
                        )
                        
                        // RESONANCE SECTION
                        VStack(spacing: 24) {
                            HStack {
                                Text("resonance")
                                    .font(.custom("DMMono-Regular", size: 13))
                                    .kerning(1.2)
                                    .foregroundColor(.white.opacity(0.45))
                                Spacer()
                                Text("\(currentPost.resonanceCount) total")
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
                                            .font(.custom("Lora-Italic", size: 16))
                                            .foregroundColor(.white.opacity(0.65))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    .padding(20)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                                    .foregroundColor(.white.opacity(0.4))
                                }
                                // CUSTOM RESONANCES (Fan created)
                                ForEach(currentPost.customResonances) { option in
                                    let isSelected = selectedOption?.id == option.id
                                    let displayCount = option.count + (isSelected ? 1 : 0)
                                    
                                    Button(action: { 
                                        withAnimation(.spring()) {
                                            selectedOption = option
                                        }
                                        isNavigatingToResonance = true
                                        let connection = ResonanceConnection(post: currentPost, feeling: option.text, userMood: option.mood)
                                        
                                        // Slight delay to show the selection state before navigating
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            onResonate(connection)
                                        }
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(option.mood.color.opacity(isSelected ? 1.0 : 0.8))
                                                .frame(width: 6, height: 6)
                                            Text(option.text)
                                                .font(.custom("Lora-Italic", size: 16))
                                                .foregroundColor(.white.opacity(isSelected ? 1.0 : 0.85))
                                            Spacer()
                                            Text(displayCount > 0 ? "\(displayCount)" : "")
                                                .font(.custom("DMMono-Regular", size: 11))
                                                .foregroundColor(.white.opacity(isSelected ? 0.6 : 0.3))
                                        }
                                        .padding(20)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(isSelected ? 0.08 : 0.03)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(isSelected ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
                                        )
                                        .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                // PRESET RESONANCES
                                ForEach(currentPost.resonanceOptions) { option in
                                    let isSelected = selectedOption?.id == option.id
                                    let displayCount = option.count + (isSelected ? 1 : 0)
                                    
                                    Button(action: { 
                                        withAnimation(.spring()) {
                                            selectedOption = option
                                        }
                                        isNavigatingToResonance = true
                                        let connection = ResonanceConnection(post: currentPost, feeling: option.text, userMood: option.mood)
                                        
                                        // Slight delay to show the selection state before navigating
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            onResonate(connection)
                                        }
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(option.mood.color.opacity(isSelected ? 1.0 : 0.8))
                                                .frame(width: 6, height: 6)
                                            Text(option.text)
                                                .font(.custom("Lora-Italic", size: 16))
                                                .foregroundColor(.white.opacity(isSelected ? 1.0 : 0.85))
                                            Spacer()
                                            Text(displayCount > 0 ? "\(displayCount)" : "")
                                                .font(.custom("DMMono-Regular", size: 11))
                                                .foregroundColor(.white.opacity(isSelected ? 0.6 : 0.3))
                                        }
                                        .padding(20)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(isSelected ? 0.08 : 0.03)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(isSelected ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
                                        )
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
        .onAppear {
            isNavigatingToResonance = false
            MusicManager.shared.playSong(song: currentPost.song, artist: currentPost.artist)
        }
        .onDisappear {
            if !isNavigatingToResonance {
                MusicManager.shared.stop()
            }
        }
        .sheet(isPresented: $showWriteSheet) {
            WriteResonanceSheet(post: currentPost) { feeling, moodType in
                store.addCustomResonance(for: currentPost.id, text: feeling, mood: moodType)
                
                // Delay the navigation so the sheet has time to slide down smoothly
                // This prevents the "jumping" visual glitch caused by simultaneous transitions
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isNavigatingToResonance = true
                    let connection = ResonanceConnection(post: currentPost, feeling: feeling, userMood: moodType)
                    onResonate(connection)
                }
            }
        }
    }
}
