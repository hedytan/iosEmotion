import Foundation

struct Post: Identifiable {
    let id = UUID()
    var tag: String
    var title: String
    var description: String
    var likes: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    var reaction: String? = nil
    var imageData: Data? = nil
    var comments: [String] = []
    
    var likeCountString: String {
        if likes >= 1000 {
            return String(format: "%.1fk", Double(likes) / 1000.0)
        }
        return "\(likes)"
    }
}
