import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(hex: "08070B").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .lastTextBaseline) {
                        Text("resonance")
                            .font(.custom("Lora-Italic", size: 24))
                            .foregroundColor(.white)
                        Spacer()
                        Text("v.01")
                            .font(.custom("DMMono-Regular", size: 9))
                            .foregroundColor(.white.opacity(0.15))
                    }
                    .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 24)
                    
                    // Feed List
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(store.posts) { post in
                                Button(action: { path.append(post) }) {
                                    ResonanceCard(post: post)
                                }
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 100)
                    }
                }
            }
            .navigationDestination(for: Post.self) { post in
                MomentDetailView(post: post) { connection in
                    path.append(connection)
                }
            }
            .navigationDestination(for: ResonanceConnection.self) { connection in
                ConnectionView(post: connection.post, feeling: connection.feeling, userMood: connection.userMood)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct ResonanceCard: View {
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // TOP ROW: Mood & Artist
            HStack(spacing: 16) {
                MoodShapeView(type: post.moodType, color: post.themeColor, customMood: post.customMood)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.artist).font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.85))
                    HStack(spacing: 6) {
                        Circle().fill(post.themeColor).frame(width: 5, height: 5)
                        Text(post.mood).font(.custom("DMMono-Regular", size: 8.5)).foregroundColor(post.themeColor)
                        Text("·").font(.custom("DMMono-Regular", size: 8.5)).foregroundColor(.white.opacity(0.15))
                        Text(post.song).font(.custom("DMMono-Regular", size: 8.5)).foregroundColor(.white.opacity(0.4))
                    }
                }
                Spacer()
            }
            
            // THE QUOTE
            Text("“\(post.quote)”")
                .font(.custom("Lora-Italic", size: 18))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4).multilineTextAlignment(.leading)
            
            // THE VISUAL FRAGMENT (Optional)
            if let image = post.attachedImage {
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity).frame(height: 180).clipped().cornerRadius(16)
                        .overlay(post.themeColor.opacity(0.22))
                    
                    MoodShapeView(type: post.moodType, color: .white, customMood: post.customMood)
                        .frame(width: 40, height: 40).opacity(0.10).padding(12)
                }
            }
            
            // FOOTER: Metrics
            HStack {
                Text("\(formatCount(post.resonanceCount)) resonated")
                    .font(.custom("DMMono-Regular", size: 8.5))
                    .foregroundColor(.white.opacity(0.12))
                Spacer()
                Text("\(post.daysAgo)d ago")
                    .font(.custom("DMMono-Regular", size: 8.5))
                    .foregroundColor(.white.opacity(0.12))
            }
        }
        .padding(24)
        .background(
            ZStack {
                Color.white.opacity(0.02)
                RadialGradient(colors: [post.themeColor.opacity(0.04), .clear], center: .center, startRadius: 0, endRadius: 150)
            }
        )
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
}
