//
//  BoardView.swift
//  iosEmotion
//
//  Created by Hedy on 3/5/2026.
//

import SwiftUI

struct BoardView: View {
    let boards = [
        BoardItem(title: "Midnight Echoes", tag: "MOOD · NOIR", color: Color(red: 0.1, green: 0.15, blue: 0.2)),
        BoardItem(title: "Velvet Distortion", tag: "TEXTURE · WARM", color: Color(red: 0.4, green: 0.15, blue: 0.1)),
        BoardItem(title: "Dune Rhythm", tag: "BEAT · EARTH", color: Color(red: 0.45, green: 0.3, blue: 0.1)),
        BoardItem(title: "Static Pulse", tag: "ENERGY · DARK", color: Color(red: 0.05, green: 0.05, blue: 0.2))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(boards) { board in
                        NavigationLink(destination: BoardDetailView(board: board)) {
                            BoardRowView(board: board)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SAVED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AppPurple"))
                        Text("Board.")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(Color("AppPurple"))
                    }
                }
            }
        }
    }
}

struct BoardItem: Identifiable {
    let id = UUID()
    var title: String
    var tag: String
    var color: Color
}

struct BoardRowView: View {
    var board: BoardItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(board.color)
                .frame(height: 100)
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 2) {
                Text(board.tag)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.7))
                Text(board.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(16)
        }
    }
}

struct BoardDetailView: View {
    var board: BoardItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Cover photo
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .frame(height: 280)
                        .cornerRadius(16)

                    // Camera info
                    Text("35MM / ISO 400")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                // Audio player card
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color("AppPurple"))
                                .clipShape(Circle())
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Demo_001.mp3")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            Text("0:45 · Lo-fi Loop")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }

                    // Waveform dots
                    HStack(spacing: 6) {
                        ForEach(0..<12) { i in
                            Circle()
                                .fill(i < 4 ? Color("AppPurple") : Color.gray.opacity(0.4))
                                .frame(width: i % 3 == 0 ? 14 : 10,
                                       height: i % 3 == 0 ? 14 : 10)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color("CardBackground"))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle(board.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("SAVED")
                        .font(.caption2)
                        .foregroundColor(Color("AppPurple"))
                    Text("Board.")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("AppPurple"))
                }
            }
        }
    }
}

#Preview {
    BoardView()
}
