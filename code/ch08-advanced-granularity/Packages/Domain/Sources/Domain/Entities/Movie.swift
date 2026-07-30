import Foundation

/// A movie — a pure domain entity.
public struct Movie: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let artist: String
    public let artworkURL: URL?
    public let overview: String?
    public let releaseDate: Date?
    public let genre: String?
    public let price: Double?

    public init(
        id: Int,
        title: String,
        artist: String,
        artworkURL: URL? = nil,
        overview: String? = nil,
        releaseDate: Date? = nil,
        genre: String? = nil,
        price: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.overview = overview
        self.releaseDate = releaseDate
        self.genre = genre
        self.price = price
    }
}
