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
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 0) {
                        Text("BEHIND THE")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color("AppPurple"))
                        Text("WORK")
                            .font(.system(size: 28, weight: .black))
                            .italic()
                            .foregroundColor(Color("AppPurple"))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Feed
                    LazyVStack(spacing: 20) {
                        ForEach(store.posts) { post in
                            PostCardView(post: post)
                        }
                    }
                }
            }
            .background(Color("AppBackground"))
            .navigationBarHidden(true)
        }
    }
}

struct PostCardView: View {
    @EnvironmentObject var store: PostStore
    var post: Post
    @State private var showComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tag & Title
            VStack(alignment: .leading, spacing: 8) {
                Text("NEW RELEASED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.cyan)
                
                Text(post.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Artist Info
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("H")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("keshi")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Artist • Fragment Mode")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            // Image (if any)
            if let data = post.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            }

            // Description
            Text(post.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
                .padding(.leading, 8)
                .overlay(
                    Rectangle()
                        .fill(Color("AppPurple"))
                        .frame(width: 2)
                        .padding(.vertical, 2),
                    alignment: .leading
                )
            
            // Shared info (Static placeholder)
            HStack {
                HStack(spacing: -8) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color("CardBackground"), lineWidth: 2))
                    }
                }
                Text("Shared by top curators")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            // Action Bar
            HStack {
                HStack(spacing: 16) {
                    Button(action: { store.toggleLike(for: post.id) }) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .pink : .white)
                    }
                    
                    Button(action: { showComments = true }) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { store.toggleSave(for: post.id) }) {
                        Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(post.isSaved ? .white : .white)
                    }
                }
                
                Spacer()
                
                Button(action: { showComments = true }) {
                    Text("JOIN DISCUSSION")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("AppPurple"))
                        .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(24)
        .padding(.horizontal)
        .sheet(isPresented: $showComments) {
            CommentSheet(store: store, postID: post.id)
        }
    }
}

#Preview {
    BehindTheWorkView()
        .environmentObject(PostStore())
}
