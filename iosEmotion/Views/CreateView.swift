//
//  CreateView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct CreateView: View {
    @State private var postText: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Tag
                    Text("NEW FRAGMENT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AppPurple"))

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
                            .fill(Color("CardBackground"))
                            .frame(minHeight: 120)

                        if postText.isEmpty {
                            Text("What were you feeling when you made this?")
                                .foregroundColor(.gray)
                                .padding(16)
                        }

                        TextEditor(text: $postText)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(12)
                            .frame(minHeight: 120)
                    }

                    // Add Audio
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundColor(Color("AppPurple"))
                            Text("Add Audio")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("CardBackground"))
                        .cornerRadius(12)
                    }

                    // Add Photo + Mood Tag
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            VStack(alignment: .leading, spacing: 4) {
                                Image(systemName: "photo")
                                    .foregroundColor(Color("AppPurple"))
                                Text("Add Photo")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Text("Visual Muse")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color("CardBackground"))
                            .cornerRadius(12)
                        }

                        Button(action: {}) {
                            VStack(alignment: .leading, spacing: 4) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(Color("AppPurple"))
                                Text("Mood Tag")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Text("Sonic Texture")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color("CardBackground"))
                            .cornerRadius(12)
                        }
                    }

                    // Post button
                    Button(action: {}) {
                        Text("Post")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AppPurple"))
                            .cornerRadius(30)
                    }
                }
                .padding()
            }
            .background(Color("AppBackground"))
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
                .foregroundColor(.white)
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
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(
                            selectedMood == mood.0 ?
                            Color("AppPurple").opacity(0.3) : Color("CardBackground")
                        )
                        .cornerRadius(12)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color("AppBackground"))
    }
}

#Preview {
    CreateView()
}

#Preview {
    CreateView()
}
