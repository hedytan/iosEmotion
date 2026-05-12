import SwiftUI
import PhotosUI

struct CreateMomentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    
    @State private var selectedPreset: Post.MoodType? = .joy
    @State private var selectedCustom: CustomMood? = nil
    @State private var quoteText = ""
    @State private var selectedSong: String? = nil
    @State private var attachedImage: UIImage? = nil
    @State private var tintOpacity: Double = 0.25
    
    @State private var showingSongPicker = false
    @State private var showingDrawSheet = false
    @State private var pickerItem: PhotosPickerItem? = nil
    
    let songs = ["稻香", "七里香", "青花瓷", "夜曲", "晴天"]
    
    var isReady: Bool {
        !quoteText.isEmpty && selectedSong != nil && (selectedPreset != nil || selectedCustom != nil)
    }
    
    var moodColor: Color {
        selectedCustom?.strokeColor ?? selectedPreset?.color ?? Color(hex: "F0A840")
    }
    
    var moodName: String {
        selectedCustom?.name ?? selectedPreset?.displayName ?? "Joy"
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
                            if isReady { publishMoment() }
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
                        
                        // STEP 01: HOW DOES IT FEEL?
                        VStack(alignment: .leading, spacing: 14) {
                            Text("01 · how does it feel?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.6)
                                .foregroundColor(.white.opacity(0.18))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(Post.MoodType.allCases.filter { $0 != .custom }, id: \.self) { mood in
                                        MoodSelectionItem(type: mood, isSelected: selectedPreset == mood)
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    selectedPreset = mood
                                                    selectedCustom = nil
                                                }
                                            }
                                    }
                                    
                                    ForEach(store.customMoods) { custom in
                                        CustomMoodSelectionItem(custom: custom, isSelected: selectedCustom?.id == custom.id)
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    selectedCustom = custom
                                                    selectedPreset = nil
                                                }
                                            }
                                    }
                                    
                                    Button(action: { showingDrawSheet = true }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                                    .frame(width: 46, height: 46)
                                                Image(systemName: "plus").font(.system(size: 14)).foregroundColor(.white.opacity(0.25))
                                            }
                                            Text("custom").font(.custom("DMMono-Regular", size: 7)).foregroundColor(.white.opacity(0.2))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 22)
                        
                        ThinDivider().padding(.vertical, 28)
                        
                        // STEP 02: SAY IT IN ONE THOUGHT
                        VStack(alignment: .leading, spacing: 14) {
                            Text("02 · say it in one thought")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.6)
                                .foregroundColor(.white.opacity(0.18))
                            
                            ZStack(alignment: .topLeading) {
                                if quoteText.isEmpty {
                                    Text("say it how it was…")
                                        .font(.custom("Lora-Italic", size: 14))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.18))
                                        .padding(16)
                                }
                                TextEditor(text: $quoteText)
                                    .font(.custom("Lora-Italic", size: 14))
                                    .italic()
                                    .foregroundColor(.white.opacity(0.75))
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
                        }
                        
                        ThinDivider().padding(.vertical, 28)
                        
                        // STEP 03: IMAGE ATTACHMENT
                        VStack(alignment: .leading, spacing: 14) {
                            Text("03 · add a visual fragment")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.6)
                                .foregroundColor(.white.opacity(0.18))
                            
                            if let image = attachedImage {
                                // IMAGE ATTACHED STATE
                                VStack(alignment: .leading, spacing: 12) {
                                    ZStack(alignment: .bottomLeading) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 220)
                                            .clipped()
                                            .cornerRadius(18)
                                            .overlay(moodColor.opacity(tintOpacity)) // ADJUSTABLE TINT
                                        
                                        // Mood Name (Bottom Left)
                                        Text(moodName.uppercased())
                                            .font(.custom("DMMono-Regular", size: 9))
                                            .kerning(2)
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding(16)
                                        
                                        // Mood Shape Watermark (Bottom Right)
                                        HStack {
                                            Spacer()
                                            MoodShapeView(type: selectedPreset ?? .custom, color: .white, customMood: selectedCustom)
                                                .frame(width: 60, height: 60)
                                                .opacity(0.12)
                                                .padding(12)
                                        }
                                    }
                                    
                                    // Controls
                                    HStack(spacing: 16) {
                                        PhotosPicker(selection: $pickerItem, matching: .images) {
                                            Label("change photo", systemImage: "arrow.triangle.2.circlepath")
                                                .font(.custom("DMMono-Regular", size: 8.5))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        
                                        Button(action: {
                                            withAnimation {
                                                tintOpacity = (tintOpacity >= 0.6) ? 0.15 : tintOpacity + 0.15
                                            }
                                        }) {
                                            Label("mood filter", systemImage: "slider.horizontal.3")
                                                .font(.custom("DMMono-Regular", size: 8.5))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: { attachedImage = nil }) {
                                            Image(systemName: "xmark.circle")
                                                .foregroundColor(.white.opacity(0.2))
                                        }
                                    }
                                }
                            } else {
                                // EMPTY STATE
                                PhotosPicker(selection: $pickerItem, matching: .images) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                            .frame(height: 80)
                                            .background(Color.white.opacity(0.01))
                                        
                                        VStack(spacing: 8) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "photo").font(.system(size: 14))
                                                Text("attach a photo").font(.custom("Lora-Italic", size: 12)).italic()
                                            }
                                            .foregroundColor(.white.opacity(0.5))
                                            
                                            Text("camera roll · take photo · files").font(.custom("DMMono-Regular", size: 8)).foregroundColor(.white.opacity(0.15))
                                        }
                                    }
                                }
                                
                                HStack {
                                    Spacer()
                                    Text("mood tints the image automatically").font(.custom("DMMono-Regular", size: 7)).foregroundColor(.white.opacity(0.12))
                                }
                            }
                        }
                        .onChange(of: pickerItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    attachedImage = UIImage(data: data)
                                }
                            }
                        }
                        
                        ThinDivider().padding(.vertical, 28)
                        
                        // STEP 04: WHICH SONG?
                        VStack(alignment: .leading, spacing: 14) {
                            Text("04 · which song?")
                                .font(.custom("DMMono-Regular", size: 8))
                                .kerning(1.6)
                                .foregroundColor(.white.opacity(0.18))
                            
                            Button(action: { showingSongPicker = true }) {
                                HStack {
                                    Image(systemName: "music.note").font(.system(size: 10)).foregroundColor(.white.opacity(0.25))
                                    Text(selectedSong ?? "link a song").font(.custom("DMMono-Regular", size: 9.5)).foregroundColor(.white.opacity(selectedSong == nil ? 0.25 : 0.55))
                                    Spacer()
                                    Image(systemName: selectedSong == nil ? "chevron.right" : "checkmark").font(.system(size: 10)).foregroundColor(.white.opacity(0.40))
                                }
                                .padding(16).background(Color.white.opacity(0.015)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
                            }
                            .confirmationDialog("Link a song", isPresented: $showingSongPicker) {
                                ForEach(songs, id: \.self) { song in
                                    Button(song) { selectedSong = song }
                                }
                            }
                        }
                        .padding(.bottom, 32)
                        
                        Button(action: publishMoment) {
                            Text("share this moment")
                                .font(.custom("DMMono-Regular", size: 10.5))
                                .foregroundColor(isReady ? Color(hex: "070604") : Color(hex: "F0A840").opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(isReady ? Color(hex: "F0A840").opacity(0.9) : Color(hex: "F0A840").opacity(0.15))
                                .cornerRadius(14)
                        }
                        .disabled(!isReady)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showingDrawSheet) { DrawMoodSheet().environmentObject(store) }
    }
    
    private func publishMoment() {
        let newPost = Post(
            artist: "You",
            song: selectedSong ?? "Unknown",
            mood: moodName,
            moodType: selectedPreset ?? .custom,
            customMood: selectedCustom,
            attachedImage: attachedImage,
            quote: quoteText,
            resonanceCount: "0",
            year: "2026",
            daysAgo: 0
        )
        withAnimation { store.posts.insert(newPost, at: 0) }
        dismiss()
    }
}

struct MoodSelectionItem: View {
    var type: Post.MoodType
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            MoodShapeView(type: type, color: type.color)
                .frame(width: 52, height: 52)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .background(
                    MoodShape(type: type)
                        .fill(type.color.opacity(isSelected ? 0.18 : 0.08))
                )
            
            Text(type.displayName.uppercased())
                .font(.custom("DMMono-Regular", size: 7.5))
                .kerning(0.1 * 7.5)
                .foregroundColor(.white.opacity(isSelected ? 0.65 : 0.20))
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

struct ThinDivider: View {
    var body: some View {
        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
    }
}
