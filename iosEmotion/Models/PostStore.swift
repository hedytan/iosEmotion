import Foundation
import Combine

class PostStore: ObservableObject {
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

    @Published var notifications: [AppNotification] = []

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private let randomUsers = ["Artist_Muse", "SonicExplorer", "Visionary", "PureVibe", "DigitalSoul", "Echo_Writer"]

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
    
    func addPost(username: String = "You", tag: String, title: String, description: String, imageData: Data? = nil, isAudio: Bool = false) {
        let newPost = Post(username: username, tag: tag, title: title, description: description, likes: 0, imageData: imageData, isAudio: isAudio)
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
