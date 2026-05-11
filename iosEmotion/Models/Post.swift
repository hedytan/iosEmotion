import Foundation

struct Post: Identifiable {
    let id = UUID()
    let username: String
    let userAvatarData: Data?
    let userProfession: String? // New property for the artist's profession
    var tag: String
    var title: String
    var description: String
    var likes: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    var reaction: String? = nil
    var imageData: Data? = nil
    var imagePath: String? = nil // For local file paths
    var emotion: String? = nil // Emotional vibe tag (e.g., 🌙 Solitude)
    var isAudio: Bool = false
    var comments: [String] = []
    
    init(username: String = "You", userAvatarData: Data? = nil, userProfession: String? = nil, tag: String, title: String, description: String, likes: Int = 0, imageData: Data? = nil, imagePath: String? = nil, emotion: String? = nil, isAudio: Bool = false, comments: [String] = []) {
        self.username = username
        self.userAvatarData = userAvatarData
        self.userProfession = userProfession
        self.tag = tag
        self.title = title
        self.description = description
        self.likes = likes
        self.imageData = imageData
        self.imagePath = imagePath
        self.emotion = emotion
        self.isAudio = isAudio
        self.comments = comments
    }
    
    var likeCountString: String {
        if likes >= 1000 {
            return String(format: "%.1fk", Double(likes) / 1000.0)
        }
        return "\(likes)"
    }
}
