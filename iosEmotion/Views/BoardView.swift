//
//  BoardView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var store: PostStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Premium Header
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SAVED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("AppPurple"))
                            .kerning(1.2)
                        Text("Board.")
                            .font(.system(size: 44, weight: .black))
                            .foregroundColor(Color("AppPurple"))
                    }
                    .padding(.bottom, 10)
                    
                    ForEach(store.boards) { board in
                        NavigationLink(destination: BoardDetailView(board: board)) {
                            BoardRowView(board: board)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("")
        }
    }
}


struct BoardRowView: View {
    var board: BoardItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Cover Image or Fallback Color
            Group {
                if let photoURL = board.coverPhoto, let url = URL(string: photoURL), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(board.color)
                }
            }
            .frame(height: 140)
            .clipped()
            .cornerRadius(24)
            
            // Dark Gradient Overlay for readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(24)

            VStack(alignment: .leading, spacing: 4) {
                Text(board.tag)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .kerning(1.2)
                Text(board.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(20)
        }
        .frame(height: 140)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

struct BoardDetailView: View {
    @EnvironmentObject var store: PostStore
    var board: BoardItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Board Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(board.tag)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AppPurple"))
                    Text(board.title)
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(Color("AppPurple"))
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                // Saved Posts
                let savedPosts = store.getPosts(for: board)
                
                if savedPosts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.2))
                        Text("No posts saved yet.")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    VStack(spacing: 32) {
                        ForEach(savedPosts) { post in
                            PostCardView(post: post)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [board.color, Color(red: 0.05, green: 0.05, blue: 0.07)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    BoardView()
        .environmentObject(PostStore())
}
