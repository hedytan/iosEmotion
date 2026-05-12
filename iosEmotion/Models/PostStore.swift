import SwiftUI
import Combine

struct Post: Identifiable, Hashable {
    let id: UUID = UUID()
    let artist: String
    let song: String
    let mood: String
    let moodColor: Color
    let quote: String
    let resonanceCount: String
    let moodType: MoodType
    var isLiked: Bool = false
    
    enum MoodType {
        case joy, melancholy, tender, wonder, urgency, awe
    }
}

class PostStore: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    
    @Published var posts: [Post] = [
        Post(artist: "Jay Chou", song: "稻香", mood: "Joy", 
             moodColor: Color(hex: "f0a840"),
             quote: "I wrote the first verse in my mother's kitchen at 2am. The smell of her cooking — that was the whole song.",
             resonanceCount: "2.4k", moodType: .joy),
        
        Post(artist: "Frank Ocean", song: "Blonde", mood: "Melancholy", 
             moodColor: Color(hex: "6888b8"),
             quote: "I kept starting over. I didn't know what I was trying to say until I stopped trying.",
             resonanceCount: "8.1k", moodType: .melancholy),
        
        Post(artist: "Adele", song: "Someone Like You", mood: "Tender", 
             moodColor: Color(hex: "d890b8"),
             quote: "I wrote this for him but never sent it. The song was the letter I couldn't give.",
             resonanceCount: "31k", moodType: .tender)
    ]
    
    func toggleLike(for id: UUID) {
        if let index = posts.firstIndex(where: { $0.id == id }) {
            posts[index].isLiked.toggle()
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
