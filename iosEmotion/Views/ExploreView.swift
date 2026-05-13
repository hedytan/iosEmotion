import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var store: PostStore
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "08070B").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .lastTextBaseline) {
                    Text("discover")
                        .font(.custom("Lora-Italic", size: 24))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.15))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // FEATURED MOODS
                        VStack(alignment: .leading, spacing: 16) {
                            Text("EXPLORE BY MOOD")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.6)
                                .foregroundColor(.white.opacity(0.2))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Post.MoodType.allCases.filter { $0 != .custom }, id: \.self) { mood in
                                        VStack(spacing: 10) {
                                            MoodShapeView(type: mood, color: mood.color)
                                                .frame(width: 44, height: 44)
                                                .background(
                                                    Circle()
                                                        .fill(mood.color.opacity(0.08))
                                                        .frame(width: 60, height: 60)
                                                )
                                            
                                            Text(mood.displayName)
                                                .font(.custom("DMMono-Regular", size: 7.5))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        .frame(width: 70)
                                    }
                                }
                            }
                        }
                        
                        // DISCOVERY GRID
                        VStack(alignment: .leading, spacing: 16) {
                            Text("LATEST RESONANCES")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.6)
                                .foregroundColor(.white.opacity(0.2))
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(store.posts) { post in
                                    ExploreCard(post: post)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct ExploreCard: View {
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                if let image = post.attachedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(post.themeColor.opacity(0.15))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(post.themeColor.opacity(0.05))
                        .frame(height: 140)
                        .overlay(
                            MoodShapeView(type: post.moodType, color: post.themeColor)
                                .frame(width: 40, height: 40)
                                .opacity(0.2)
                        )
                }
                
                Text(post.mood.uppercased())
                    .font(.custom("DMMono-Regular", size: 7))
                    .kerning(1)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.artist)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(post.song)
                    .font(.custom("Lora-Italic", size: 9))
                    .foregroundColor(.white.opacity(0.3))
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .padding(8)
        .background(Color.white.opacity(0.02))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
