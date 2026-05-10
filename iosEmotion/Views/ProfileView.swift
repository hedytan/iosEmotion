//
//  ProfileView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: PostStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Artist Header (Photo next to Name & Stats)
                    HStack(alignment: .top, spacing: 20) {
                        // Avatar with checkmark
                        ZStack(alignment: .bottomTrailing) {
                            if let data = store.currentUser.avatarData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color("AppPurple").opacity(0.1), lineWidth: 4))
                            } else {
                                Circle()
                                    .fill(Color("AppPurple").opacity(0.1))
                                    .frame(width: 110, height: 110)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color("AppPurple"))
                                    )
                            }
                            
                            Circle()
                                .fill(Color("AppPurple"))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: -4, y: -4)
                        }
                        
                        // Name + Stats
                        VStack(alignment: .leading, spacing: 12) {
                            Text(store.currentUser.name)
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(Color("AppPurple"))
                            
                            // Stats in a sleek row
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("2.4M")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("FOLLOWERS")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("182")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("FOLLOWING")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("45.8K")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("RESONANCES")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)

                    // Identity + Bio (Below Photo)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.currentUser.profession.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("AppPurple").opacity(0.8))
                            .kerning(1.5)
                        
                        Text(store.currentUser.bio)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    // My Journey title
                    Text("MY JOURNEY")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("AppPurple"))
                        .padding(.horizontal)

                    // Card 1 - GABRIEL
                    NavigationLink(destination: JourneyDetailView(title: "GABRIEL")) {
                        ZStack(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .frame(height: 100)
                                .cornerRadius(16)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("GABRIEL")
                                        .font(.title3).fontWeight(.heavy)
                                        .foregroundColor(Color("AppPurple"))
                                    Text("24 ELEMENTS")
                                        .font(.caption2).foregroundColor(.white.opacity(0.6))
                                }
                                .padding(14)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.trailing, 14)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    // Card 2 - TOUR AESTHETICS
                    NavigationLink(destination: JourneyDetailView(title: "TOUR AESTHETICS")) {
                        ZStack(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(Color(red: 0.15, green: 0.35, blue: 0.35))
                                .frame(height: 100)
                                .cornerRadius(16)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("TOUR AESTHETICS")
                                        .font(.title3).fontWeight(.heavy)
                                        .foregroundColor(Color("AppPurple"))
                                    Text("52 ELEMENTS")
                                        .font(.caption2).foregroundColor(.white.opacity(0.6))
                                }
                                .padding(14)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.trailing, 14)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(Color.white)
        }
    }
}

struct JourneyDetailView: View {
    @EnvironmentObject var store: PostStore
    var title: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(store.posts) { post in
                    JourneyPostCard(post: post)
                }
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Journey Post Card

struct JourneyPostCard: View {
    @EnvironmentObject var store: PostStore
    var post: Post
    @State private var showComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                if let data = post.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 220)
                        .cornerRadius(16)
                }

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 220)
                .cornerRadius(16)

                VStack(alignment: .leading, spacing: 4) {
                    Text(post.tag)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("AppPurple"))
                        .cornerRadius(6)

                    Text(post.title)
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("AppPurple"))

                    Text(post.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(14)
            }

            // Action bar
            HStack(spacing: 16) {
                Button(action: {
                    store.toggleLike(for: post.id)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .pink : .gray)
                        Text(post.likeCountString).font(.subheadline).foregroundColor(.gray)
                    }
                }
                
                Button(action: {
                    showComments = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left").foregroundColor(.gray)
                        Text("\(post.comments.count)").font(.subheadline).foregroundColor(.gray)
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
                
                Button(action: {
                    store.toggleSave(for: post.id)
                }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(Color("AppPurple"))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .sheet(isPresented: $showComments) {
            CommentSheet(store: store, postID: post.id)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(PostStore())
}
