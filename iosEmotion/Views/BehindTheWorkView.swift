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
    @State private var selectedMood: String? = nil
    
    let moods = ["🌙 Solitude", "🌊 Drift", "🕯️ Intimate", "✨ Spark", "🌀 Fluid"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
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
                                    Circle().fill(.red).frame(width: 10, height: 10).offset(x: 2, y: -2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Mood Filter Hub
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: { 
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        selectedMood = (selectedMood == mood) ? nil : mood
                                    }
                                }) {
                                    Text(mood)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(selectedMood == mood ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedMood == mood ? Color("AppPurple") : Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                    }

                    LazyVStack(spacing: 40) {
                        let filteredPosts = store.posts.filter { post in
                            guard let selected = selectedMood else { return true }
                            // Extract just the word after the emoji for matching
                            let moodName = selected.components(separatedBy: " ").last ?? ""
                            return post.emotion?.contains(moodName) ?? false
                        }
                        
                        ForEach(filteredPosts) { post in
                            PostCardView(post: post)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }
            .background(Color(.systemBackground))
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
    @State private var showSaveSheet = false
    @State private var isPlaying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 0. Artist Header
            HStack(spacing: 12) {
                Group {
                    if let avatarData = post.userAvatarData, let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Circle().fill(Color("AppPurple").opacity(0.1))
                            .overlay(Image(systemName: "person.fill").font(.system(size: 14)).foregroundColor(Color("AppPurple")))
                    }
                }
                .frame(width: 36, height: 36).clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username).font(.system(size: 14, weight: .bold))
                    Text(post.userProfession ?? "Artist & Musician").font(.system(size: 10)).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "ellipsis").foregroundColor(.secondary).font(.system(size: 14))
            }
            .padding(.horizontal, 20).padding(.vertical, 16)

            // 1. Media Area
            ZStack(alignment: .bottomLeading) {
                if let path = post.imagePath, let url = URL(string: path), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill).frame(height: 480).clipped()
                } else if let data = post.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill).frame(height: 480).clipped()
                } else {
                    LinearGradient(colors: [Color("AppPurple").opacity(0.2), Color("AppPurple").opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing).frame(height: 480)
                }
            }
            .cornerRadius(32).padding(.horizontal, 6)

            // 2. Emotional Context & Title
            VStack(alignment: .leading, spacing: 8) {
                if let emotion = post.emotion {
                    Text(emotion.uppercased()).font(.system(size: 10, weight: .bold)).foregroundColor(Color("AppPurple")).kerning(2)
                }
                Text(post.title).font(.system(size: 28, weight: .black)).foregroundColor(.primary)
                Text(post.description).font(.system(size: 15)).foregroundColor(.secondary).lineLimit(3).padding(.top, 4)
            }
            .padding(.horizontal, 24).padding(.top, 24)

            // 3. Resonance Interaction Bar
            HStack(spacing: 24) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        store.toggleLike(for: post.id)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 22))
                            .foregroundColor(post.isLiked ? .pink : .primary)
                            .scaleEffect(post.isLiked ? 1.2 : 1.0)
                        Text(post.likeCountString).font(.system(size: 14, weight: .bold))
                    }
                }

                Button(action: { showComments = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bubble.left").font(.system(size: 20))
                        Text("\(post.comments.count)").font(.system(size: 14, weight: .bold))
                    }
                }
                Spacer()
                Button(action: { store.toggleSave(for: post.id) }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(post.isSaved ? Color("AppPurple") : .primary)
                }
            }
            .foregroundColor(.primary).padding(.horizontal, 24).padding(.top, 28).padding(.bottom, 24)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(44)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
        .sheet(isPresented: $showComments) { CommentSheet(store: store, postID: post.id) }
    }
}

#Preview {
    BehindTheWorkView()
        .environmentObject(PostStore())
}
