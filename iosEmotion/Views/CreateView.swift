//
//  CreateView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI
import PhotosUI

struct CreateView: View {
    @EnvironmentObject var store: PostStore
    @State private var postText: String = ""
    @State private var selectedMood: String = "NEW FRAGMENT"
    @State private var showMoodPicker = false
    
    // Photo selection
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // Audio selection
    @State private var showAudioImporter = false
    @State private var selectedAudioURL: URL?
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Tag
                    Button(action: { showMoodPicker = true }) {
                        Text(selectedMood.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AppPurple"))
                    }

                    // Title
                    Text("Create.")
                        .font(.system(size: 36, weight: .heavy))
                        .italic()
                        .foregroundColor(Color("AppPurple"))

                    // Subtitle
                    Text("The Soul of this Moment")
                        .font(.subheadline)
                        .foregroundColor(Color("AppPurple").opacity(0.7))

                    // Text input
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(minHeight: 120)

                        if postText.isEmpty {
                            Text("What were you feeling when you made this?")
                                .foregroundColor(.secondary)
                                .padding(16)
                        }

                        TextEditor(text: $postText)
                            .foregroundColor(.primary)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(12)
                            .frame(minHeight: 120)
                    }

                    // Add Audio
                    Button(action: { showAudioImporter = true }) {
                        HStack {
                            Image(systemName: selectedAudioURL == nil ? "waveform" : "checkmark.circle.fill")
                                .foregroundColor(Color("AppPurple"))
                            Text(selectedAudioURL == nil ? "Add Audio" : "Audio Added")
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Add Photo + Mood Tag
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            VStack(alignment: .leading, spacing: 4) {
                                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 80)
                                        .cornerRadius(8)
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundColor(Color("AppPurple"))
                                    Text("Add Photo")
                                        .foregroundColor(.primary)
                                        .fontWeight(.medium)
                                }
                                
                                Text("Visual Muse")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }

                        Button(action: { showMoodPicker = true }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(Color("AppPurple"))
                                Text("Mood Tag")
                                    .foregroundColor(.primary)
                                    .fontWeight(.medium)
                                Text(selectedMood)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }

                    // Post button
                    Button(action: {
                        if !postText.isEmpty {
                            store.addPost(tag: selectedMood.uppercased(), 
                                          title: "New Creation", 
                                          description: postText,
                                          imageData: selectedImageData)
                            postText = ""
                            selectedImageData = nil
                            selectedAudioURL = nil
                        }
                    }) {
                        Text("Post")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(postText.isEmpty ? Color.gray : Color("AppPurple"))
                            .cornerRadius(30)
                    }
                    .disabled(postText.isEmpty)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showMoodPicker) {
                MoodPickerView(selectedMood: $selectedMood)
            }
            .fileImporter(isPresented: $showAudioImporter, allowedContentTypes: [.audio]) { result in
                switch result {
                case .success(let url):
                    selectedAudioURL = url
                case .failure(let error):
                    print("Error selecting audio: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MoodPickerView: View {
    @Binding var selectedMood: String
    @Environment(\.dismiss) var dismiss

    let moods = [
        ("Melancholic", "moon.fill"),
        ("Euphoric", "sun.max.fill"),
        ("Raw", "bolt.fill"),
        ("Nostalgic", "clock.fill"),
        ("Restless", "wind"),
        ("Tender", "heart.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose a Mood")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(moods, id: \.0) { mood in
                    Button(action: {
                        selectedMood = mood.0
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: mood.1)
                                .foregroundColor(Color("AppPurple"))
                            Text(mood.0)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                        .background(
                            selectedMood == mood.0 ?
                            Color("AppPurple").opacity(0.1) : Color.gray.opacity(0.1)
                        )
                        .cornerRadius(12)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    CreateView()
        .environmentObject(PostStore())
}

#Preview {
    CreateView()
        .environmentObject(PostStore())
}
