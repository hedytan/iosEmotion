import SwiftUI
import PhotosUI

struct CreateMomentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PostStore
    @Binding var selectedTab: Int
    
    @State private var selectedPreset: Post.MoodType? = .joy
    @State private var selectedCustom: CustomMood? = nil
    @State private var quoteText = ""
    @State private var selectedSong: String? = nil
    @State private var attachedImage: UIImage? = nil
    
    @State private var showingSongPicker = false
    @State private var showingDrawSheet = false
    @State private var pickerItem: PhotosPickerItem? = nil
    @FocusState private var isFocused: Bool
    
    let songs = ["Show Me How", "Lauren", "Tailwhip", "Sugar", "Tree Among Shrubs", "Seven", "Humming"]
    var isReady: Bool { !quoteText.isEmpty && selectedSong != nil && (selectedPreset != nil || selectedCustom != nil) }
    
    var moodColor: Color { selectedCustom?.strokeColor ?? selectedPreset?.color ?? Color(hex: "F0A840") }
    var moodName: String { selectedCustom?.name ?? selectedPreset?.displayName ?? "Joy" }
    
    var body: some View {
        ZStack {
            Color(hex: "08070C").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NAVIGATION BAR
                VStack(spacing: 0) {
                    HStack {
                        Button("cancel") { dismiss() }
                            .font(.custom("DMMono-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.4))
                        Spacer()
                        Text("a moment")
                            .font(.custom("Lora-Italic", size: 16))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Button("publish") { if isReady { publishMoment() } }
                            .font(.custom("DMMono-Regular", size: 12))
                            .foregroundColor(isReady ? .white.opacity(0.85) : .white.opacity(0.2))
                            .disabled(!isReady)
                    }
                    .padding(.horizontal, 24).padding(.vertical, 16)
                    Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // STEP 01 — MOOD
                        VStack(alignment: .leading, spacing: 14) {
                            Text("01 · how does it feel?")
                                .font(.custom("DMMono-Regular", size: 12))
                                .kerning(1.8).textCase(.uppercase).foregroundColor(.white.opacity(0.3))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Post.MoodType.allCases.filter { $0 != .custom }, id: \.self) { mood in
                                        MoodSelectionItem(type: mood, isSelected: selectedPreset == mood)
                                            .onTapGesture { withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { selectedPreset = mood; selectedCustom = nil } }
                                    }
                                    ForEach(store.customMoods) { custom in
                                        CustomMoodSelectionItem(custom: custom, isSelected: selectedCustom?.id == custom.id)
                                            .onTapGesture { withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { selectedCustom = custom; selectedPreset = nil } }
                                    }
                                    // DRAW BUTTON
                                    Button(action: { showingDrawSheet = true }) {
                                        VStack(spacing: 8) {
                                            Circle().stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4])).frame(width: 50, height: 50)
                                                .overlay(Image(systemName: "plus").font(.system(size: 18)).foregroundColor(.white.opacity(0.35)))
                                            Text("draw").font(.custom("DMMono-Regular", size: 11)).foregroundColor(.white.opacity(0.3))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 22)
                        
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        
                        // STEP 02 — WRITE
                        VStack(alignment: .leading, spacing: 14) {
                            Text("02 · say it in one thought")
                                .font(.custom("DMMono-Regular", size: 12))
                                .kerning(1.8).textCase(.uppercase).foregroundColor(.white.opacity(0.3))
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                ZStack(alignment: .topLeading) {
                                    if quoteText.isEmpty {
                                        Text("say it how it was…").font(.custom("Lora-Italic", size: 13.5)).foregroundColor(.white.opacity(0.18)).padding(16)
                                    }
                                    TextEditor(text: $quoteText)
                                        .font(.custom("Lora-Italic", size: 13.5))
                                        .foregroundColor(.white.opacity(0.72))
                                        .padding(16)
                                        .frame(minHeight: 100)
                                        .scrollContentBackground(.hidden)
                                        .background(ZStack { Color.white.opacity(0.02); RadialGradient(colors: [moodColor.opacity(0.05), .clear], center: .center, startRadius: 0, endRadius: 100) })
                                        .cornerRadius(14)
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(isFocused ? moodColor.opacity(0.26) : Color.white.opacity(0.06), lineWidth: 1))
                                        .focused($isFocused)
                                        .tint(moodColor)
                                }
                                Text("\(quoteText.count) / 200").font(.custom("DMMono-Regular", size: 7.5)).foregroundColor(.white.opacity(0.12))
                            }
                        }
                        
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        
                        // STEP 03 — IMAGE
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("03 · add an image").font(.custom("DMMono-Regular", size: 7.5)).kerning(1.5).textCase(.uppercase).foregroundColor(.white.opacity(0.18))
                                Text("optional").font(.custom("DMMono-Regular", size: 7.5)).foregroundColor(.white.opacity(0.08))
                            }
                            
                            if let image = attachedImage {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill).frame(maxWidth: .infinity).frame(height: 180).clipped().cornerRadius(12)
                                    Button(action: { attachedImage = nil }) { Image(systemName: "xmark.circle.fill").padding(8).foregroundColor(.white.opacity(0.4)) }
                                }
                            } else {
                                PhotosPicker(selection: $pickerItem, matching: .images) {
                                    HStack(spacing: 14) {
                                        Image(systemName: "photo").font(.system(size: 16)).foregroundColor(.white.opacity(0.22))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("attach a photo").font(.custom("Lora-Italic", size: 12)).foregroundColor(.white.opacity(0.22))
                                            Text("camera roll · take photo").font(.custom("DMMono-Regular", size: 7.5)).foregroundColor(.white.opacity(0.14))
                                        }
                                        Spacer()
                                    }
                                    .padding(16).frame(height: 72).background(Color.white.opacity(0.01)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 4])))
                                }
                            }
                        }
                        .onChange(of: pickerItem) { newItem in Task { if let data = try? await newItem?.loadTransferable(type: Data.self) { attachedImage = UIImage(data: data) } } }
                        
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        
                        // STEP 04 — DRAW MOOD (Optional)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("04 · draw your mood").font(.custom("DMMono-Regular", size: 7.5)).kerning(1.5).textCase(.uppercase).foregroundColor(.white.opacity(0.18))
                                Text("optional").font(.custom("DMMono-Regular", size: 7.5)).foregroundColor(.white.opacity(0.08))
                            }
                            if store.customMoods.isEmpty {
                                Text("tap draw in step 01 to add your mood shape").font(.custom("DMMono-Regular", size: 8)).foregroundColor(.white.opacity(0.14))
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(store.customMoods) { custom in
                                            Image(uiImage: custom.thumbnail).resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
                        
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
        let newPost = Post(artist: "Hedy (me)", moodType: selectedPreset ?? .custom, quote: quoteText, song: selectedSong ?? "Unknown", year: "2026", resonanceCount: 0)
        withAnimation { store.addPost(newPost) }
        selectedTab = 0; dismiss()
    }
}

// Sub-components for CreateMomentView
struct MoodSelectionItem: View {
    var type: Post.MoodType
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 8) {
            MoodShapeView(type: type, color: type.color).frame(width: 50, height: 50)
                .scaleEffect(isSelected ? 1.12 : 1.0)
                .background(MoodShape(type: type).fill(type.color.opacity(isSelected ? 0.18 : 0)))
            Text(type.displayName.uppercased()).font(.custom("DMMono-Regular", size: 7)).foregroundColor(.white.opacity(isSelected ? 0.65 : 0.20))
        }
    }
}

struct CustomMoodSelectionItem: View {
    var custom: CustomMood
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: custom.thumbnail).resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                .scaleEffect(isSelected ? 1.12 : 1.0)
            Text(custom.name.uppercased()).font(.custom("DMMono-Regular", size: 7)).foregroundColor(.white.opacity(isSelected ? 0.65 : 0.20))
        }
    }
}
