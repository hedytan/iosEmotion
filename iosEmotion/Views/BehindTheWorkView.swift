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
        VStack(alignment: .leading, spacing: 0) {
            // 1. The Media/Art Card
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let data = post.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        LinearGradient(colors: [Color("AppPurple").opacity(0.2), Color("AppPurple").opacity(0.1)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                }
                .frame(height: 450) // Increased height for "Phone" feel
                .frame(maxWidth: .infinity)
                .clipped()
                
                // Content Overlay
                if post.isAudio {
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: { isPlaying.toggle() }) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("NOW PLAYING")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(post.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            // Mock Waveform
                            HStack(spacing: 3) {
                                ForEach(0..<10) { i in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white)
                                        .frame(width: 3, height: isPlaying ? CGFloat.random(in: 10...30) : 5)
                                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.1), value: isPlaying)
                                }
                            }
                        }
                        .padding(20)
                        .background(BlurView(style: .systemUltraThinMaterialDark))
                    }
                } else {
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
            .frame(height: 450)
            
            // 2. Interaction Area
            VStack(alignment: .leading, spacing: 12) {
                Text(post.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 12)
                
                HStack {
                    HStack(spacing: 20) {
                        Button(action: { store.toggleLike(for: post.id) }) {
                            HStack(spacing: 4) {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                Text(post.likeCountString)
                                    .font(.caption)
                            }
                            .foregroundColor(post.isLiked ? .pink : .gray)
                        }
                        
                        Button(action: { showComments = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                Text("\(post.comments.count)")
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showComments = true }) {
                        Text("JOIN DISCUSSION")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AppPurple"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color("AppPurple"), lineWidth: 1)
                            )
                    }
                }
            }
            .padding([.horizontal, .bottom], 20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24)) // Forced clipping of all content
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .sheet(isPresented: $showComments) {
            CommentSheet(store: store, postID: post.id)
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
