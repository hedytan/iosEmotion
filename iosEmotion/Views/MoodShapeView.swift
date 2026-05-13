import SwiftUI
import PencilKit

struct MoodShapeView: View {
    var type: Post.MoodType
    var color: Color
    var isLarge: Bool = false
    var customMood: CustomMood? = nil
    var drawing: PKDrawing? = nil
    
    var body: some View {
        ZStack {
            if type == .custom || customMood != nil || drawing != nil {
                // Raw Custom Shape
                if let draw = drawing ?? customMood?.drawing {
                    CustomDrawingView(drawing: draw, color: color)
                } else if let thumb = customMood?.thumbnail {
                    Image(uiImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                // Preset Organic Shape
                MoodShape(type: type)
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.16), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: isLarge ? 60 : 24
                        )
                    )
                    .overlay(
                        MoodShape(type: type)
                            .stroke(color.opacity(0.5), lineWidth: 1)
                    )
            }
        }
    }
}

struct CustomDrawingView: View {
    var drawing: PKDrawing
    var color: Color
    
    var body: some View {
        Canvas { context, size in
            // Rendering the drawing with the theme color
            for stroke in drawing.strokes {
                var path = Path()
                let points = stroke.path.map { $0.location }
                if let first = points.first {
                    path.move(to: first)
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                context.stroke(path, with: .color(color.opacity(0.8)), lineWidth: 1.5)
            }
        }
    }
}

struct MoodShape: Shape {
    var type: Post.MoodType
    func path(in rect: CGRect) -> Path {
        switch type {
        case .joy: return JoyShape().path(in: rect)
        case .melancholy: return MelancholyShape().path(in: rect)
        case .wonder: return WonderShape().path(in: rect)
        case .tender: return TenderShape().path(in: rect)
        case .urgency: return UrgencyShape().path(in: rect)
        case .awe: return AweShape().path(in: rect)
        case .custom: return Circle().path(in: rect)
        }
    }
}
