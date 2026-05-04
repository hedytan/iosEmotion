//
//  BehindTheWorkView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct BehindTheWorkView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    PostCardView(
                        tag: "SPOTLIGHT",
                        title: "LIMBO",
                        description: "The sonic architecture of a dream state. Exploring the reverb trails in GABRIEL.",
                        likes: "24.1k",
                        comments: "842"
                    )
                    PostCardView(
                        tag: "NEW FRAGMENT",
                        title: "The Geometry of Noise",
                        description: "This album got me through the hardest year of my life.",
                        likes: "12.4k",
                        comments: "391"
                    )
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("BEHIND THE")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(Color("AppPurple"))
                        Text("WORK")
                            .font(.title)
                            .fontWeight(.heavy)
                            .italic()
                            .foregroundColor(Color("AppPurple"))
                    }
                }
            }
        }
    }
}

struct PostCardView: View {
    var tag: String
    var title: String
    var description: String
    var likes: String
    var comments: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Image card
            ZStack(alignment: .bottomLeading) {
                // Placeholder image (grey for now)
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 380)
                    .cornerRadius(20)

                // Gradient overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 380)
                .cornerRadius(20)

                // Text overlay
                VStack(alignment: .leading, spacing: 6) {
                    Text(tag)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.purple.opacity(0.8))
                        .cornerRadius(6)

                    Text(title)
                        .font(.system(size: 42, weight: .heavy))
                        .foregroundColor(Color("AppPurple"))

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(20)
            }

            // Action bar
            HStack(spacing: 16) {
                // Heart
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                    Text(likes)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Comment
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.gray)
                    Text(comments)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // React
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color("AppPurple"))
                    Text("React")
                        .font(.subheadline)
                        .foregroundColor(Color("AppPurple"))
                }

                Spacer()

                // Bookmark
                Image(systemName: "bookmark")
                    .foregroundColor(Color("AppPurple"))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    BehindTheWorkView()
}
