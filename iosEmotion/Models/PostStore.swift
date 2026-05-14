import SwiftUI
import Combine
import PencilKit

// MARK: - Models

struct CustomMood: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let drawing: PKDrawing
    let strokeColor: Color
    var thumbnail: UIImage
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CustomMood, rhs: CustomMood) -> Bool { lhs.id == rhs.id }
}

struct ResonanceOption: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let mood: Post.MoodType
    var count: Int
    var isSelectedByCurrentUser: Bool = false
    let isCustom: Bool
}

struct Post: Identifiable, Hashable {
    let id = UUID()
    let artist: String
    let moodType: MoodType
    let quote: String
    let song: String
    let year: String
    var resonanceCount: Int
    let timestamp: Date = Date()
    var attachedImage: UIImage?
    var customShape: PKDrawing?
    var customShapeName: String?
    
    var resonanceOptions: [ResonanceOption] = []
    var customResonances: [ResonanceOption] = []
    
    var themeColor: Color { moodType.color }
    var mood: String { moodType.displayName }
    
    // Manual Hashable to avoid issues with UIImage and PKDrawing
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Post, rhs: Post) -> Bool { lhs.id == rhs.id }
    
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

// MARK: - Mood Shapes (Organic Paths)

struct JoyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w*0.2, y: h*0.4))
        path.addCurve(to: CGPoint(x: w*0.8, y: h*0.2), control1: CGPoint(x: w*0.1, y: h*0.1), control2: CGPoint(x: w*0.5, y: 0))
        path.addCurve(to: CGPoint(x: w*0.9, y: h*0.7), control1: CGPoint(x: w, y: h*0.3), control2: CGPoint(x: w*1.1, y: h*0.6))
        path.addCurve(to: CGPoint(x: w*0.4, y: h*0.9), control1: CGPoint(x: w*0.7, y: h*0.9), control2: CGPoint(x: w*0.6, y: h))
        path.addCurve(to: CGPoint(x: w*0.2, y: h*0.4), control1: CGPoint(x: w*0.1, y: h*0.8), control2: CGPoint(x: 0, y: h*0.5))
        return path
    }
}

struct MelancholyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w*0.5, y: 0))
        path.addCurve(to: CGPoint(x: w*0.5, y: h), control1: CGPoint(x: w*0.2, y: h*0.3), control2: CGPoint(x: 0, y: h*0.7))
        path.addCurve(to: CGPoint(x: w*0.5, y: 0), control1: CGPoint(x: w, y: h*0.7), control2: CGPoint(x: w*0.8, y: h*0.3))
        return path
    }
}

struct WonderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height, cx = w/2, cy = h/2
        let points = 8
        for i in 0..<points*2 {
            let angle = CGFloat(i) * .pi / CGFloat(points)
            let r = i % 2 == 0 ? w/2 : w/6
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

struct TenderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w*0.5, y: h*0.05))
        path.addCurve(to: CGPoint(x: w*0.92, y: h*0.48), control1: CGPoint(x: w*0.78, y: h*0.05), control2: CGPoint(x: w*0.95, y: h*0.22))
        path.addCurve(to: CGPoint(x: w*0.52, y: h*0.95), control1: CGPoint(x: w*0.88, y: h*0.78), control2: CGPoint(x: w*0.72, y: h*0.95))
        path.addCurve(to: CGPoint(x: w*0.08, y: h*0.52), control1: CGPoint(x: w*0.32, y: h*0.95), control2: CGPoint(x: w*0.05, y: h*0.72))
        path.addCurve(to: CGPoint(x: w*0.5, y: h*0.05), control1: CGPoint(x: w*0.12, y: h*0.28), control2: CGPoint(x: w*0.22, y: h*0.05))
        return path
    }
}

struct UrgencyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w/2, y: 0))
        path.addLine(to: CGPoint(x: w, y: h/2))
        path.addLine(to: CGPoint(x: w/2, y: h))
        path.addLine(to: CGPoint(x: 0, y: h/2))
        path.closeSubpath()
        return path
    }
}

struct AweShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height, cx = w/2, cy = h/2
        for i in 0..<3 {
            let r = (w/2) * CGFloat(3-i)/3
            path.addEllipse(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2))
        }
        return path
    }
}

// MARK: - PostStore

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var customMoods: [CustomMood] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var navigationPath = NavigationPath()
    
    init() {
        self.posts = [
            Post(
                artist: "Jay Chou", 
                moodType: .joy, 
                quote: "I wrote the first verse in my mother's kitchen at 2am. The smell of her cooking — that was the whole song.", 
                song: "稻香", 
                year: "2008", 
                resonanceCount: 2418, 
                resonanceOptions: [
                    ResonanceOption(text: "smell of home cooking", mood: .tender, count: 842, isCustom: false),
                    ResonanceOption(text: "back to simpler times", mood: .melancholy, count: 654, isCustom: false),
                    ResonanceOption(text: "childhood summer vibes", mood: .joy, count: 432, isCustom: false),
                    ResonanceOption(text: "pure countryside air", mood: .wonder, count: 321, isCustom: false),
                    ResonanceOption(text: "this is my happy place", mood: .joy, count: 169, isCustom: false)
                ]
            ),
            Post(
                artist: "Frank Ocean", 
                moodType: .melancholy, 
                quote: "I kept starting over. I didn't know what I was trying to say until I stopped trying.", 
                song: "Blonde", 
                year: "2016", 
                resonanceCount: 8103, 
                resonanceOptions: [
                    ResonanceOption(text: "felt this in my chest", mood: .melancholy, count: 2147, isCustom: false),
                    ResonanceOption(text: "beautiful sadness", mood: .awe, count: 1890, isCustom: false),
                    ResonanceOption(text: "growing pains", mood: .urgency, count: 1654, isCustom: false),
                    ResonanceOption(text: "lost in the memories", mood: .tender, count: 1432, isCustom: false),
                    ResonanceOption(text: "found myself replaying it", mood: .melancholy, count: 980, isCustom: false)
                ]
            ),
            Post(
                artist: "Adele", 
                moodType: .tender, 
                quote: "I wrote this for him but never sent it. The song was the letter I couldn't give.", 
                song: "Someone Like You", 
                year: "2011", 
                resonanceCount: 31204, 
                resonanceOptions: [
                    ResonanceOption(text: "the letter I never sent", mood: .melancholy, count: 12402, isCustom: false),
                    ResonanceOption(text: "healing through tears", mood: .tender, count: 8904, isCustom: false),
                    ResonanceOption(text: "still wish you the best", mood: .joy, count: 5654, isCustom: false),
                    ResonanceOption(text: "found peace with it now", mood: .wonder, count: 3232, isCustom: false),
                    ResonanceOption(text: "hurts but it's okay", mood: .tender, count: 1012, isCustom: false)
                ]
            ),
            Post(
                artist: "Björk", 
                moodType: .wonder, 
                quote: "Standing on a glacier. That was it. That was the whole album right there.", 
                song: "Jóga", 
                year: "1997", 
                resonanceCount: 12088, 
                resonanceOptions: [
                    ResonanceOption(text: "standing on a glacier", mood: .awe, count: 4208, isCustom: false),
                    ResonanceOption(text: "rhythm of nature", mood: .wonder, count: 3204, isCustom: false),
                    ResonanceOption(text: "pure volcanic energy", mood: .urgency, count: 2120, isCustom: false),
                    ResonanceOption(text: "emotional landscape", mood: .melancholy, count: 1654, isCustom: false),
                    ResonanceOption(text: "state of emergency", mood: .urgency, count: 902, isCustom: false)
                ]
            )
        ]
    }
    
    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
    }
    
    func toggleResonance(for postID: UUID, optionID: UUID) {
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            if let optionIndex = posts[postIndex].resonanceOptions.firstIndex(where: { $0.id == optionID }) {
                posts[postIndex].resonanceOptions[optionIndex].isSelectedByCurrentUser.toggle()
                posts[postIndex].resonanceOptions[optionIndex].count += posts[postIndex].resonanceOptions[optionIndex].isSelectedByCurrentUser ? 1 : -1
                posts[postIndex].resonanceCount += posts[postIndex].resonanceOptions[optionIndex].isSelectedByCurrentUser ? 1 : -1
            }
        }
    }
    
    func addCustomResonance(for postID: UUID, text: String, mood: Post.MoodType) {
        if let postIndex = posts.firstIndex(where: { $0.id == postID }) {
            let newRes = ResonanceOption(text: text, mood: mood, count: 1, isSelectedByCurrentUser: true, isCustom: true)
            posts[postIndex].customResonances.insert(newRes, at: 0)
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
