//
//  ProfileView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: PostStore
    
    enum ContentMode {
        case journey, saved
    }
    
    @State private var selectedContent: ContentMode = .journey
    
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
                                    Text("\(store.currentUser.followersCount)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("FOLLOWERS")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(store.currentUser.followingCount)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("FOLLOWING")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("24") // Mock resonances count
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
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(store.currentUser.bio)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("AppPurple").opacity(0.8))
                            .kerning(1.5)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    // Content Switcher (Centered)
                    HStack(spacing: 40) {
                        Button(action: { 
                            withAnimation(.spring()) {
                                selectedContent = .journey 
                            }
                        }) {
                            VStack(alignment: .center, spacing: 4) {
                                Text("MY JOURNEY")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(selectedContent == .journey ? Color("AppPurple") : .gray.opacity(0.4))
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(selectedContent == .journey ? Color("AppPurple") : Color.clear)
                                    .frame(width: 40, height: 2)
                            }
                        }
                        
                        Button(action: { 
                            withAnimation(.spring()) {
                                selectedContent = .saved 
                            }
                        }) {
                            VStack(alignment: .center, spacing: 4) {
                                Text("SAVED")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(selectedContent == .saved ? Color("AppPurple") : .gray.opacity(0.4))
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(selectedContent == .saved ? Color("AppPurple") : Color.clear)
                                    .frame(width: 40, height: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)

                    // Swipeable Content Area
                    TabView(selection: $selectedContent) {
                        // 1. My Journey (Irregular Masonry)
                        ScrollView {
                            let myPosts = store.posts.filter { $0.username == store.currentUser.name }
                            
                            if myPosts.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "plus.square.dashed")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.3))
                                    Text("No fragments yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 60)
                            } else {
                                // 2-Column Masonry Layout
                                HStack(alignment: .top, spacing: 16) {
                                    // Column 1
                                    VStack(spacing: 16) {
                                        ForEach(Array(myPosts.enumerated()), id: \.element.id) { index, post in
                                            if index % 2 == 0 {
                                                JourneyPostCard(post: post, height: index % 3 == 0 ? 280 : 200)
                                            }
                                        }
                                    }
                                    
                                    // Column 2
                                    VStack(spacing: 16) {
                                        ForEach(Array(myPosts.enumerated()), id: \.element.id) { index, post in
                                            if index % 2 != 0 {
                                                JourneyPostCard(post: post, height: index % 3 == 0 ? 200 : 280)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                            }
                            
                            Spacer(minLength: 120)
                        }
                        .tag(ContentMode.journey)
                        
                        // 2. Saved
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(store.boards) { board in
                                    NavigationLink(destination: BoardDetailView(board: board)) {
                                        BoardRowView(board: board)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                        .tag(ContentMode.saved)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 600) // Ensure enough height for content

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(Color.white)
        }
    }
}

// MARK: - Journey Post Card

struct JourneyPostCard: View {
    var post: Post
    var height: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image/Color
            Group {
                if let data = post.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if let path = post.imagePath, let url = URL(string: path), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                }
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Subtle Overlay for details
            LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(post.tag)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                Text(post.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                if post.isAudio {
                    Image(systemName: "waveform")
                        .font(.system(size: 10))
                        .foregroundColor(Color("AppPurple"))
                        .padding(.top, 4)
                }
            }
            .padding(12)
        }
        .frame(height: height)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProfileView()
        .environmentObject(PostStore())
}
