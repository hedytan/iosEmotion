import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    
    var body: some View {
        NavigationStack(path: $store.navigationPath) {
            ZStack {
                Color(hex: "07060A").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // HEADER
                    HStack(alignment: .center) {
                        Text("resonance")
                            .font(.custom("Lora-Italic", size: 19))
                            .foregroundColor(.white.opacity(0.75))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(store.posts) { post in
                                Button(action: { store.navigationPath.append(post) }) {
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
                    store.navigationPath.append(connection)
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
                MoodShapeView(type: post.moodType, color: post.themeColor, drawing: post.customShape)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.artist)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    Text("now · \(post.song)")
                        .font(.custom("DMMono-Regular", size: 10.5))
                        .foregroundColor(.white.opacity(0.25))
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
            
            // ATTACHED IMAGE THUMBNAIL
            if let img = post.attachedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.bottom, 11)
            }
            
            // BOTTOM ROW
            HStack {
                Text("\(post.resonanceCount) resonated")
                    .font(.custom("DMMono-Regular", size: 13))
                    .foregroundColor(.white.opacity(0.45))
                
                Spacer()
                
                Text("feel this →")
                    .font(.custom("DMMono-Regular", size: 13))
                    .foregroundColor(.white.opacity(0.45))
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
