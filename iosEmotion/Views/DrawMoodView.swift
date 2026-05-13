import SwiftUI
import PencilKit

struct DrawMoodView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor = Color(hex: "F0A840")
    @State private var moodName = ""
    @State private var isDrawing = false
    
    let colors = [
        Color(hex: "F0A840"), Color(hex: "6888B8"), Color(hex: "40B8C8"), Color(hex: "D890B8"),
        Color(hex: "E05040"), Color(hex: "7090D0"), Color(hex: "88C8A0"), Color.white.opacity(0.6)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "07060B").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NAVIGATION BAR
                HStack {
                    Button("← back") { dismiss() }
                        .font(.custom("DMMono-Regular", size: 9))
                        .foregroundColor(.white.opacity(0.28))
                    Spacer()
                    Text("draw your mood")
                        .font(.custom("Lora-Italic", size: 14))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Button("done") { saveDrawing() }
                        .font(.custom("DMMono-Regular", size: 9))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24).padding(.vertical, 16)
                
                Text("draw how this moment feels")
                    .font(.custom("Lora-Italic", size: 12))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.vertical, 8)
                
                // CANVAS
                ZStack {
                    CanvasRepresentable(canvasView: $canvasView, color: selectedColor, isDrawing: $isDrawing)
                        .frame(height: 210)
                        .background(Color.white.opacity(0.01))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.07), lineWidth: 1))
                    
                    if !isDrawing && canvasView.drawing.strokes.isEmpty {
                        Text("let your hand speak")
                            .font(.custom("Lora-Italic", size: 13))
                            .foregroundColor(.white.opacity(0.1))
                    }
                }
                .padding(.horizontal, 20).padding(.top, 12)
                
                // COLOR PICKER
                VStack(alignment: .leading, spacing: 12) {
                    Text("colour")
                        .font(.custom("DMMono-Regular", size: 7.5))
                        .kerning(1.2).foregroundColor(.white.opacity(0.2))
                    
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 22, height: 22)
                                    .scaleEffect(selectedColor == color ? 1.22 : 1.0)
                                    .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 1.5 : 0))
                            }
                        }
                        Spacer()
                        Button("clear") { canvasView.drawing = PKDrawing() }
                            .font(.custom("DMMono-Regular", size: 7.5))
                            .underline().foregroundColor(.white.opacity(0.2))
                    }
                }
                .padding(.horizontal, 20).padding(.top, 24)
                
                // NAME INPUT
                VStack(alignment: .leading, spacing: 12) {
                    Text("name this mood")
                        .font(.custom("DMMono-Regular", size: 7.5))
                        .kerning(1.2).foregroundColor(.white.opacity(0.2))
                    
                    HStack(spacing: 0) {
                        Text("◎")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 12)
                            .overlay(Rectangle().fill(Color.white.opacity(0.05)).frame(width: 1), alignment: .trailing)
                        
                        TextField("what do you call this feeling?", text: $moodName)
                            .font(.custom("DMMono-Regular", size: 11))
                            .foregroundColor(.white.opacity(0.65))
                            .kerning(0.6)
                            .padding(.horizontal, 12)
                            .submitLabel(.done)
                    }
                    .frame(height: 44)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .padding(.horizontal, 20).padding(.top, 24)
                
                Spacer()
                
                // ACTION BUTTON
                Button(action: saveDrawing) {
                    Text("use this shape →")
                        .font(.custom("DMMono-Regular", size: 9.5))
                        .kerning(1.4).textCase(.uppercase).foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(11)
                        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
                .padding(.horizontal, 20).padding(.bottom, 34)
            }
        }
    }
    
    private func saveDrawing() {
        let drawing = canvasView.drawing
        // Capture transparent thumbnail
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        let customMood = CustomMood(name: moodName.isEmpty ? "Unknown" : moodName, drawing: drawing, strokeColor: selectedColor, thumbnail: image)
        store.customMoods.append(customMood)
        dismiss()
    }
}

struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var color: Color
    @Binding var isDrawing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: UIColor(color), width: 2.5)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = PKInkingTool(.pen, color: UIColor(color), width: 2.5)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasRepresentable
        init(_ parent: CanvasRepresentable) { self.parent = parent }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) { parent.isDrawing = true }
    }
}
