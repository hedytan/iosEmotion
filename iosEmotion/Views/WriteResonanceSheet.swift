import SwiftUI

struct WriteResonanceSheet: View {
    @Environment(\.dismiss) var dismiss
    var post: Post
    var onConfirm: (String, Post.MoodType) -> Void
    
    @State private var text = ""
    @State private var selectedMood: Post.MoodType = .joy
    @FocusState private var isFocused: Bool
    
    let moods: [Post.MoodType] = [.joy, .melancholy, .wonder, .tender, .urgency, .awe]
    var isReady: Bool { text.count >= 5 }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.white.opacity(0.14))
                .frame(width: 34, height: 3)
                .padding(.top, 10)
            
            // Header
            VStack(spacing: 4) {
                Text("your resonance")
                    .font(.custom("Lora-Italic", size: 14))
                    .foregroundColor(.white.opacity(0.55))
                
                Text("how does \(post.artist)'s moment feel to you?")
                    .font(.custom("DMMono-Regular", size: 7.5))
                    .kerning(0.9)
                    .textCase(.uppercase)
                    .foregroundColor(.white.opacity(0.18))
            }
            .padding(.top, 18).padding(.bottom, 22)
            
            // MOOD SELECTOR
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(moods, id: \.self) { mood in
                        Button(action: { selectedMood = mood }) {
                            VStack(spacing: 8) {
                                MoodShapeView(type: mood, color: mood.color)
                                    .frame(width: 30, height: 30)
                                
                                Text(mood.displayName.uppercased())
                                    .font(.custom("DMMono-Regular", size: 6.5))
                                    .foregroundColor(selectedMood == mood ? mood.color.opacity(0.7) : .white.opacity(0.2))
                            }
                            .padding(.vertical, 6).padding(.horizontal, 8)
                            .frame(width: 64)
                            .background(selectedMood == mood ? Color.white.opacity(0.03) : Color.clear)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedMood == mood ? Color.white.opacity(0.16) : Color.white.opacity(0.05), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
            .padding(.bottom, 24)
            
            // TEXT EDITOR
            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("say it in your own words…")
                            .font(.custom("Lora-Italic", size: 13.5))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(12)
                    }
                    TextEditor(text: $text)
                        .font(.custom("Lora-Italic", size: 13.5))
                        .foregroundColor(.white.opacity(0.75))
                        .scrollContentBackground(.hidden)
                        .background(Color.white.opacity(0.02))
                        .padding(12)
                        .focused($isFocused)
                        .tint(selectedMood.color)
                }
                .frame(height: 120)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isFocused ? selectedMood.color.opacity(0.26) : Color.white.opacity(0.08), lineWidth: 1))
                
                Text("\(text.count) / 120")
                    .font(.custom("DMMono-Regular", size: 7.5))
                    .foregroundColor(.white.opacity(0.14))
            }
            .padding(.horizontal, 14).padding(.bottom, 24)
            
            // CONFIRM BUTTON
            Button(action: {
                if isReady {
                    onConfirm(text, selectedMood)
                    dismiss()
                }
            }) {
                Text("feel the connection →")
                    .font(.custom("DMMono-Regular", size: 10))
                    .kerning(1.4)
                    .textCase(.uppercase)
                    .foregroundColor(isReady ? .white.opacity(0.65) : .white.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(isReady ? Color.white.opacity(0.07) : Color.white.opacity(0.02))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(isReady ? Color.white.opacity(0.18) : Color.white.opacity(0.06), lineWidth: 1))
            }
            .disabled(!isReady)
            .padding(.horizontal, 14).padding(.bottom, 34)
            
            Spacer()
        }
        .background(Color(hex: "111014").ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
