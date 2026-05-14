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
        Color(hex: "F0A840"), Color(hex: "6888B8"), Color(hex: "40B8C8"),
        Color(hex: "D890B8"), Color(hex: "E05040"), Color(hex: "7090D0"),
        Color(hex: "80C0A0"), Color(hex: "B0B0B0")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NAVIGATION BAR
                HStack {
                    Button("← back") { dismiss() }
                        .font(.custom("DMMono-Regular", size: 11))
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Text("draw your mood")
                        .font(.custom("Lora-Italic", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Button("done") { saveDrawing() }
                        .font(.custom("DMMono-Regular", size: 11))
                        .foregroundColor(moodName.isEmpty ? .white.opacity(0.1) : .white.opacity(0.8))
                        .disabled(moodName.isEmpty)
                }
                .padding(.horizontal, 24).padding(.vertical, 20)
                
                Text("draw how this moment feels")
                    .font(.custom("Lora-Italic", size: 13.5))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.vertical, 8)
                
                // DRAWING CANVAS
                ZStack {
                    CanvasRepresentable(canvasView: $canvasView, color: selectedColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 380)
                        .cornerRadius(32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                    
                    if !isDrawing && canvasView.drawing.strokes.isEmpty {
                        Text("let your hand speak")
                            .font(.custom("Lora-Italic", size: 16))
                            .foregroundColor(.white.opacity(0.1))
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // COLOR PICKER
                VStack(alignment: .leading, spacing: 14) {
                    Text("colour")
                        .font(.custom("DMMono-Regular", size: 8))
                        .foregroundColor(.white.opacity(0.18))
                        .padding(.horizontal, 24)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 32)
                
                // MOOD NAME
                VStack(alignment: .leading, spacing: 14) {
                    Text("name this mood")
                        .font(.custom("DMMono-Regular", size: 8))
                        .foregroundColor(.white.opacity(0.18))
                    
                    HStack(spacing: 16) {
                        Image(systemName: "circle.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.3))
                        
                        TextField("what do you call this feeling?", text: $moodName)
                            .font(.custom("Lora-Italic", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .tint(selectedColor)
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.02)))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                Spacer()
            }
        }
    }
    
    func saveDrawing() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        let newMood = CustomMood(name: moodName, drawing: canvasView.drawing, strokeColor: selectedColor, thumbnail: image)
        store.customMoods.insert(newMood, at: 0)
        dismiss()
    }
}

struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var color: Color
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        
        // Corrected PKInkingTool initialization
        canvasView.tool = PKInkingTool(.pen, color: UIColor(color), width: 2)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool color when selectedColor changes
        uiView.tool = PKInkingTool(.pen, color: UIColor(color), width: 2)
    }
}
