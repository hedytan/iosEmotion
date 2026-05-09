import Foundation

struct Post: Identifiable {
    let id = UUID()
    let username: String
    let userAvatarData: Data? // New property for artist's profile picture
    var tag: String
    var title: String
    var description: String
    var likes: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    var reaction: String? = nil
    var imageData: Data? = nil
    var isAudio: Bool = false
    var comments: [String] = []
    
    init(username: String = "You", userAvatarData: Data? = nil, tag: String, title: String, description: String, likes: Int = 0, imageData: Data? = nil, isAudio: Bool = false, comments: [String] = []) {
        self.username = username
        self.userAvatarData = userAvatarData
        self.tag = tag
        self.title = title
        self.description = description
        self.likes = likes
        self.imageData = imageData
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
