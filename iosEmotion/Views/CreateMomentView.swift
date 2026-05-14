import SwiftUI

struct CreateMomentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    @Binding var selectedTab: Int
    
    @State private var quoteText = ""
    @State private var selectedPreset: Post.MoodType? = nil
    @State private var selectedCustomMood: CustomMood? = nil
    @State private var selectedSong: String? = nil
    @State private var attachedImage: UIImage? = nil
    @State private var showingDrawSheet = false
    @State private var showingSongPicker = false
    @State private var pickerItem: PhotosPickerItem? = nil
    
    let presets = Post.MoodType.allCases.filter { $0 != .custom }
    let songs = ["Midnight City", "Starboy", "Nightcall", "Ocean Drive", "After Hours"]
    
    var isReady: Bool {
        !quoteText.isEmpty && (selectedPreset != nil || selectedCustomMood != nil) && selectedSong != nil
    }
    
    var body: some View {
        ZStack {
            Color(hex: "07060A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NAVIGATION
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark").font(.system(size: 14)).foregroundColor(.white.opacity(0.3))
                    }
                    Spacer()
                    Text("create a moment").font(.custom("Lora-Italic", size: 16)).foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Color.clear.frame(width: 14)
                }
                .padding(.horizontal, 24).padding(.vertical, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // STEP 01 — THE MOOD
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("01 · choose a mood").font(.custom("DMMono-Regular", size: 7.5)).kerning(1.5).textCase(.uppercase).foregroundColor(.white.opacity(0.18))
                                Spacer()
                                Button(action: { showingDrawSheet = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "pencil.and.outline").font(.system(size: 9))
                                        Text("draw your own").font(.custom("DMMono-Regular", size: 8))
                                    }
                                    .padding(.horizontal, 10).padding(.vertical, 5).background(Color.white.opacity(0.04)).cornerRadius(6)
                                    .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(presets, id: \.self) { mood in
                                        Button(action: { 
                                            selectedPreset = mood
                                            selectedCustomMood = nil 
                                        }) {
                                            MoodSelectionItem(type: mood, isSelected: selectedPreset == mood)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        
                        // STEP 02 — THE WORDS
                        VStack(alignment: .leading, spacing: 14) {
                            Text("02 · the words").font(.custom("DMMono-Regular", size: 7.5)).kerning(1.5).textCase(.uppercase).foregroundColor(.white.opacity(0.18))
                            ZStack(alignment: .topLeading) {
                                if quoteText.isEmpty {
                                    Text("what did you feel in that moment?").font(.custom("Lora-Italic", size: 13.5)).foregroundColor(.white.opacity(0.1)).padding(.top, 12).padding(.leading, 12)
                                }
                                TextEditor(text: $quoteText).font(.custom("Lora-Italic", size: 13.5)).foregroundColor(.white.opacity(0.7)).scrollContentBackground(.hidden).background(Color.white.opacity(0.015)).cornerRadius(12).padding(4)
                            }
                            .frame(height: 120).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        }
                        
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        
                        // STEP 03 — IMAGE (Optional)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("03 · attach vision").font(.custom("DMMono-Regular", size: 7.5)).kerning(1.5).textCase(.uppercase).foregroundColor(.white.opacity(0.18))
                                Text("optional").font(.custom("DMMono-Regular", size: 7.5)).foregroundColor(.white.opacity(0.08))
                            }
                            PhotosPicker(selection: $pickerItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle").font(.system(size: 10)).foregroundColor(.white.opacity(0.25))
                                    Text(attachedImage == nil ? "upload a photo" : "photo attached").font(.custom("DMMono-Regular", size: 9.5)).foregroundColor(.white.opacity(attachedImage == nil ? 0.25 : 0.55))
                                    Spacer(); if attachedImage != nil { Image(systemName: "checkmark").font(.system(size: 10)).foregroundColor(.white.opacity(0.4)) }
                                }
                                .padding(.vertical, 11).padding(.horizontal, 14).background(Color.white.opacity(0.012)).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.05), lineWidth: 1))
                            }
                        }
                        .onChange(of: pickerItem) { newItem in Task { if let data = try? await newItem?.loadTransferable(type: Data.self) { attachedImage = UIImage(data: data) } } }
                        
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        
                        // STEP 04 — YOUR DRAWINGS
                        if !store.customMoods.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("04 · your custom moods").font(.custom("DMMono-Regular", size: 7.5)).kerning(1.5).textCase(.uppercase).foregroundColor(.white.opacity(0.18))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(store.customMoods) { custom in
                                            Button(action: {
                                                selectedCustomMood = custom
                                                selectedPreset = nil
                                            }) {
                                                CustomMoodSelectionItem(custom: custom, isSelected: selectedCustomMood == custom)
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        }
                        
                        // STEP 05 — SONG
                        VStack(alignment: .leading, spacing: 14) {
                            Text("05 · which song?").font(.custom("DMMono-Regular", size: 7.5)).kerning(1.5).textCase(.uppercase).foregroundColor(.white.opacity(0.18))
                            Button(action: { showingSongPicker = true }) {
                                HStack {
                                    Image(systemName: "music.note").font(.system(size: 10)).foregroundColor(.white.opacity(0.25))
                                    Text(selectedSong ?? "link a song").font(.custom("DMMono-Regular", size: 9.5)).foregroundColor(.white.opacity(selectedSong == nil ? 0.25 : 0.55))
                                    Spacer(); Image(systemName: selectedSong == nil ? "chevron.right" : "checkmark").font(.system(size: 10)).foregroundColor(.white.opacity(0.40))
                                }
                                .padding(.vertical, 11).padding(.horizontal, 14).background(Color.white.opacity(0.012)).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.05), lineWidth: 1))
                            }
                            .confirmationDialog("Link a song", isPresented: $showingSongPicker) { ForEach(songs, id: \.self) { song in Button(song) { selectedSong = song } } }
                        }
                        .padding(.bottom, 32)
                        
                        // PUBLISH BUTTON
                        Button(action: publishMoment) {
                            Text("share this moment").font(.custom("DMMono-Regular", size: 10.5)).kerning(1.6).foregroundColor(isReady ? Color(hex: "070604") : Color(hex: "F0A840").opacity(0.3)).frame(maxWidth: .infinity).padding(.vertical, 14).background(isReady ? Color(hex: "F0A840").opacity(0.88) : Color(hex: "F0A840").opacity(0.15)).cornerRadius(13)
                        }
                        .disabled(!isReady)
                    }
                    .padding(.horizontal, 22).padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showingDrawSheet) { DrawMoodView().environmentObject(store) }
    }
    
    private func publishMoment() {
        var moodType = selectedPreset ?? .custom
        var newPost = Post(
            artist: "Hedy (me)", 
            moodType: moodType, 
            quote: quoteText, 
            song: selectedSong ?? "Unknown", 
            year: "2026", 
            resonanceCount: 0
        )
        
        // Attach custom drawing if selected
        if let custom = selectedCustomMood {
            newPost.customShape = custom.drawing
            newPost.customShapeName = custom.name
        }
        
        if let img = attachedImage { newPost.attachedImage = img }
        
        // Add basic resonance options
        newPost.resonanceOptions = [
            ResonanceOption(text: "felt this in my chest", mood: moodType, count: 0, isCustom: false),
            ResonanceOption(text: "took me somewhere else", mood: moodType, count: 0, isCustom: false)
        ]
        
        withAnimation { store.addPost(newPost) }
        selectedTab = 0; dismiss()
    }
}

struct MoodSelectionItem: View {
    var type: Post.MoodType
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 8) {
            MoodShape(type: type)
                .fill(type.color.opacity(isSelected ? 0.3 : 0.05))
                .overlay(MoodShape(type: type).stroke(type.color.opacity(isSelected ? 0.8 : 0.2), lineWidth: 1.2))
                .frame(width: 50, height: 50)
                .scaleEffect(isSelected ? 1.12 : 1.0)
            Text(type.displayName.uppercased()).font(.custom("DMMono-Regular", size: 7)).foregroundColor(.white.opacity(isSelected ? 0.65 : 0.20))
        }
    }
}

struct CustomMoodSelectionItem: View {
    var custom: CustomMood
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: custom.thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding(8)
                .background(Circle().fill(custom.strokeColor.opacity(isSelected ? 0.2 : 0.05)))
                .overlay(Circle().stroke(custom.strokeColor.opacity(isSelected ? 0.8 : 0.2), lineWidth: 1.2))
                .scaleEffect(isSelected ? 1.12 : 1.0)
            
            Text(custom.name.uppercased()).font(.custom("DMMono-Regular", size: 7)).foregroundColor(.white.opacity(isSelected ? 0.65 : 0.20))
        }
    }
}
