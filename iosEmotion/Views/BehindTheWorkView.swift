import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(hex: "07060A").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // HEADER
                    HStack(alignment: .center) {
                        Text("moodpost")
                            .font(.custom("Lora-Italic", size: 19))
                            .foregroundColor(.white.opacity(0.75))
                        
                        Spacer()
                        
                        // "all moods" pill
                        Text("all moods")
                            .font(.custom("DMMono-Regular", size: 8))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().stroke(Color.white.opacity(0.07), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(store.posts) { post in
                                Button(action: { path.append(post) }) {
                                    FeedPostCard(post: post)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
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

struct FeedPostCard: View {
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // TOP ROW
            HStack(spacing: 16) {
                MoodShapeView(type: post.moodType, color: post.themeColor)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.artist)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.82))
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(post.themeColor)
                            .frame(width: 5, height: 5)
                        Text(post.mood)
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(post.themeColor)
                        Text("·")
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(.white.opacity(0.15))
                        Text(post.song)
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(.white.opacity(0.22))
                    }
                }
                Spacer()
            }
            
            // QUOTE
            Text(post.quote)
                .font(.custom("Lora-Italic", size: 13.5))
                .lineSpacing(4) // Approx 1.65 line height
                .foregroundColor(.white.opacity(0.62))
                .lineLimit(2)
                .truncationMode(.tail)
                .padding(.top, 11)
                .padding(.bottom, 11)
            
            // BOTTOM ROW
            HStack {
                Text("\(formatCount(post.resonanceCount)) resonated")
                    .font(.custom("DMMono-Regular", size: 8))
                    .foregroundColor(.white.opacity(0.18))
                Spacer()
                Text("feel this →")
                    .font(.custom("DMMono-Regular", size: 8))
                    .foregroundColor(.white.opacity(0.18))
            }
            
            Rectangle()
                .fill(Color.white.opacity(0.04))
                .frame(height: 1)
                .padding(.top, 20)
        }
        .padding(.top, 20)
        .padding(.horizontal, 24)
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000 { return String(format: "%.1fk", Double(count) / 1000.0) }
        return "\(count)"
    }
}
