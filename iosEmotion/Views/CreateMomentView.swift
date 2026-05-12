import SwiftUI

struct CreateMomentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMood: Post.MoodType = .joy
    @State private var quoteText = "I wrote the first verse in my mother's kitchen at 2am. The smell of her cooking — that was the whole song."
    @State private var songSelected = true
    
    let moods: [(Post.MoodType, String, Color)] = [
        (.joy, "Joy", Color(hex: "f0a840")),
        (.melancholy, "Melancholy", Color(hex: "6888b8")),
        (.wonder, "Wonder", Color(hex: "40b8c8")),
        (.tender, "Tender", Color(hex: "d890b8")),
        (.urgency, "Urgency", Color(hex: "e05040")),
        (.awe, "Awe", Color(hex: "7090d0"))
    ]
    
    var moodColor: Color {
        moods.first(where: { $0.0 == selectedMood })?.2 ?? .white
    }
    
    var body: some View {
        ZStack {
            Color(hex: "08070b").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation
                HStack {
                    Button("cancel") { dismiss() }
                        .font(.custom("DMMono-Regular", size: 9))
                        .foregroundColor(.white.opacity(0.25))
                    
                    Spacer()
                    
                    Text("a moment")
                        .font(.custom("Lora-Italic", size: 13))
                        .italic()
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Button("share") { }
                        .font(.custom("DMMono-Regular", size: 9))
                        .foregroundColor(.white.opacity(0.20))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // STEP 01
                        VStack(alignment: .leading, spacing: 20) {
                            Text("01 · How does it feel?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.5)
                                .foregroundColor(.white.opacity(0.18))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 24) {
                                    ForEach(moods, id: \.1) { mood in
                                        MoodSelectionItem(type: mood.0, name: mood.1, color: mood.2, isSelected: selectedMood == mood.0)
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    selectedMood = mood.0
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.05))
                        
                        // STEP 02
                        VStack(alignment: .leading, spacing: 20) {
                            Text("02 · Say it in one thought")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.5)
                                .foregroundColor(.white.opacity(0.18))
                            
                            ZStack(alignment: .bottomTrailing) {
                                TextEditor(text: $quoteText)
                                    .font(.custom("Lora-Italic", size: 13))
                                    .italic()
                                    .foregroundColor(.white.opacity(0.72))
                                    .padding(16)
                                    .frame(minHeight: 140)
                                    .scrollContentBackground(.hidden)
                                    .background(
                                        ZStack {
                                            Color(hex: "08070b")
                                            RadialGradient(colors: [moodColor.opacity(0.05), .clear], center: .center, startRadius: 0, endRadius: 100)
                                        }
                                    )
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )
                                
                                Text("\(quoteText.count) / 200")
                                    .font(.custom("DMMono-Regular", size: 8))
                                    .foregroundColor(.white.opacity(0.15))
                                    .padding(12)
                            }
                        }
                        
                        // STEP 03
                        VStack(alignment: .leading, spacing: 20) {
                            Text("03 · Which song?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.5)
                                .foregroundColor(.white.opacity(0.18))
                            
                            HStack {
                                Image(systemName: "music.note")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                
                                Text("稻香")
                                    .font(.custom("DMMono-Regular", size: 9))
                                    .foregroundColor(.white.opacity(0.55))
                                
                                Spacer()
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.015))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                        }
                        
                        Spacer(minLength: 40)
                        
                        // SHARE BUTTON
                        Button(action: { dismiss() }) {
                            Text("Share this moment")
                                .font(.custom("DMMono-Regular", size: 10))
                                .kerning(1.5)
                                .foregroundColor(Color(hex: "080706"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(moodColor.opacity(0.9))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct MoodSelectionItem: View {
    var type: Post.MoodType
    var name: String
    var color: Color
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                if isSelected {
                    MoodShape(type: type)
                        .fill(RadialGradient(colors: [color.opacity(0.16), .clear], center: .center, startRadius: 0, endRadius: 24))
                }
                
                MoodShape(type: type)
                    .stroke(color.opacity(isSelected ? 0.8 : 0.4), lineWidth: 1)
                    .fill(color.opacity(isSelected ? 0.16 : 0.07))
            }
            .frame(width: 48, height: 48)
            .scaleEffect(isSelected ? 1.12 : 1.0)
            
            Text(name)
                .font(.custom("DMMono-Regular", size: 8))
                .foregroundColor(.white.opacity(isSelected ? 0.65 : 0.2))
        }
    }
}
