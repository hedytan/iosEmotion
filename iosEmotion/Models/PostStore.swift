import SwiftUI
import Combine
import PencilKit

struct CustomMood: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let drawing: PKDrawing
    let strokeColor: Color
    let thumbnail: UIImage
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CustomMood, rhs: CustomMood) -> Bool {
        lhs.id == rhs.id
    }
}

struct ResonanceOption: Identifiable, Hashable {
    let id = UUID()
    let label: String
    var count: Int
    var isSelectedByCurrentUser: Bool = false
    var mood: Post.MoodType // Pre-assigned mood for this option
}

struct CustomResonance: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let mood: Post.MoodType
    let authorIsCurrentUser: Bool
}

struct Post: Identifiable, Hashable {
    let id = UUID()
    let artist: String
    let song: String
    let mood: String
    let moodType: MoodType
    let customMood: CustomMood?
    let attachedImage: UIImage?
    let quote: String
    var resonanceCount: Int
    var resonanceOptions: [ResonanceOption]
    var customResonances: [CustomResonance] = []
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
            case .melancholy: return Color(hex: "6888B8")
            case .wonder: return Color(hex: "40B8C8")
            case .tender: return Color(hex: "D890B8")
            case .urgency: return Color(hex: "E05040")
            case .awe: return Color(hex: "7090D0")
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
            Post(artist: "Jay Chou", song: "稻香", mood: "Joy", moodType: .joy, customMood: nil, attachedImage: nil, quote: "I wrote the first verse in my mother's kitchen at 2am. The smell of her cooking — that was the whole song.", resonanceCount: 2400, resonanceOptions: [
                ResonanceOption(label: "felt this in my chest", count: 1247, mood: .joy),
                ResonanceOption(label: "took me somewhere else", count: 890, mood: .melancholy),
                ResonanceOption(label: "reminds me of someone", count: 654, mood: .tender),
                ResonanceOption(label: "can't explain it", count: 432, mood: .wonder),
                ResonanceOption(label: "held my breath", count: 156, mood: .awe)
            ], year: "2008", daysAgo: 3),
            Post(artist: "Frank Ocean", song: "Blonde", mood: "Melancholy", moodType: .melancholy, customMood: nil, attachedImage: nil, quote: "I kept starting over. I didn't know what I was trying to say until I stopped trying.", resonanceCount: 8100, resonanceOptions: [
                ResonanceOption(label: "felt this in my chest", count: 4100, mood: .joy),
                ResonanceOption(label: "took me somewhere else", count: 2100, mood: .melancholy),
                ResonanceOption(label: "reminds me of someone", count: 1540, mood: .tender),
                ResonanceOption(label: "can't explain it", count: 820, mood: .wonder),
                ResonanceOption(label: "held my breath", count: 250, mood: .awe)
            ], year: "2016", daysAgo: 5)
        ]
    }
    
    func toggleResonance(for postID: UUID, optionID: UUID) {
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            if let optionIndex = posts[postIndex].resonanceOptions.firstIndex(where: { $0.id == optionID }) {
                let isNowSelected = !posts[postIndex].resonanceOptions[optionIndex].isSelectedByCurrentUser
                posts[postIndex].resonanceOptions[optionIndex].isSelectedByCurrentUser = isNowSelected
                posts[postIndex].resonanceOptions[optionIndex].count += (isNowSelected ? 1 : -1)
                posts[postIndex].resonanceCount += (isNowSelected ? 1 : -1)
            }
        }
    }
    
    func addCustomResonance(for postID: UUID, text: String, mood: Post.MoodType) {
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            let newRes = CustomResonance(text: text, mood: mood, authorIsCurrentUser: true)
            posts[postIndex].customResonances.append(newRes)
            posts[postIndex].resonanceCount += 1
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
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
