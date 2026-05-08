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

                    LazyVStack(spacing: 32) { // Increased spacing for a cleaner look
                        ForEach(store.posts) { post in
                            PostCardView(post: post)
                        }
                    }
                    .padding(.horizontal, 24) // GUTTER: Forces everything to stay in 'Phone Size'
                    .padding(.top)
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
    @State private var isPlaying = false

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                // 1. Media Area (Image or Audio Background)
                ZStack(alignment: .bottomLeading) {
                    if let data = post.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 480)
                            .clipped()
                    } else {
                        LinearGradient(colors: [Color("AppPurple").opacity(0.2), Color("AppPurple").opacity(0.1)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 480)
                    }
                    
                    // Text Overlay for Photo Posts
                    if !post.isAudio {
                        LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        
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
                .frame(height: 480)
                .clipped()
                
                // 2. Interaction Area (Stays white)
                VStack(alignment: .leading, spacing: 16) {
                    // Description
                    if !post.description.isEmpty {
                        Text(post.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .padding(.top, 12)
                    }
                    
                    // Buttons Row
                    HStack {
                        // Likes & Comments
                        HStack(spacing: 16) {
                            Button(action: { store.toggleLike(for: post.id) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    Text(post.likeCountString)
                                }
                                .foregroundColor(post.isLiked ? .pink : .gray)
                            }
                            
                            Button(action: { showComments = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "bubble.left")
                                    Text("\(post.comments.count)")
                                }
                                .foregroundColor(.gray)
                            }
                        }
                        .font(.subheadline)
                        
                        Spacer()
                        
                        // Action Button
                        Button(action: { showComments = true }) {
                            Text("JOIN DISCUSSION")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(Color("AppPurple"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("AppPurple"), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                
                // Special Audio Player Controls (Only for Audio posts)
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
                        
                        // Mock Waveform
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
            .frame(maxWidth: 340)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
            .sheet(isPresented: $showComments) {
                CommentSheet(store: store, postID: post.id)
            }
            Spacer()
        }
    }
}

// Helper for Blur
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    BehindTheWorkView()
        .environmentObject(PostStore())
}
