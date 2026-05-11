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
            // Artistic Avatar
            Group {
                if let avatar = artist.avatarImage, avatar.contains("file://"), let url = URL(string: avatar), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // Fallback to stylized gradients
                    ArtistStyleGradient(style: artist.avatarImage ?? "default")
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
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
            // Artistic Avatar
            Group {
                if let avatar = artist.avatarImage, avatar.contains("file://"), let url = URL(string: avatar), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ArtistStyleGradient(style: artist.avatarImage ?? "default")
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
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

struct ArtistStyleGradient: View {
    var style: String
    
    var body: some View {
        Circle()
            .fill(gradient)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white.opacity(0.3))
            )
    }
    
    var gradient: LinearGradient {
        switch style {
        case "neon":
            return LinearGradient(colors: [.blue, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "quiet":
            return LinearGradient(colors: [Color.white.opacity(0.8), Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        case "bw":
            return LinearGradient(colors: [.black, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "colorful":
            return LinearGradient(colors: [.orange, .purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
        }
    }
}

#Preview {
    ExploreView()
        .environmentObject(PostStore())
}
