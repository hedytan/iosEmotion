import SwiftUI
import Combine

struct Post: Identifiable, Hashable {
    let id: UUID = UUID()
    let artist: String
    let song: String
    let mood: String
    let moodType: MoodType
    let quote: String
    let resonanceCount: String
    let year: String
    let daysAgo: Int
    
    enum MoodType: CaseIterable {
        case joy, melancholy, wonder, tender, urgency, awe
        
        var color: Color {
            switch self {
            case .joy: return Color(hex: "F0A840")
            case .melancholy: return Color(hex: "6888B8")
            case .wonder: return Color(hex: "40B8C8")
            case .tender: return Color(hex: "D890B8")
            case .urgency: return Color(hex: "E05040")
            case .awe: return Color(hex: "7090D0")
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
            }
        }
    }
}

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var hasCompletedOnboarding: Bool = false
    
    init() {
        self.posts = [
            Post(artist: "Jay Chou", song: "稻香", mood: "Joy", moodType: .joy, quote: "I wrote the first verse in my mother's kitchen at 2am. The smell of her cooking — that was the whole song.", resonanceCount: "2.4k", year: "2008", daysAgo: 3),
            Post(artist: "Frank Ocean", song: "Blonde", mood: "Melancholy", moodType: .melancholy, quote: "I kept starting over. I didn't know what I was trying to say until I stopped trying.", resonanceCount: "8.1k", year: "2016", daysAgo: 5),
            Post(artist: "Adele", song: "Someone Like You", mood: "Tender", moodType: .tender, quote: "I wrote this for him but never sent it. The song was the letter I couldn't give.", resonanceCount: "31k", year: "2011", daysAgo: 1),
            Post(artist: "Björk", song: "Jóga", mood: "Wonder", moodType: .wonder, quote: "Standing on a glacier. That was it. That was the whole album right there.", resonanceCount: "12k", year: "1997", daysAgo: 7)
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
