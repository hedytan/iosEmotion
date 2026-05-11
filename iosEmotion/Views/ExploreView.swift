import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var store: PostStore
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.4))
                        TextField("Search artists, sounds...", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(red: 0.05, green: 0.05, blue: 0.07)) // Midnight Noir
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Featured Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("RISING TALENT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("AppPurple"))
                            .kerning(1.5)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(store.discoveredArtists.prefix(3)) { artist in
                                    FeaturedArtistCard(artist: artist)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Browse by Category
                    VStack(alignment: .leading, spacing: 20) {
                        Text("EXPLORE NICHES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("AppPurple"))
                            .kerning(1.5)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(store.discoveredArtists) { artist in
                                ArtistRowView(artist: artist)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.white)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SEARCH")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("AppPurple"))
                            .kerning(1.2)
                        Text("Artists.")
                            .font(.system(size: 34, weight: .black))
                            .foregroundColor(Color("AppPurple"))
                    }
                }
            }
        }
    }
}

struct FeaturedArtistCard: View {
    var artist: Artist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(artist.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(artist.identity)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(24)
        .frame(width: 200, height: 200, alignment: .leading)
        .background(Color(red: 0.05, green: 0.05, blue: 0.07))
        .cornerRadius(32)
    }
}

struct ArtistRowView: View {
    @EnvironmentObject var store: PostStore
    var artist: Artist
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(Color("AppPurple").opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(artist.name)
                    .font(.system(size: 16, weight: .bold))
                Text(artist.identity)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { 
                withAnimation(.spring()) {
                    store.toggleFollowArtist(id: artist.id)
                }
            }) {
                Text(artist.isFollowing ? "Following" : "Follow")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(artist.isFollowing ? .white : Color("AppPurple"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(artist.isFollowing ? Color("AppPurple") : Color("AppPurple").opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(24)
    }
}

#Preview {
    ExploreView()
        .environmentObject(PostStore())
}
