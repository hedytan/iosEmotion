import Foundation
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

    // MARK: - Public Entry Point
    func playSong(song: String, artist: String) {
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

    func stop() {
        isPlaying = false
        currentSong = nil
    }

    // MARK: - Get Access Token (Client Credentials Flow)
    private func getAccessToken() async throws -> String {
        // Return cached token if still valid
        if let token = accessToken, let expiry = tokenExpiry, Date() < expiry {
            return token
        }

        let credentials = "\(clientID):\(clientSecret)"
        guard let credData = credentials.data(using: .utf8) else {
            throw SpotifyError.invalidCredentials
        }
        let base64 = credData.base64EncodedString()

        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        accessToken = tokenResponse.access_token
        tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in - 60))
        print("SpotifyManager: Access token obtained ✓")
        return tokenResponse.access_token
    }

    // MARK: - Search Track
    private func searchTrack(song: String, artist: String, token: String) async throws -> String {
        let query = "\(song) artist:\(artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(query)&type=track&limit=1&market=AU"

        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)

        guard let track = searchResponse.tracks.items.first else {
            throw SpotifyError.trackNotFound(song)
        }

        print("SpotifyManager: Found '\(track.name)' by \(track.artists.first?.name ?? "?")")
        return track.id
    }

    // MARK: - Open Spotify Deep Link
    private func openSpotify(trackID: String) {
        let spotifyURI = URL(string: "spotify:track:\(trackID)")!
        let webFallback = URL(string: "https://open.spotify.com/track/\(trackID)")!

        if UIApplication.shared.canOpenURL(spotifyURI) {
            UIApplication.shared.open(spotifyURI)
        } else {
            // Spotify not installed — open in browser
            UIApplication.shared.open(webFallback)
        }
    }
}

// MARK: - Errors
enum SpotifyError: LocalizedError {
    case invalidCredentials
    case trackNotFound(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid Spotify credentials"
        case .trackNotFound(let s): return "Track '\(s)' not found on Spotify"
        }
    }
}

// MARK: - Response Models
private struct TokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
}

private struct SearchResponse: Decodable {
    let tracks: TrackList
    struct TrackList: Decodable {
        let items: [Track]
    }
    struct Track: Decodable {
        let id: String
        let name: String
        let artists: [Artist]
    }
    struct Artist: Decodable {
        let name: String
    }
}
