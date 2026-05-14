import Foundation
import AVFoundation
import Combine
import MusicKit

@MainActor
class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published var isPlaying = false
    @Published var currentSong: String?
    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined

    private init() {}

    // MARK: - Authorization
    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
    }

    // MARK: - Play song by name + artist
    func playSong(song: String, artist: String) {
        Task {
            // Request authorization first
            if authorizationStatus == .notDetermined {
                await requestAuthorization()
            }

            guard authorizationStatus == .authorized else {
                print("MusicKit: Not authorized")
                return
            }

            do {
                // Search Apple Music for the exact song
                var request = MusicCatalogSearchRequest(term: "\(song) \(artist)", types: [Song.self])
                request.limit = 1
                let response = try await request.response()

                guard let foundSong = response.songs.first else {
                    print("MusicKit: Song '\(song)' by \(artist) not found")
                    return
                }

                // Play the song via SystemMusicPlayer
                ApplicationMusicPlayer.shared.queue = [foundSong]
                try await ApplicationMusicPlayer.shared.play()

                currentSong = foundSong.title
                isPlaying = true
                print("MusicKit: Now playing \(foundSong.title) by \(foundSong.artistName)")

            } catch {
                print("MusicKit error: \(error)")
            }
        }
    }

    // MARK: - Stop
    func stop() {
        ApplicationMusicPlayer.shared.stop()
        isPlaying = false
        currentSong = nil
    }
}
