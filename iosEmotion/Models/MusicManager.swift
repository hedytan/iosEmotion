import Foundation
import AVFoundation
import UIKit
import Combine

@MainActor
class MusicManager: ObservableObject {
    static let shared = MusicManager()

    @Published var isPlaying = false
    @Published var currentSong: String?

    // ─── REPLACE THESE WITH YOUR SPOTIFY CREDENTIALS ───
    private let clientID     = "YOUR_CLIENT_ID"
    private let clientSecret = "YOUR_CLIENT_SECRET"
    // ────────────────────────────────────────────────────

    private var accessToken: String?
    private var tokenExpiry: Date?

    private init() {}

    // MARK: - Play
    func playSong(song: String, artist: String) {
        // Release audio session so Spotify can take over
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        Task {
            do {
                let token = try await getAccessToken()
                let trackID = try await searchTrack(song: song, artist: artist, token: token)
                openSpotify(trackID: trackID)
                currentSong = song
                isPlaying = true
            } catch {
                print("SpotifyManager error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Stop (interrupts Spotify by claiming audio session)
    func stop() {
        guard isPlaying else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            // Claim playback category → interrupts Spotify
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            // We don't actually play anything — Spotify is now paused
            // Keep session active so Spotify stays paused while on feed
        } catch {
            print("AVAudioSession stop error: \(error)")
        }

        isPlaying = false
        currentSong = nil
        print("MusicManager: Spotify interrupted ✓")
    }

    // MARK: - Access Token
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
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = tokenResponse.access_token
        tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in - 60))
        return tokenResponse.access_token
    }

    // MARK: - Search
    private func searchTrack(song: String, artist: String, token: String) async throws -> String {
        let query = "\(song) artist:\(artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(query)&type=track&limit=5&market=AU"
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)

        let best = response.tracks.items.first(where: {
            $0.title.localizedCaseInsensitiveContains(song)
        }) ?? response.tracks.items.first

        guard let track = best else { throw SpotifyError.trackNotFound(song) }
        print("SpotifyManager: '\(track.title)' by \(track.artists.first?.name ?? "?")")
        return track.id
    }

    // MARK: - Open Spotify
    private func openSpotify(trackID: String) {
        let uri = URL(string: "spotify:track:\(trackID)")!
        let web = URL(string: "https://open.spotify.com/track/\(trackID)")!
        UIApplication.shared.open(UIApplication.shared.canOpenURL(uri) ? uri : web)
    }
}

// MARK: - Errors
enum SpotifyError: LocalizedError {
    case invalidCredentials, trackNotFound(String)
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid Spotify credentials"
        case .trackNotFound(let s): return "Track '\(s)' not found"
        }
    }
}

// MARK: - Models
private struct TokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
}
private struct SearchResponse: Decodable {
    let tracks: TrackList
    struct TrackList: Decodable { let items: [Track] }
    struct Track: Decodable {
        let id: String
        let title: String
        let artists: [Artist]
        enum CodingKeys: String, CodingKey { case id, title = "name", artists }
    }
    struct Artist: Decodable { let name: String }
}
