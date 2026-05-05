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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(store.posts.prefix(2)) { post in
                        PostCardView(post: post)
                    }
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("BEHIND THE")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(Color("AppPurple"))
                        Text("WORK")
                            .font(.title)
                            .fontWeight(.heavy)
                            .italic()
                            .foregroundColor(Color("AppPurple"))
                    }
                }
            }
        }
    }
}

struct PostCardView: View {
    @EnvironmentObject var store: PostStore
    var post: Post
    @State private var showComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Image card
            ZStack(alignment: .bottomLeading) {
                // Image or Placeholder
                if let data = post.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 480)
                        .clipped()
                        .cornerRadius(24)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 480)
                        .cornerRadius(24)
                }

                // Gradient overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 480)
                .cornerRadius(24)

                // Text overlay
                VStack(alignment: .leading, spacing: 6) {
                    Text(post.tag)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.purple.opacity(0.8))
                        .cornerRadius(6)

                    Text(post.title)
                        .font(.system(size: 42, weight: .heavy))
                        .foregroundColor(Color("AppPurple"))

                    Text(post.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(20)
            }

            // Action bar
            HStack(spacing: 16) {
                // Heart
                Button(action: {
                    store.toggleLike(for: post.id)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .pink : .gray)
                        Text(post.likeCountString)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // Comment
                Button(action: {
                    showComments = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.gray)
                        Text("\(post.comments.count)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // React
                Menu {
                    Button("✨ Sparkle") { store.setReaction(for: post.id, reaction: "✨") }
                    Button("🔥 Fire") { store.setReaction(for: post.id, reaction: "🔥") }
                    Button("💜 Heart") { store.setReaction(for: post.id, reaction: "💜") }
                } label: {
                    HStack(spacing: 4) {
                        if let reaction = post.reaction {
                            Text(reaction)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(post.reaction == nil ? "React" : "Reacted")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color("AppPurple"))
                }

                Spacer()

                // Bookmark
                Button(action: {
                    store.toggleSave(for: post.id)
                }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(Color("AppPurple"))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 14)
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
