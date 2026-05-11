import Foundation
import Combine
import SwiftUI

struct BoardItem: Identifiable {
    let id = UUID()
    var title: String
    var tag: String
    var color: Color
    var coverPhoto: String? // Added for artistic cover images
    var postIDs: [UUID] = [] // Store the IDs of saved posts
}

struct Artist: Identifiable {
    let id = UUID()
    var name: String
    var identity: String
    var avatarImage: String?
    var isFollowing: Bool = false
}

struct UserProfile {
    var name: String = ""
    var handle: String = ""
    var bio: String = ""
    var profession: String = "Artist"
    var avatarData: Data? = nil // Circular profile photo
}

class PostStore: ObservableObject {
    @Published var currentUser = UserProfile()
    @Published var hasCompletedOnboarding: Bool = false
    @Published var posts: [Post] = [
        Post(username: "HYBS", tag: "SPOTLIGHT", title: "LIMBO",
             description: "The sonic architecture of a dream state. Exploring the reverb trails in GABRIEL.",
             likes: 24100, isAudio: true, comments: ["This is incredible", "The production is top notch!", "Can't wait for the full release"]),
        Post(username: "Babychair", tag: "NEW FRAGMENT", title: "The Geometry of Noise",
             description: "This album got me through the hardest year of my life.",
             likes: 12400, comments: ["I feel this", "Pure art"]),
        Post(username: "Phum Viphurit", tag: "FRAGMENT", title: "Studio Session 01",
             description: "3am and the chords finally made sense.",
             likes: 8200, isAudio: true, comments: ["Relatable", "3am sessions are the best"])
    ]

    @Published var boards: [BoardItem] = [
        BoardItem(title: "Midnight Echoes", tag: "MOOD · NOIR", color: Color(red: 0.1, green: 0.1, blue: 0.15), coverPhoto: "file:///Users/hedy/.gemini/antigravity/brain/c701732b-1506-4db1-adac-c15d300b51aa/midnight_echoes_cover_1778405740695.png"),
        BoardItem(title: "Velvet Distortion", tag: "TEXTURE · WARM", color: Color(red: 0.3, green: 0.1, blue: 0.05), coverPhoto: "file:///Users/hedy/.gemini/antigravity/brain/c701732b-1506-4db1-adac-c15d300b51aa/velvet_distortion_cover_1778405783107.png"),
        BoardItem(title: "Dune Rhythm", tag: "BEAT · EARTH", color: Color(red: 0.35, green: 0.2, blue: 0.1), coverPhoto: "file:///Users/hedy/.gemini/antigravity/brain/c701732b-1506-4db1-adac-c15d300b51aa/dune_rhythm_cover_1778405831642.png"),
        BoardItem(title: "Static Pulse", tag: "ENERGY · ELECTRIC", color: Color(red: 0.1, green: 0.1, blue: 0.3), coverPhoto: "file:///Users/hedy/.gemini/antigravity/brain/c701732b-1506-4db1-adac-c15d300b51aa/static_pulse_cover_1778405966946.png")
    ]

    @Published var discoveredArtists: [Artist] = [
        Artist(name: "Ariel Blue", identity: "Dream Pop Vocalist"),
        Artist(name: "Kaelo", identity: "Neo-Soul Producer"),
        Artist(name: "Sora", identity: "Ambient Soundscapes"),
        Artist(name: "Juno", identity: "Indie Electronica"),
        Artist(name: "Lumi", identity: "Vocal Architect")
    ]

    func toggleFollowArtist(id: UUID) {
        if let index = discoveredArtists.firstIndex(where: { $0.id == id }) {
            discoveredArtists[index].isFollowing.toggle()
        }
    }

    @Published var notifications: [AppNotification] = []

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private let randomUsers = ["Artist_Muse", "SonicExplorer", "Visionary", "PureVibe", "DigitalSoul", "Echo_Writer"]

    func createBoard(title: String, tag: String) {
        let colors: [Color] = [.purple, .blue, .orange, .pink, .gray]
        let newBoard = BoardItem(title: title, tag: tag, color: colors.randomElement() ?? .purple)
        boards.append(newBoard)
    }
    
    func savePost(postID: UUID, toBoardID boardID: UUID) {
        if let index = boards.firstIndex(where: { $0.id == boardID }) {
            if !boards[index].postIDs.contains(postID) {
                boards[index].postIDs.append(postID)
            }
        }
        
        // Mark the post as saved globally
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            posts[postIndex].isSaved = true
        }
    }
    
    func getPosts(for board: BoardItem) -> [Post] {
        return posts.filter { board.postIDs.contains($0.id) }
    }

    func toggleLike(for postID: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            posts[index].isLiked.toggle()
            if posts[index].isLiked {
                posts[index].likes += 1
                let user = randomUsers.randomElement() ?? "Someone"
                addNotification(type: .like, message: "\(user) liked your photo: \(posts[index].title)")
            } else {
                posts[index].likes -= 1
            }
        }
    }

    func addNotification(type: AppNotification.NotificationType, message: String) {
        let newNotif = AppNotification(type: type, message: message)
        notifications.insert(newNotif, at: 0)
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
    }

    func toggleSave(for postID: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            posts[index].isSaved.toggle()
        }
    }
    
    func setReaction(for postID: UUID, reaction: String) {
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            posts[index].reaction = reaction
        }
    }
    
    func addPost(username: String = "You", userAvatarData: Data? = nil, userProfession: String? = nil, tag: String, title: String, description: String, imageData: Data? = nil, isAudio: Bool = false) {
        let newPost = Post(username: username, userAvatarData: userAvatarData, userProfession: userProfession, tag: tag, title: title, description: description, likes: 0, imageData: imageData, isAudio: isAudio)
        posts.insert(newPost, at: 0)
    }
    
    func addComment(to postID: UUID, text: String) {
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            posts[index].comments.append(text)
            let user = randomUsers.randomElement() ?? "Someone"
            addNotification(type: .comment, message: "\(user) commented: \"\(text)\"")
        }
    }
}
