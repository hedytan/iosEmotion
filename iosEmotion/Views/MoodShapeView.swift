import SwiftUI

struct MoodShapeView: View {
    var type: Post.MoodType
    var color: Color
    var isLarge: Bool = false
    
    var body: some View {
        ZStack {
            // Soft glow behind shape when featured large
            if isLarge {
                Circle()
                    .fill(color.opacity(0.20))
                    .frame(width: 160, height: 160)
                    .blur(radius: 50)
            }
            
            // Radial Background Fill (15% opacity center -> 0%)
            MoodShape(type: type)
                .fill(RadialGradient(colors: [color.opacity(0.15), .clear], center: .center, startRadius: 0, endRadius: isLarge ? 60 : 22))
            
            // Outer Stroke (50% opacity, 1pt)
            MoodShape(type: type)
                .stroke(color.opacity(0.50), lineWidth: 1)
            
            // Inner Dashed Ring (15% opacity)
            MoodShape(type: type)
                .scale(0.7)
                .stroke(color.opacity(0.15), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
        }
    }
}

struct MoodShape: Shape {
    var type: Post.MoodType
    
    func path(in rect: CGRect) -> Path {
        switch type {
        case .joy:
            return joyPath(in: rect)
        case .melancholy:
            return melancholyPath(in: rect)
        case .wonder:
            return wonderPath(in: rect)
        case .tender:
            return tenderPath(in: rect)
        case .urgency:
            return urgencyPath(in: rect)
        case .awe:
            return awePath(in: rect)
        }
    }
    
    private func joyPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.1), control1: CGPoint(x: rect.width * 0.1, y: rect.height * 0.2), control2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.05))
        path.addCurve(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.45), control1: CGPoint(x: rect.width * 0.7, y: rect.height * 0.15), control2: CGPoint(x: rect.width * 0.95, y: rect.height * 0.3))
        path.addCurve(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.9), control1: CGPoint(x: rect.width * 0.85, y: rect.height * 0.6), control2: CGPoint(x: rect.width * 0.8, y: rect.height * 0.85))
        path.addCurve(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4), control1: CGPoint(x: rect.width * 0.35, y: rect.height * 0.95), control2: CGPoint(x: rect.width * 0.05, y: rect.height * 0.6))
        path.closeSubpath()
        return path
    }
    
    private func melancholyPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.05))
        path.addCurve(to: CGPoint(x: rect.width * 0.95, y: rect.height * 0.8), control1: CGPoint(x: rect.width * 0.7, y: rect.height * 0.1), control2: CGPoint(x: rect.width * 0.95, y: rect.height * 0.5))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.98), control1: CGPoint(x: rect.width * 0.95, y: rect.height * 0.95), control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.98))
        path.addCurve(to: CGPoint(x: rect.width * 0.05, y: rect.height * 0.8), control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.98), control2: CGPoint(x: rect.width * 0.05, y: rect.height * 0.95))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.05), control1: CGPoint(x: rect.width * 0.05, y: rect.height * 0.5), control2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.1))
        path.closeSubpath()
        return path
    }
    
    private func wonderPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 8
        let innerRadius = rect.width * 0.12
        let outerRadius = rect.width * 0.48
        for i in 0..<points * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(points)
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
    
    private func tenderPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width * 0.45
        path.move(to: CGPoint(x: center.x, y: center.y - radius * 0.85))
        path.addCurve(to: CGPoint(x: center.x + radius, y: center.y), control1: CGPoint(x: center.x + radius * 0.3, y: center.y - radius * 0.9), control2: CGPoint(x: center.x + radius, y: center.y - radius * 0.5))
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        path.addCurve(to: CGPoint(x: center.x, y: center.y - radius * 0.85), control1: CGPoint(x: center.x - radius, y: center.y - radius * 0.5), control2: CGPoint(x: center.x - radius * 0.3, y: center.y - radius * 0.9))
        path.closeSubpath()
        return path
    }
    
    private func urgencyPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.width * 0.95, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height * 0.95))
        path.addLine(to: CGPoint(x: rect.width * 0.05, y: rect.midY))
        path.closeSubpath()
        return path
    }
    
    private func awePath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for i in 0...2 {
            let radius = rect.width * (0.45 - CGFloat(i) * 0.15)
            path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        }
        return path
    }
}
