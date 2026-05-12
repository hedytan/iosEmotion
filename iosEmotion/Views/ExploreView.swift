import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var store: PostStore
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color(hex: "07060a").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SEARCH")
                            .font(.custom("DMMono-Regular", size: 12))
                            .foregroundColor(Color(hex: "f0a840"))
                            .kerning(1.2)
                        Text("Artists.")
                            .font(.custom("Lora-Italic", size: 38))
                            .italic()
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.system(size: 14))
                        TextField("Search names, sounds...", text: $searchText)
                            .foregroundColor(.white)
                            .font(.custom("DMMono-Regular", size: 14))
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)

                    // Artist List
                    VStack(alignment: .leading, spacing: 0) {
                        Text("RISING TALENT")
                            .font(.custom("DMMono-Regular", size: 10))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        
                        ForEach(store.discoveredArtists) { artist in
                            ArtistRowView(artist: artist)
                            Rectangle()
                                .fill(Color.white.opacity(0.035))
                                .frame(height: 1)
                                .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ArtistRowView: View {
    @EnvironmentObject var store: PostStore
    var artist: Artist
    
    var body: some View {
        HStack(spacing: 16) {
            // Mood Shape as Placeholder
            MoodShapeView(type: .tender, color: Color.white.opacity(0.2))
                .scaleEffect(0.8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(artist.name)
                    .font(.custom("Lora-Italic", size: 16))
                    .italic()
                    .foregroundColor(.white)
                Text(artist.identity)
                    .font(.custom("DMMono-Regular", size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            Button(action: { }) {
                Text("connect")
                    .font(.custom("DMMono-Regular", size: 10))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    ExploreView()
        .environmentObject(PostStore())
}
