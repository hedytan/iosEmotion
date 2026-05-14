import Foundation
import Combine
import MediaPlayer

@MainActor
class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published var isPlaying = false
    @Published var currentSong: String?

    private let player = MPMusicPlayerController.systemMusicPlayer

    private init() {}

    // MARK: - Play by song title + artist
    func playSong(song: String, artist: String) {
        // Request library access
        MPMediaLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("MediaPlayer: Not authorized — status: \(status.rawValue)")
                return
            }

            // Search user's Apple Music library
            let songFilter = MPMediaPropertyPredicate(
                value: song,
                forProperty: MPMediaItemPropertyTitle,
                comparisonType: .contains
            )
            let artistFilter = MPMediaPropertyPredicate(
                value: artist,
                forProperty: MPMediaItemPropertyArtist,
                comparisonType: .contains
            )

            let query = MPMediaQuery()
            query.addFilterPredicate(songFilter)
            query.addFilterPredicate(artistFilter)

            DispatchQueue.main.async {
                if let items = query.items, !items.isEmpty {
                    print("MediaPlayer: Found '\(items[0].title ?? "unknown")' — playing!")
                    self.player.setQueue(with: MPMediaItemCollection(items: items))
                    self.player.play()
                    self.currentSong = items[0].title
                    self.isPlaying = true
                } else {
                    // Fallback: search by title only
                    let titleOnly = MPMediaQuery()
                    titleOnly.addFilterPredicate(songFilter)
                    if let fallback = titleOnly.items, !fallback.isEmpty {
                        print("MediaPlayer: Fallback match '\(fallback[0].title ?? "unknown")'")
                        self.player.setQueue(with: MPMediaItemCollection(items: fallback))
                        self.player.play()
                        self.currentSong = fallback[0].title
                        self.isPlaying = true
                    } else {
                        print("MediaPlayer: '\(song)' not found in library. User needs to add it to Apple Music.")
                    }
                }
            }
        }
    }

    // MARK: - Stop
    func stop() {
        player.stop()
        isPlaying = false
        currentSong = nil
    }
}
