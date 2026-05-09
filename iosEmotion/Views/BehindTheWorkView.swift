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
            ScrollViewReader { proxy in
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
                        .id("TOP")

                        LazyVStack(spacing: 32) {
                            ForEach(store.posts) { post in
                                PostCardView(post: post)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationBarHidden(true)
                .onChange(of: store.posts.count) { _ in
                    withAnimation(.spring()) {
                        proxy.scrollTo("TOP", anchor: .top)
                    }
                }
            }
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
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                // 0. Artist Header
                HStack(spacing: 10) {
                    if let avatarData = post.userAvatarData, let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color("AppPurple").opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("AppPurple"))
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.username)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Artist & Musician")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)

                // 1. Media Area (Only if Photo or Audio exists)
                if post.imageData != nil || post.isAudio {
                    ZStack(alignment: .bottomLeading) {
                        if let data = post.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 340, height: 480)
                                .clipped()
                        } else {
                            LinearGradient(colors: [Color("AppPurple").opacity(0.2), Color("AppPurple").opacity(0.1)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(width: 340, height: 480)
                        }
                        
                        if !post.isAudio {
                            LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                                .frame(width: 340, height: 480)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(post.tag)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color("AppPurple"))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                                
                                Text(post.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(20)
                        }
                    }
                    .frame(width: 340, height: 480)
                    .clipped()
                }
                
                // 2. Interaction Area
                VStack(alignment: .leading, spacing: 12) {
                    if !post.description.isEmpty {
                        Text(post.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .padding(.top, 12)
                    } else {
                        Spacer().frame(height: 12)
                    }
                    
                    HStack(alignment: .center) {
                        HStack(spacing: 20) {
                            Button(action: { store.toggleLike(for: post.id) }) {
                                HStack(spacing: 6) {
                                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                        .font(.system(size: 18))
                                    Text(post.likeCountString)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(post.isLiked ? .pink : .gray)
                            }
                            
                            Button(action: { showComments = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "bubble.left")
                                        .font(.system(size: 18))
                                    Text("\(post.comments.count)")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { showSaveSheet = true }) {
                            Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 18))
                                .foregroundColor(post.isSaved ? Color("AppPurple") : .gray)
                        }
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
                
                if post.isAudio {
                    HStack {
                        Button(action: { isPlaying.toggle() }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color("AppPurple"))
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.title)
                                .font(.caption)
                                .fontWeight(.bold)
                            Text("NOW PLAYING")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(0..<8) { i in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color("AppPurple").opacity(0.3))
                                    .frame(width: 2, height: isPlaying ? CGFloat.random(in: 10...20) : 4)
                                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.1), value: isPlaying)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color("AppPurple").opacity(0.05))
                    .cornerRadius(12)
                    .padding([.horizontal, .bottom], 12)
                }
            }
            .frame(width: 340)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
            .sheet(isPresented: $showComments) {
                CommentSheet(store: store, postID: post.id)
            }
            .sheet(isPresented: $showSaveSheet) {
                SaveToAlbumSheet(postID: post.id)
            }
            Spacer()
        }
    }
}

#Preview {
    BehindTheWorkView()
        .environmentObject(PostStore())
}
