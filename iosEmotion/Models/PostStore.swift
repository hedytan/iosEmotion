import SwiftUI
import Combine
import PencilKit

struct CustomMood: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let drawing: PKDrawing
    let strokeColor: Color
    let thumbnail: UIImage
    
    // Conforming to Hashable for PKDrawing and UIImage
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CustomMood, rhs: CustomMood) -> Bool {
        lhs.id == rhs.id
    }
}

struct Post: Identifiable, Hashable {
    let id: UUID = UUID()
    let artist: String
    let song: String
    let mood: String
    let moodType: MoodType
    let customMood: CustomMood? // Support for custom hand-drawn moods
    let quote: String
    let resonanceCount: String
    let year: String
    let daysAgo: Int
    
    enum MoodType: CaseIterable, Hashable {
        case joy, melancholy, wonder, tender, urgency, awe, custom
        
        var color: Color {
            switch self {
            case .joy: return Color(hex: "F0A840")
            case .melancholy: return Color(hex: "6888B8")
            case .wonder: return Color(hex: "40B8C8")
            case .tender: return Color(hex: "D890B8")
            case .urgency: return Color(hex: "E05040")
            case .awe: return Color(hex: "7090D0")
            case .custom: return Color.white.opacity(0.8)
            }
        }
        
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
    }
}

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var customMoods: [CustomMood] = []
    @Published var hasCompletedOnboarding: Bool = false
    
    init() {
        self.posts = [
            Post(artist: "Jay Chou", song: "稻香", mood: "Joy", moodType: .joy, customMood: nil, quote: "I wrote the first verse in my mother's kitchen at 2am. The smell of her cooking — that was the whole song.", resonanceCount: "2.4k", year: "2008", daysAgo: 3),
            Post(artist: "Frank Ocean", song: "Blonde", mood: "Melancholy", moodType: .melancholy, customMood: nil, quote: "I kept starting over. I didn't know what I was trying to say until I stopped trying.", resonanceCount: "8.1k", year: "2016", daysAgo: 5),
            Post(artist: "Adele", song: "Someone Like You", mood: "Tender", moodType: .tender, customMood: nil, quote: "I wrote this for him but never sent it. The song was the letter I couldn't give.", resonanceCount: "31k", year: "2011", daysAgo: 1),
            Post(artist: "Björk", song: "Jóga", mood: "Wonder", moodType: .wonder, customMood: nil, quote: "Standing on a glacier. That was it. That was the whole album right there.", resonanceCount: "12k", year: "1997", daysAgo: 7)
        ]
    }
}
