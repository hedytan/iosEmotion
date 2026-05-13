import SwiftUI
import Combine
import PencilKit

struct CustomMood: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let drawing: PKDrawing
    let strokeColor: Color
    let thumbnail: UIImage
    
    // Conforming to Hashable manually for non-conforming types
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CustomMood, rhs: CustomMood) -> Bool {
        lhs.id == rhs.id
    }
}

struct Post: Identifiable, Hashable {
    let id = UUID()
    let artist: String
    let song: String
    let mood: String
    let moodType: MoodType
    let customMood: CustomMood? // Support for custom hand-drawn moods
    let attachedImage: UIImage? // Support for optional photo attachment
    let quote: String
    let resonanceCount: String
    let year: String
    let daysAgo: Int
    
    var themeColor: Color {
        customMood?.strokeColor ?? moodType.color
    }
    
    enum MoodType: CaseIterable, Hashable {
        case joy, melancholy, wonder, tender, urgency, awe, custom
        
        var displayName: String {
            switch self {
            case .joy: return "Joy"
            case .melancholy: return "Melancholy"
            case .wonder: return "Wonder"
            case .tender: return "Tender"
            case .urgency: return "Urgency"
            case .awe: return "Awe"
            case .custom: return "Custom"
            }
        }
        
        var color: Color {
            switch self {
            case .joy: return Color(hex: "F0A840")
            case .melancholy: return Color(hex: "6888B0")
            case .wonder: return Color(hex: "88B080")
            case .tender: return Color(hex: "D890B8")
            case .urgency: return Color(hex: "B06060")
            case .awe: return Color(hex: "A080C0")
            case .custom: return Color.white.opacity(0.8)
            }
        }
    }
}

struct ResonanceConnection: Hashable {
    let post: Post
    let feeling: String
    let userMood: Post.MoodType
}

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var customMoods: [CustomMood] = []
    @Published var hasCompletedOnboarding: Bool = false
    
    init() {
        self.posts = [
            Post(artist: "Jay Chou", song: "稻香", mood: "Joy", moodType: .joy, customMood: nil, attachedImage: nil, quote: "I wrote the first verse in my mother's kitchen at 2am. The smell of her cooking — that was the whole song.", resonanceCount: "2.4k", year: "2008", daysAgo: 3),
            Post(artist: "Frank Ocean", song: "Blonde", mood: "Melancholy", moodType: .melancholy, customMood: nil, attachedImage: nil, quote: "I kept starting over. I didn't know what I was trying to say until I stopped trying.", resonanceCount: "8.1k", year: "2016", daysAgo: 5),
            Post(artist: "Adele", song: "Someone Like You", mood: "Tender", moodType: .tender, customMood: nil, attachedImage: nil, quote: "I wrote this for him but never sent it. The song was the letter I couldn't give.", resonanceCount: "31k", year: "2011", daysAgo: 1),
            Post(artist: "Björk", song: "Jóga", mood: "Wonder", moodType: .wonder, customMood: nil, attachedImage: nil, quote: "Standing on a glacier. That was it. That was the whole album right there.", resonanceCount: "12k", year: "1997", daysAgo: 7)
        ]
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
