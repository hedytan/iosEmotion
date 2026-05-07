//
//  BehindTheWorkView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    @State private var showNotifications = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("RESONANCE")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(Color("AppPurple"))
                        }
                        
                        Spacer()
                        
                        Button(action: { showNotifications = true }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.title3)
                                    .foregroundColor(Color("AppPurple"))
                                
                                if store.unreadCount > 0 {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
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
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
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
                    .foregroundColor(Color("AppPurple"))
                
                Text(post.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Artist Info
            HStack(spacing: 12) {
                Circle()
                    .fill(Color("AppPurple").opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("H")
                            .foregroundColor(Color("AppPurple"))
                            .font(.system(size: 14, weight: .bold))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("keshi")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Artist • Fragment Mode")
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.leading, 8)
                .overlay(
                    Rectangle()
                        .fill(Color("AppPurple"))
                        .frame(width: 2)
                        .padding(.vertical, 2),
                    alignment: .leading
                )
            
            // Shared info
            HStack {
                HStack(spacing: -8) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                Text("Shared by top curators")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Action Bar
            HStack {
                HStack(spacing: 16) {
                    Button(action: { store.toggleLike(for: post.id) }) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .pink : .gray)
                    }
                    
                    Button(action: { showComments = true }) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: { store.toggleSave(for: post.id) }) {
                        Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(post.isSaved ? Color("AppPurple") : .gray)
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
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
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
