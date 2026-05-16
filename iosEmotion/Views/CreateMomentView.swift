import SwiftUI
import PhotosUI

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
    let songs = ["Show Me How", "Lauren", "Tailwhip", "Seven", "Numb"]
    
    var isReady: Bool {
        !quoteText.isEmpty && (selectedPreset != nil || selectedCustomMood != nil) && selectedSong != nil
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "07060A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NAVIGATION BAR
                VStack(spacing: 16) {
                    HStack {
                        Button("cancel") { dismiss() }
                            .font(.custom("DMMono-Regular", size: 13))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        Text("a moment")
                            .font(.custom("Lora-Italic", size: 18))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Spacer()
                        
                        Button("publish") { if isReady { publishMoment() } }
                            .font(.custom("DMMono-Regular", size: 13))
                            .foregroundColor(isReady ? .white.opacity(0.75) : .white.opacity(0.18))
                            .disabled(!isReady)
                    }
                    .padding(.horizontal, 24)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 0.5)
                }
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) { // Tightened from 44
                        
                        // 01 — HOW DOES IT FEEL?
                        VStack(alignment: .leading, spacing: 20) { // Tightened from 24
                            Text("01 · HOW DOES IT FEEL?")
                                .font(.custom("DMMono-Regular", size: 11))
                                .kerning(1.5)
                                .foregroundColor(.white.opacity(0.45))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 28) {
                                    ForEach(presets, id: \.self) { mood in
                                        Button(action: { 
                                            selectedPreset = mood
                                            selectedCustomMood = nil 
                                        }) {
                                            MoodSelectionItem(type: mood, isSelected: selectedPreset == mood)
                                        }
                                    }
                                    
                                    ForEach(store.customMoods) { custom in
                                        Button(action: {
                                            selectedCustomMood = custom
                                            selectedPreset = nil
                                        }) {
                                            CustomMoodSelectionItem(custom: custom, isSelected: selectedCustomMood == custom)
                                        }
                                    }
                                    
                                    Button(action: { showingDrawSheet = true }) {
                                        VStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .stroke(Color.white.opacity(0.15), lineWidth: 1.1)
                                                    .frame(width: 52, height: 52)
                                                Image(systemName: "plus")
                                                    .font(.system(size: 14, weight: .light))
                                                    .foregroundColor(.white.opacity(0.35))
                                            }
                                            Text("CREATE").font(.custom("DMMono-Regular", size: 9)).foregroundColor(.white.opacity(0.2))
                                        }
                                    }
                                }
                                .padding(.leading, 4)
                                .padding(.trailing, 24)
                            }
                        }
                        .padding(.top, 24) // Tightened from 32
                        
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5)
                        
                        // 02 — SAY IT IN ONE THOUGHT
                        VStack(alignment: .leading, spacing: 18) {
                            Text("02 · SAY IT IN ONE THOUGHT")
                                .font(.custom("DMMono-Regular", size: 11))
                                .kerning(1.5)
                                .foregroundColor(.white.opacity(0.45))
                            
                            ZStack(alignment: .topLeading) {
                                if quoteText.isEmpty {
                                    Text("say it how it was...")
                                        .font(.custom("Lora-Italic", size: 16))
                                        .foregroundColor(.white.opacity(0.35))
                                        .padding(.top, 24).padding(.leading, 24)
                                }
                                TextEditor(text: $quoteText)
                                    .font(.custom("Lora-Italic", size: 16))
                                    .foregroundColor(.white.opacity(0.85))
                                    .scrollContentBackground(.hidden)
                                    .background(Color.white.opacity(0.02))
                                    .cornerRadius(20)
                                    .padding(8)
                            }
                            .frame(height: 160)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            
                            HStack {
                                Spacer()
                                Text("\(quoteText.count) / 200")
                                    .font(.custom("DMMono-Regular", size: 10))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5)
                        
                        // 03 — ADD AN IMAGE
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Text("03 · ADD AN IMAGE")
                                    .font(.custom("DMMono-Regular", size: 11))
                                    .kerning(1.5)
                                    .foregroundColor(.white.opacity(0.45))
                                Text("OPTIONAL")
                                    .font(.custom("DMMono-Regular", size: 9))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            
                            PhotosPicker(selection: $pickerItem, matching: .images) {
                                ZStack {
                                    if let img = attachedImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                                    } else {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                            .frame(height: 100)
                                        
                                        HStack(spacing: 12) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white.opacity(0.4))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("attach a photo")
                                                    .font(.custom("Lora-Italic", size: 15))
                                                    .foregroundColor(.white.opacity(0.45))
                                                Text("camera roll · take photo")
                                                    .font(.custom("DMMono-Regular", size: 10))
                                                    .foregroundColor(.white.opacity(0.3))
                                            }
                                        }
                                    }
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
                        
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5)
                        
                        // 04 — THE SOUNDTRACK
                        VStack(alignment: .leading, spacing: 18) {
                            Text("04 · THE SOUNDTRACK")
                                .font(.custom("DMMono-Regular", size: 11))
                                .kerning(1.5)
                                .foregroundColor(.white.opacity(0.45))
                            
                            Button(action: { showingSongPicker = true }) {
                                HStack {
                                    Image(systemName: "music.note").font(.system(size: 11)).foregroundColor(.white.opacity(0.4))
                                    Text(selectedSong ?? "link a song").font(.custom("Lora-Italic", size: 16)).foregroundColor(.white.opacity(selectedSong == nil ? 0.35 : 0.75))
                                    Spacer()
                                    Image(systemName: selectedSong == nil ? "chevron.right" : "checkmark").font(.system(size: 11)).foregroundColor(.white.opacity(0.4))
                                }
                                .padding(.vertical, 14).padding(.horizontal, 18)
                                .background(Color.white.opacity(0.02))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            }
                            .confirmationDialog("Link a song", isPresented: $showingSongPicker) {
                                ForEach(songs, id: \.self) { song in
                                    Button(song) { selectedSong = song }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .fullScreenCover(isPresented: $showingDrawSheet) {
            DrawMoodView().environmentObject(store)
        }
    }
    
    private func publishMoment() {
        var moodType = selectedPreset ?? .custom
        var newPost = Post(
            artist: "Men I Trust (Me)", 
            moodType: moodType, 
            quote: quoteText, 
            song: selectedSong ?? "Show Me How", 
            year: "2026", 
            resonanceCount: 0
        )
        
        if let custom = selectedCustomMood {
            newPost.customShape = custom.drawing
            newPost.customShapeName = custom.name
            newPost.customColor = custom.strokeColor
        }
        
        if let img = attachedImage { newPost.attachedImage = img }
        
        newPost.resonanceOptions = [
            ResonanceOption(text: "felt this in my chest", mood: moodType, count: 0, isCustom: false),
            ResonanceOption(text: "took me somewhere else", mood: moodType, count: 0, isCustom: false)
        ]
        
        withAnimation { store.addPost(newPost) }
        selectedTab = 0
        dismiss()
    }
}

struct MoodSelectionItem: View {
    var type: Post.MoodType
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                MoodShape(type: type)
                    .fill(
                        RadialGradient(
                            colors: [type.color.opacity(isSelected ? 0.5 : 0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 28
                        )
                    )
                
                MoodShape(type: type)
                    .stroke(type.color.opacity(isSelected ? 0.85 : 0.35), lineWidth: 1.1)
            }
            .frame(width: 52, height: 52)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            
            Text(type.displayName.uppercased())
                .font(.custom("DMMono-Regular", size: 9))
                .kerning(1.2)
                .foregroundColor(.white.opacity(isSelected ? 0.75 : 0.35))
        }
    }
}

struct CustomMoodSelectionItem: View {
    var custom: CustomMood
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [custom.strokeColor.opacity(isSelected ? 0.5 : 0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 28
                        )
                    )
                
                Image(uiImage: custom.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 52, height: 52)
            }
            .frame(width: 52, height: 52)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            
            Text(custom.name.uppercased())
                .font(.custom("DMMono-Regular", size: 9))
                .kerning(1.2)
                .foregroundColor(.white.opacity(isSelected ? 0.75 : 0.35))
        }
    }
}
