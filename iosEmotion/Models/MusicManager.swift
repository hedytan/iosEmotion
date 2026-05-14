import Foundation
import AVFoundation
import Combine
import MusicKit

@MainActor
class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published var isPlaying = false
    @Published var currentSong: String?

    private init() {}

    // MARK: - Play song by name + artist
    func playSong(song: String, artist: String) {
        Task {
            // Always re-check authorization status live
            let status = await MusicAuthorization.request()
            print("MusicKit auth status: \(status)")

            guard status == .authorized else {
                print("MusicKit: Authorization denied — user needs Apple Music")
                return
            }

            do {
                // Search Apple Music catalog
                var request = MusicCatalogSearchRequest(
                    term: "\(song) \(artist)",
                    types: [Song.self]
                )
                request.limit = 5
                let response = try await request.response()

                print("MusicKit: Found \(response.songs.count) results for '\(song) \(artist)'")

                // Pick the closest match (prefer exact song name match)
                let bestMatch = response.songs.first(where: {
                    $0.title.localizedCaseInsensitiveContains(song)
                }) ?? response.songs.first

                guard let foundSong = bestMatch else {
                    print("MusicKit: No match found for '\(song)' by \(artist)")
                    return
                }

                print("MusicKit: Playing '\(foundSong.title)' by \(foundSong.artistName)")

                // Set queue and play
                ApplicationMusicPlayer.shared.queue = ApplicationMusicPlayer.Queue([foundSong])
                try await ApplicationMusicPlayer.shared.play()

                currentSong = foundSong.title
                isPlaying = true

            } catch {
                print("MusicKit error: \(error.localizedDescription)")
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
