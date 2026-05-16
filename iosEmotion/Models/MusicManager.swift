import Foundation
import AVFoundation
import Combine

@MainActor
class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published var isPlaying = false
    @Published var currentSong: String?

    // ─── YOUR SPOTIFY CREDENTIALS ───
    private let clientID     = "5f715c804bec414b98b3ae8894382acd"
    private let clientSecret = "2990e41348c148878823b617f8590562"
    // ────────────────────────────────

    private var player: AVPlayer?
    private var accessToken: String?
    private var tokenExpiry: Date?

    private init() {
        // Allow audio to play in background and mix with silence
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: []
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Public: Play in-app (no Spotify app switch)
    func playSong(song: String, artist: String) {
        if currentSong == song && isPlaying {
            print("▶️ MusicManager: '\(song)' is already playing, ignoring play request.")
            return
        }
        
        let cleanArtist = artist.replacingOccurrences(of: "(Me)", with: "").trimmingCharacters(in: .whitespaces)
        
        print("▶️ MusicManager.playSong called: '\(song)' by \(cleanArtist)")
        Task {
            do {
                let token = try await getAccessToken()
                print("▶️ Token OK, searching...")
                guard let previewURL = try await getPreviewURL(song: song, artist: cleanArtist, token: token) else {
                    print("⚠️ No preview URL for '\(song)' — try a different track or market")
                    return
                }
                await startPlayback(url: previewURL, title: song)
            } catch {
                print("❌ MusicManager error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Stop
    func stop() {
        guard let currentPlayer = player else { return }
        
        // Detach player immediately so UI updates and new songs can play
        player = nil
        isPlaying = false
        currentSong = nil
        
        // Smooth fade out over 1.5 seconds
        Task {
            let steps = 15
            let interval = 1.5 / Double(steps)
            let stepAmount = currentPlayer.volume / Float(steps)
            
            for _ in 0..<steps {
                currentPlayer.volume = max(0, currentPlayer.volume - stepAmount)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
            currentPlayer.pause()
            print("MusicManager: Stopped and faded out ✓")
        }
    }

    // MARK: - Internal Playback
    private func startPlayback(url: URL, title: String) async {
        // Stop and fade out any current track first
        stop()

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.volume = 0.0
        newPlayer.play()

        self.player = newPlayer
        self.currentSong = title
        self.isPlaying = true
        print("MusicManager: Now playing '\(title)' in-app ✓")
        
        // Smooth fade in over 2.5 seconds
        Task {
            let steps = 25
            let interval = 2.5 / Double(steps)
            let stepAmount = 1.0 / Float(steps)
            
            for _ in 0..<steps {
                guard self.player === newPlayer else { return }
                newPlayer.volume = min(1.0, newPlayer.volume + stepAmount)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
            
            if self.player === newPlayer {
                newPlayer.volume = 1.0
            }
        }
    }

    // MARK: - Get Spotify Access Token
    private func getAccessToken() async throws -> String {
        if let token = accessToken, let expiry = tokenExpiry, Date() < expiry {
            return token
        }
        let credentials = "\(clientID):\(clientSecret)"
        guard let credData = credentials.data(using: .utf8) else {
            throw SpotifyError.invalidCredentials
        }

        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(credData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)

        // Debug: print raw response if decoding fails
        guard let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
            let raw = String(data: data, encoding: .utf8) ?? "unreadable"
            print("MusicManager token error: \(raw)")
            throw SpotifyError.invalidCredentials
        }

        accessToken = tokenResponse.access_token
        tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in - 60))
        print("MusicManager: Token obtained ✓")
        return tokenResponse.access_token
    }

    // MARK: - Search via Deezer (free, no auth, still has previews)
    private func getPreviewURL(song: String, artist: String, token: String) async throws -> URL? {
        // Deezer API: free, no auth needed, preview_url still works in 2024
        let query = "\(song) \(artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.deezer.com/search?q=\(query)&limit=5&output=json"

        guard let url = URL(string: urlString) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)

        let raw = String(data: data, encoding: .utf8) ?? ""
        print("▶️ Deezer search raw: \(raw.prefix(300))")

        guard let response = try? JSONDecoder().decode(DeezerResponse.self, from: data) else {
            print("❌ Deezer decode error")
            return nil
        }

        // Find best match with a preview URL
        let best = response.data.first(where: {
            $0.preview != nil && (
                $0.title.localizedCaseInsensitiveContains(song) ||
                $0.artist.name.localizedCaseInsensitiveContains(artist)
            )
        }) ?? response.data.first(where: { $0.preview != nil })

        guard let track = best, let previewStr = track.preview,
              let previewURL = URL(string: previewStr) else {
            print("⚠️ No Deezer preview for '\(song)'")
            return nil
        }

        print("✅ Deezer preview: '\(track.title)' by \(track.artist.name)")
        return previewURL
    }
}

// MARK: - Errors
enum SpotifyError: LocalizedError {
    case invalidCredentials, trackNotFound(String)
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid credentials"
        case .trackNotFound(let s): return "No preview for '\(s)'"
        }
    }
}

// MARK: - Spotify Token Model (kept for token fetch)
private struct TokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
}

// MARK: - Deezer Response Models
private struct DeezerResponse: Decodable {
    let data: [DeezerTrack]
    struct DeezerTrack: Decodable {
        let title: String
        let preview: String?
        let artist: DeezerArtist
    }
    struct DeezerArtist: Decodable {
        let name: String
    }
}
