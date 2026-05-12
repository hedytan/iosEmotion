import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    @State private var path = NavigationPath()
    @State private var showingExpress = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(hex: "08070B").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    VStack(spacing: 0) {
                        HStack {
                            Text("resonance")
                                .font(.custom("Lora-Italic", size: 19))
                                .italic()
                                .foregroundColor(.white.opacity(0.75))
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("all moods")
                                    .font(.custom("DMMono-Regular", size: 8))
                                    .foregroundColor(.white.opacity(0.20))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.07), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.04))
                            .frame(height: 1)
                    }
                    
                    // Feed List
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(store.posts) { post in
                                Button(action: { path.append(post) }) {
                                    ResonanceCard(post: post)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.04))
                                    .frame(height: 1)
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Post.self) { post in
                MomentDetailView(post: post) { feeling in
                    path.append(feeling)
                }
            }
            .navigationDestination(for: String.self) { feeling in
                // Find the post that triggered this connection (hacky for prototype but works)
                if let lastPost = store.posts.first(where: { post in 
                    // This is a bit complex for a simple path, 
                    // usually we'd pass a struct with post + feeling
                    return true 
                }) {
                    ConnectionView(post: lastPost, feeling: feeling)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ResonanceCard: View {
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP ROW
            HStack(spacing: 16) {
                MoodShapeView(type: post.moodType, color: post.themeColor, customMood: post.customMood)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.artist)
                        .font(.system(size: 14, weight: .medium)) // SF Pro Medium
                        .foregroundColor(.white.opacity(0.82))
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(post.themeColor)
                            .frame(width: 5, height: 5)
                        
                        Text(post.moodType.displayName)
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(post.themeColor)
                            .font(.custom("DMMono-Regular", size: 8.5))
                            .foregroundColor(.white.opacity(0.22))
                        
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
                .italic()
                .foregroundColor(.white.opacity(0.62))
                .lineSpacing(1.65 * 13.5 - 13.5) // Approximate line height
                .lineLimit(2)
                .truncationMode(.tail)
                .padding(.top, 4)
            
            // BOTTOM ROW
            HStack {
                Text("\(post.resonanceCount) resonated")
                    .font(.custom("DMMono-Regular", size: 8))
                    .foregroundColor(.white.opacity(0.18))
                
                Spacer()
                
                Text("feel this →")
                    .font(.custom("DMMono-Regular", size: 8))
                    .foregroundColor(.white.opacity(0.18))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}
