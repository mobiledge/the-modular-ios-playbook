import Foundation

/// A movie returned by the iTunes Search API (`media=movie`).
struct Movie: Decodable, Identifiable, Hashable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let artworkUrl100: URL?
    let longDescription: String?
    let releaseDate: Date?
    let primaryGenreName: String?
    let trackPrice: Double?

    var id: Int { trackId }
}
