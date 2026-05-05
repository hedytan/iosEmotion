import SwiftUI

class PostStore: ObservableObject {
    @Published var posts: [Post] = [
        Post(tag: "SPOTLIGHT", title: "LIMBO", description: "The sonic architecture of a dream state. Exploring the reverb trails in GABRIEL.", likes: 24100, comments: ["This is incredible", "The production is top notch!", "Can't wait for the full release"]),
        Post(tag: "NEW FRAGMENT", title: "The Geometry of Noise", description: "This album got me through the hardest year of my life.", likes: 12400, comments: ["I feel this", "Pure art"]),
        Post(tag: "FRAGMENT", title: "Studio Session 01", description: "3am and the chords finally made sense.", likes: 8200, comments: ["Relatable", "3am sessions are the best"])
    ]
    
    func toggleLike(for postID: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            posts[index].isLiked.toggle()
            if posts[index].isLiked {
                posts[index].likes += 1
            } else {
                posts[index].likes -= 1
            }
        }
    }
    
    func addComment(to postID: UUID, text: String) {
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            posts[index].comments.append(text)
        }
    }
}
