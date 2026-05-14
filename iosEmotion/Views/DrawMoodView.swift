import SwiftUI
import PencilKit

struct DrawMoodView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: Color = Color(hex: "F0A840")
    @State private var moodName: String = ""
    @State private var showingSaveAlert = false
    
    let colors: [Color] = [
        Color(hex: "F0A840"), // Joy
        Color(hex: "7499D1"), // Melancholy
        Color(hex: "49C2C2"), // Wonder
        Color(hex: "D991BA"), // Tender
        Color(hex: "E05C42"), // Urgency
        Color(hex: "7092E1"), // Awe
        Color(hex: "89C9A4"), // Peace
        Color(hex: "C4C4C4")  // Neutral
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            VStack(spacing: 24) {
                // NAVIGATION
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                            Text("back")
                        }
                        .font(.custom("DMMono-Regular", size: 14)) // Boosted from 12
                        .foregroundColor(.white.opacity(0.6)) // Boosted from 0.3
                    }
                    
                    Spacer()
                    
                    Text("draw your mood")
                        .font(.custom("Lora-Italic", size: 18)) // Boosted from 16
                        .foregroundColor(.white.opacity(0.85)) // Boosted from 0.7
                    
                    Spacer()
                    
                    Button("done") {
                        saveMood()
                    }
                    .font(.custom("DMMono-Regular", size: 14)) // Boosted from 12
                    .foregroundColor(moodName.isEmpty ? .white.opacity(0.15) : .white.opacity(0.7)) // Boosted
                    .disabled(moodName.isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                VStack(spacing: 8) {
                    Text("draw how this moment feels")
                        .font(.custom("Lora-Italic", size: 15)) // Boosted from 13
                        .foregroundColor(.white.opacity(0.35)) // Boosted from 0.2
                }
                
                // CANVAS
                CanvasRepresentable(canvasView: $canvasView, color: selectedColor)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.white.opacity(0.015))
                    .cornerRadius(32)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal, 24)
                
                // COLOR PICKER
                VStack(alignment: .leading, spacing: 16) {
                    Text("colour")
                        .font(.custom("DMMono-Regular", size: 11)) // Boosted from 8
                        .kerning(1.5)
                        .textCase(.uppercase)
                        .foregroundColor(.white.opacity(0.45)) // Boosted from 0.2
                    
                    HStack(spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                        .padding(-4)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // NAME INPUT
                VStack(alignment: .leading, spacing: 16) {
                    Text("name this mood")
                        .font(.custom("DMMono-Regular", size: 11)) // Boosted from 8
                        .kerning(1.5)
                        .textCase(.uppercase)
                        .foregroundColor(.white.opacity(0.45)) // Boosted from 0.2
                    
                    HStack(spacing: 16) {
                        Image(systemName: "circle.circle")
                            .font(.system(size: 18))
                            .foregroundColor(selectedColor.opacity(0.6))
                        
                        TextField("Love", text: $moodName)
                            .font(.custom("Lora-Italic", size: 18)) // Boosted from 16
                            .foregroundColor(.white.opacity(0.85)) // Boosted from 0.7
                    }
                    .padding(.vertical, 16).padding(.horizontal, 20)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
    
    private func saveMood() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        let newCustomMood = CustomMood(
            name: moodName,
            drawing: canvasView.drawing,
            thumbnail: image,
            strokeColor: selectedColor
        )
        store.addCustomMood(newCustomMood)
        dismiss()
    }
}

struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var color: Color
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        
        let tool = PKInkingTool(.pen, color: UIColor(color), width: 3)
        canvasView.tool = tool
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        let tool = PKInkingTool(.pen, color: UIColor(color), width: 3)
        uiView.tool = tool
    }
}
