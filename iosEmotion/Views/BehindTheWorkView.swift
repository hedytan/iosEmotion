import SwiftUI

struct BehindTheWorkView: View {
    @EnvironmentObject var store: PostStore
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "07060a").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
                        Text("moodpost")
                            .font(.custom("Lora-Italic", size: 16))
                            .italic()
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    // Feed List
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(store.posts) { post in
                                NavigationLink(destination: MomentDetailView(post: post)) {
                                    MoodPostCard(post: post)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.015))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MoodPostCard: View {
    var post: Post
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Edge Color Stripe
            Rectangle()
                .fill(post.moodColor)
                .frame(width: 2)
                .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 16) {
                // Top Row: Shape + Artist + Mood + Song
                HStack(spacing: 12) {
                    MoodShapeView(type: post.moodType, color: post.moodColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(post.artist)
                                .font(.custom("DMMono-Regular", size: 13))
                                .foregroundColor(.white)
                            
                            Text(post.mood)
                                .font(.custom("DMMono-Regular", size: 13))
                                .foregroundColor(post.moodColor)
                        }
                        
                        Text(post.song)
                            .font(.custom("DMMono-Regular", size: 11))
                            .foregroundColor(.gray)
                    }
                }
                
                // Middle Row: Quote (Italic Serif)
                Text(post.quote)
                    .font(.custom("Lora-Italic", size: 12.5))
                    .italic()
                    .foregroundColor(.white.opacity(0.62))
                    .lineSpacing(6)
                    .padding(.trailing, 20)
                
                // Bottom Row: Resonance + Action
                HStack {
                    Text("\(post.resonanceCount) resonated")
                        .font(.custom("DMMono-Regular", size: 7.5))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("feel this →")
                        .font(.custom("DMMono-Regular", size: 7.5))
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 16)
            .padding(.vertical, 24)
            .padding(.trailing, 20)
        }
    }
}
