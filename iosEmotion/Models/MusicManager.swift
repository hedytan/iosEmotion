import Foundation
import AVFoundation
import Combine

@MainActor
class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published var isPlaying = false
    @Published var currentSong: String?

    // ─── YOUR SPOTIFY CREDENTIALS ───
    private let clientID     = "YOUR_CLIENT_ID"
    private let clientSecret = "YOUR_CLIENT_SECRET"
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
        Task {
            do {
                let token = try await getAccessToken()
                guard let previewURL = try await getPreviewURL(song: song, artist: artist, token: token) else {
                    print("MusicManager: No preview available for '\(song)'")
                    return
                }
                await startPlayback(url: previewURL, title: song)
            } catch {
                print("MusicManager error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Stop
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentSong = nil
        print("MusicManager: Stopped ✓")
    }

    // MARK: - Internal Playback
    private func startPlayback(url: URL, title: String) async {
        // Stop any current track first
        player?.pause()

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = 1.0
        player?.play()

        currentSong = title
        isPlaying = true
        print("MusicManager: Now playing '\(title)' in-app ✓")
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

    // MARK: - Search for 30s Preview URL
    private func getPreviewURL(song: String, artist: String, token: String) async throws -> URL? {
        let query = "\(song) \(artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(query)&type=track&limit=5"

        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let response = try? JSONDecoder().decode(SearchResponse.self, from: data) else {
            let raw = String(data: data, encoding: .utf8) ?? "unreadable"
            print("MusicManager search error: \(raw)")
            throw SpotifyError.trackNotFound(song)
        }

        // Find best match with a preview URL
        let match = response.tracks.items.first(where: {
            $0.preview_url != nil &&
            $0.name.localizedCaseInsensitiveContains(song)
        }) ?? response.tracks.items.first(where: { $0.preview_url != nil })

        guard let track = match, let urlString = track.preview_url,
              let url = URL(string: urlString) else {
            print("MusicManager: No preview URL found for '\(song)'")
            return nil
        }

        print("MusicManager: Preview found for '\(track.name)' ✓")
        return url
    }
}

// MARK: - Errors
enum SpotifyError: LocalizedError {
    case invalidCredentials, trackNotFound(String)
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid Spotify credentials — check Client ID/Secret"
        case .trackNotFound(let s): return "No preview found for '\(s)'"
        }
    }
}

// MARK: - Spotify API Models
private struct TokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
}

private struct SearchResponse: Decodable {
    let tracks: TrackList
    struct TrackList: Decodable { let items: [Track] }
    struct Track: Decodable {
        let name: String
        let preview_url: String?
        let artists: [Artist]
    }
    struct Artist: Decodable { let name: String }
}
