import SwiftUI

struct CreateMomentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    
    @State private var selectedPreset: Post.MoodType? = .joy
    @State private var selectedCustom: CustomMood? = nil
    @State private var quoteText = ""
    @State private var selectedSong: String? = nil
    @State private var showingSongPicker = false
    @State private var showingDrawSheet = false
    
    let songs = ["稻香", "七里香", "青花瓷", "夜曲", "晴天"]
    
    var isReady: Bool {
        (!quoteText.isEmpty && selectedSong != nil) && (selectedPreset != nil || selectedCustom != nil)
    }
    
    var moodColor: Color {
        if let custom = selectedCustom {
            return custom.strokeColor
        }
        return selectedPreset?.color ?? Color(hex: "F0A840")
    }
    
    var body: some View {
        ZStack {
            Color(hex: "08070C").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                VStack(spacing: 0) {
                    HStack {
                        Button("cancel") { dismiss() }
                            .font(.custom("DMMono-Regular", size: 9.5))
                            .foregroundColor(.white.opacity(0.28))
                        
                        Spacer()
                        
                        Text("a moment")
                            .font(.custom("Lora-Italic", size: 14))
                            .italic()
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Button("publish") {
                            if isReady { dismiss() }
                        }
                        .font(.custom("DMMono-Regular", size: 9.5))
                        .foregroundColor(isReady ? Color(hex: "F0A840").opacity(0.8) : .white.opacity(0.2))
                        .disabled(!isReady)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.04))
                    .frame(height: 1)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // STEP 01
                        VStack(alignment: .leading, spacing: 14) {
                            Text("01 · how does it feel?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(0.2 * 8)
                                .foregroundColor(.white.opacity(0.18))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    // Presets
                                    ForEach(Post.MoodType.allCases.filter { $0 != .custom }, id: \.self) { mood in
                                        MoodSelectionItem(type: mood, isSelected: selectedPreset == mood)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedPreset = mood
                                                    selectedCustom = nil
                                                }
                                            }
                                    }
                                    
                                    // Saved Custom Moods
                                    ForEach(store.customMoods) { custom in
                                        CustomMoodSelectionItem(custom: custom, isSelected: selectedCustom?.id == custom.id)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedCustom = custom
                                                    selectedPreset = nil
                                                }
                                            }
                                    }
                                    
                                    // Add Custom Button
                                    Button(action: { showingDrawSheet = true }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                                    .frame(width: 46, height: 46)
                                                
                                                Image(systemName: "plus")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.25))
                                            }
                                            
                                            Text("custom")
                                                .font(.custom("DMMono-Regular", size: 7))
                                                .foregroundColor(.white.opacity(0.2))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 22)
                        
                        ThinDivider().padding(.vertical, 28)
                        
                        // STEP 02
                        VStack(alignment: .leading, spacing: 14) {
                            Text("02 · say it in one thought")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(0.2 * 8)
                                .foregroundColor(.white.opacity(0.18))
                            
                            ZStack(alignment: .topLeading) {
                                if quoteText.isEmpty {
                                    Text("say it how it was…")
                                        .font(.custom("Lora-Italic", size: 14))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.18))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                }
                                
                                TextEditor(text: $quoteText)
                                    .font(.custom("Lora-Italic", size: 14))
                                    .italic()
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineSpacing(14 * 1.75 - 14)
                                    .padding(16)
                                    .frame(minHeight: 110)
                                    .scrollContentBackground(.hidden)
                                    .background(
                                        ZStack {
                                            Color.white.opacity(0.02)
                                            RadialGradient(colors: [moodColor.opacity(0.06), .clear], center: .center, startRadius: 0, endRadius: 100)
                                        }
                                    )
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(quoteText.isEmpty ? Color.white.opacity(0.06) : moodColor.opacity(0.26), lineWidth: 1)
                                    )
                            }
                            
                            HStack {
                                Spacer()
                                Text("\(quoteText.count) / 200")
                                    .font(.custom("DMMono-Regular", size: 8))
                                    .foregroundColor(.white.opacity(0.15))
                            }
                            .padding(.top, 8)
                        }
                        
                        ThinDivider().padding(.vertical, 28)
                        
                        // STEP 03
                        VStack(alignment: .leading, spacing: 14) {
                            Text("03 · which song?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(0.2 * 8)
                                .foregroundColor(.white.opacity(0.18))
                            
                            Button(action: { showingSongPicker = true }) {
                                HStack {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.25))
                                    
                                    Text(selectedSong ?? "link a song")
                                        .font(.custom("DMMono-Regular", size: 9.5))
                                        .foregroundColor(.white.opacity(selectedSong == nil ? 0.25 : 0.55))
                                    
                                    Spacer()
                                    
                                    Image(systemName: selectedSong == nil ? "chevron.right" : "checkmark")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.40))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.015))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                            .confirmationDialog("Link a song", isPresented: $showingSongPicker) {
                                ForEach(songs, id: \.self) { song in
                                    Button(song) { selectedSong = song }
                                }
                            }
                        }
                        .padding(.bottom, 26)
                        
                        // PUBLISH BUTTON
                        Button(action: { dismiss() }) {
                            Text("share this moment")
                                .font(.custom("DMMono-Regular", size: 10.5))
                                .kerning(0.16 * 10.5)
                                .foregroundColor(isReady ? Color(hex: "070604") : Color(hex: "F0A840").opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(isReady ? Color(hex: "F0A840").opacity(0.9) : Color(hex: "F0A840").opacity(0.15))
                                .cornerRadius(14)
                        }
                        .disabled(!isReady)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showingDrawSheet) {
            DrawMoodSheet()
                .environmentObject(store)
        }
    }
}

struct CustomMoodSelectionItem: View {
    var custom: CustomMood
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(custom.strokeColor.opacity(isSelected ? 0.18 : 0.08))
                    .frame(width: 52, height: 52)
                
                Image(uiImage: custom.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .padding(6)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .overlay(
                Circle().stroke(custom.strokeColor.opacity(isSelected ? 0.8 : 0.4), lineWidth: 1)
                    .frame(width: 52, height: 52)
            )
            
            Text(custom.name.uppercased())
                .font(.custom("DMMono-Regular", size: 7.5))
                .kerning(0.1 * 7.5)
                .foregroundColor(.white.opacity(isSelected ? 0.65 : 0.20))
        }
    }
}
