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
                VStack(spacing: 12) {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SAVED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AppPurple"))
                        Text("Board.")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(Color("AppPurple"))
                    }
                }
            }
        }
    }
}


struct BoardRowView: View {
    var board: BoardItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(board.color)
                .frame(height: 100)
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 2) {
                Text(board.tag)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.7))
                Text(board.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(16)
        }
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
                        .foregroundColor(board.color)
                    Text(board.title)
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Saved Posts
                let savedPosts = store.getPosts(for: board)
                
                if savedPosts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No posts saved yet.")
                            .font(.headline)
                            .foregroundColor(.gray)
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
                }
            }
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    BoardView()
        .environmentObject(PostStore())
}
