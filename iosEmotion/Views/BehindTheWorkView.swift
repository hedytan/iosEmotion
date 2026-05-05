//
//  BehindTheWorkView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(store.posts) { post in
                    PostCardView(post: post)
                        .containerRelativeFrame(.vertical)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea(edges: .top)
        .background(Color.black)
    }
}

struct PostCardView: View {
    @EnvironmentObject var store: PostStore
    var post: Post
    @State private var showComments = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full Screen Image/Background
            GeometryReader { geo in
                if let data = post.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(LinearGradient(colors: [Color("AppPurple").opacity(0.3), .black], startPoint: .top, endPoint: .bottom))
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .ignoresSafeArea()

            // Dark Gradient for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Floating UI Content
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.tag)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.purple.opacity(0.8))
                            .cornerRadius(6)

                        Text(post.title)
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(.white)

                        Text(post.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)
                    }
                    
                    Spacer()
                    
                    // Vertical Action Bar
                    VStack(spacing: 20) {
                        // Heart
                        Button(action: { store.toggleLike(for: post.id) }) {
                            VStack(spacing: 4) {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(post.isLiked ? .pink : .white)
                                Text(post.likeCountString)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }

                        // Comment
                        Button(action: { showComments = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("\(post.comments.count)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }

                        // React
                        Menu {
                            Button("✨ Sparkle") { store.setReaction(for: post.id, reaction: "✨") }
                            Button("🔥 Fire") { store.setReaction(for: post.id, reaction: "🔥") }
                            Button("💜 Heart") { store.setReaction(for: post.id, reaction: "💜") }
                        } label: {
                            VStack(spacing: 4) {
                                Text(post.reaction ?? "✨")
                                    .font(.title2)
                                Text("React")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }

                        // Bookmark
                        Button(action: { store.toggleSave(for: post.id) }) {
                            Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(post.isSaved ? .yellow : .white)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(20)
            .padding(.bottom, 60) // Extra padding for the tab bar
        }
        .sheet(isPresented: $showComments) {
            CommentSheet(store: store, postID: post.id)
        }
    }
}

#Preview {
    BehindTheWorkView()
        .environmentObject(PostStore())
}
