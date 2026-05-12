import SwiftUI

struct MoodShapeView: View {
    var type: Post.MoodType
    var color: Color
    
    var body: some View {
        ZStack {
            // Radial Background Glow (12% opacity)
            shapePath()
                .fill(RadialGradient(colors: [color.opacity(0.12), .clear], center: .center, startRadius: 5, endRadius: 30))
            
            // Outer Stroke (55% opacity, 0.9pt)
            shapePath()
                .stroke(color.opacity(0.55), lineWidth: 0.9)
            
            // Inner Dashed Ring (15% opacity)
            shapePath()
                .scale(0.7)
                .stroke(color.opacity(0.15), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
        }
        .frame(width: 44, height: 44)
    }
    
    @ViewBuilder
    func shapePath() -> some Shape {
        switch type {
        case .joy:
            JoyShape()
        case .melancholy:
            MelancholyShape()
        case .tender:
            TenderShape()
        }
    }
}

struct JoyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.1),
                      control1: CGPoint(x: rect.width * 0.1, y: rect.height * 0.2),
                      control2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.05))
        path.addCurve(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.4),
                      control1: CGPoint(x: rect.width * 0.7, y: rect.height * 0.15),
                      control2: CGPoint(x: rect.width * 0.95, y: rect.height * 0.25))
        path.addCurve(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.9),
                      control1: CGPoint(x: rect.width * 0.85, y: rect.height * 0.6),
                      control2: CGPoint(x: rect.width * 0.9, y: rect.height * 0.85))
        path.addCurve(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4),
                      control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.95),
                      control2: CGPoint(x: rect.width * 0.05, y: rect.height * 0.6))
        path.closeSubpath()
        return path
    }
}

struct MelancholyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.05))
        path.addCurve(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.7),
                      control1: CGPoint(x: rect.width * 0.6, y: rect.height * 0.1),
                      control2: CGPoint(x: rect.width * 0.95, y: rect.height * 0.4))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.95),
                      control1: CGPoint(x: rect.width * 0.85, y: rect.height * 0.9),
                      control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.95))
        path.addCurve(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.7),
                      control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.95),
                      control2: CGPoint(x: rect.width * 0.15, y: rect.height * 0.9))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.05),
                      control1: CGPoint(x: rect.width * 0.05, y: rect.height * 0.4),
                      control2: CGPoint(x: rect.width * 0.4, y: rect.height * 0.1))
        path.closeSubpath()
        return path
    }
}

struct TenderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.addArc(center: center, radius: rect.width * 0.42, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        // Soft indent
        path.move(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.2))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.3),
                          control: CGPoint(x: rect.width * 0.75, y: rect.height * 0.22))
        return path
    }
}
