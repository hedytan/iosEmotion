import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: PostStore
    
    enum ContentMode {
        case journey, saved
    }
    
    @State private var selectedContent: ContentMode = .journey
    
    var body: some View {
        ZStack {
            Color(hex: "07060a").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Artist Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text(store.currentUser.name)
                            .font(.custom("Lora-Italic", size: 38))
                            .italic()
                            .foregroundColor(.white)
                        
                        Text(store.currentUser.bio)
                            .font(.custom("Lora-Italic", size: 14))
                            .italic()
                            .foregroundColor(.white.opacity(0.6))
                            .lineSpacing(4)
                        
                        // Stats (Monospace)
                        HStack(spacing: 24) {
                            StatView(label: "followers", value: "\(store.currentUser.followersCount)")
                            StatView(label: "following", value: "\(store.currentUser.followingCount)")
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    // Content Switcher
                    HStack(spacing: 32) {
                        Button(action: { withAnimation(.spring()) { selectedContent = .journey } }) {
                            Text("JOURNEY")
                                .font(.custom("DMMono-Regular", size: 12))
                                .foregroundColor(selectedContent == .journey ? .white : .white.opacity(0.2))
                        }
                        
                        Button(action: { withAnimation(.spring()) { selectedContent = .saved } }) {
                            Text("SAVED")
                                .font(.custom("DMMono-Regular", size: 12))
                                .foregroundColor(selectedContent == .saved ? .white : .white.opacity(0.2))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Content Area
                    if selectedContent == .journey {
                        VStack(spacing: 0) {
                            ForEach(store.posts) { post in
                                MoodPostCard(post: post)
                                Rectangle()
                                    .fill(Color.white.opacity(0.035))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                    } else {
                        VStack(spacing: 24) {
                            ForEach(store.boards) { board in
                                NavigationLink(destination: BoardDetailView(board: board)) {
                                    BoardRowView(board: board)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct StatView: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.custom("DMMono-Regular", size: 14))
                .foregroundColor(.white)
            Text(label)
                .font(.custom("DMMono-Regular", size: 10))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(PostStore())
}
