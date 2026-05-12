import SwiftUI
import PencilKit

struct DrawMoodSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor = Color(hex: "F0A840")
    @State private var selectedWeight: CGFloat = 3.0
    @State private var moodName = ""
    @State private var hasStartedDrawing = false
    
    let colors = [
        Color(hex: "F0A840"), Color(hex: "6888B8"), Color(hex: "40B8C8"), Color(hex: "D890B8"),
        Color(hex: "E05040"), Color(hex: "7090D0"), Color(hex: "B4A0D8"), Color(hex: "88C8A0")
    ]
    
    let weights: [(String, CGFloat)] = [
        ("Thin", 1.5), ("Medium", 3.0), ("Thick", 6.0), ("Bold", 10.0)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "08070B").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button("cancel") { dismiss() }
                        .font(.custom("DMMono-Regular", size: 9.5))
                        .foregroundColor(.white.opacity(0.28))
                    
                    Spacer()
                    
                    Text("draw your mood")
                        .font(.custom("Lora-Italic", size: 14))
                        .italic()
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Button("done") { saveAndDismiss() }
                        .font(.custom("DMMono-Regular", size: 9.5))
                        .foregroundColor(moodName.isEmpty || !hasStartedDrawing ? .white.opacity(0.2) : Color(hex: "F0A840"))
                        .disabled(moodName.isEmpty || !hasStartedDrawing)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // CANVAS AREA
                        ZStack {
                            CanvasView(canvasView: $canvasView, tool: PKInkingTool(.pen, color: UIColor(selectedColor), width: selectedWeight), hasStartedDrawing: $hasStartedDrawing)
                                .frame(height: 220)
                                .background(Color.white.opacity(0.015))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                                )
                            
                            if !hasStartedDrawing {
                                Text("let your hand speak")
                                    .font(.custom("Lora-Italic", size: 13))
                                    .italic()
                                    .foregroundColor(.white.opacity(0.10))
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // COLOR PICKER
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 22, height: 22)
                                        .scaleEffect(selectedColor == color ? 1.2 : 1.0)
                                        .overlay(
                                            Circle().stroke(Color.white, lineWidth: selectedColor == color ? 1.5 : 0)
                                        )
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedColor = color
                                            }
                                        }
                                }
                                
                                Spacer()
                                
                                Button("clear") {
                                    canvasView.drawing = PKDrawing()
                                    hasStartedDrawing = false
                                }
                                .font(.custom("DMMono-Regular", size: 8.5))
                                .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // STROKE WEIGHT
                        HStack(spacing: 12) {
                            ForEach(weights, id: \.1) { name, weight in
                                Button(action: { selectedWeight = weight }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedWeight == weight ? Color.white.opacity(0.1) : Color.white.opacity(0.04))
                                            .frame(width: 36, height: 36)
                                        
                                        Rectangle()
                                            .fill(Color.white.opacity(selectedWeight == weight ? 0.8 : 0.3))
                                            .frame(width: 14, height: weight / 2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // NAME INPUT
                        VStack(alignment: .leading, spacing: 12) {
                            Text("name this mood")
                                .font(.custom("DMMono-Regular", size: 7.5))
                                .foregroundColor(.white.opacity(0.18))
                            
                            HStack(spacing: 12) {
                                Text("◎")
                                    .font(.custom("DMMono-Regular", size: 11))
                                    .foregroundColor(.white.opacity(0.2))
                                
                                TextField("what do you call this feeling?", text: $moodName)
                                    .font(.custom("DMMono-Regular", size: 11))
                                    .foregroundColor(.white)
                                    .onChange(of: moodName) { newValue in
                                        if newValue.count > 20 {
                                            moodName = String(newValue.prefix(20))
                                        }
                                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.02))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // USE THIS SHAPE BUTTON
                        Button(action: saveAndDismiss) {
                            HStack {
                                Text("use this shape →")
                                    .font(.custom("DMMono-Regular", size: 10.5))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .disabled(moodName.isEmpty || !hasStartedDrawing)
                        .opacity(moodName.isEmpty || !hasStartedDrawing ? 0.5 : 1.0)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func saveAndDismiss() {
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        let image = renderer.image { ctx in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        
        let newCustomMood = CustomMood(
            name: moodName,
            drawing: canvasView.drawing,
            strokeColor: selectedColor,
            thumbnail: image
        )
        
        store.customMoods.append(newCustomMood)
        dismiss()
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var tool: PKInkingTool
    @Binding var hasStartedDrawing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.tool = tool
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if !canvasView.drawing.bounds.isEmpty {
                parent.hasStartedDrawing = true
            }
        }
    }
}
