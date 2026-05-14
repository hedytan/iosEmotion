import Foundation
import AVFoundation
import Combine

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    private var player: AVPlayer?
    
    @Published var isPlaying = false
    @Published var currentSong: String?
    
    func playSong(named: String) {
        // In a real app, this would search MusicKit or a local library.
        // For now, we'll simulate the "vibe" of loading a track.
        print("MusicManager: Now playing \(named)")
        self.currentSong = named
        self.isPlaying = true
        
        // Mock implementation: If you add .mp3 files to your project later,
        // this code will find them and play them automatically.
        if let url = Bundle.main.url(forResource: named.lowercased(), withExtension: "mp3") {
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            player?.play()
        }
    }
    
    func stop() {
        player?.pause()
        self.isPlaying = false
        self.currentSong = nil
    }
}
