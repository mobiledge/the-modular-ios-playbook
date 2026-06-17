import Foundation

/// An audiobook — a pure domain entity.
public struct Audiobook: Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let author: String
    public let artworkURL: URL?
    public let releaseDate: Date?
    public let genre: String?

    public init(
        id: Int,
        title: String,
        author: String,
        artworkURL: URL? = nil,
        releaseDate: Date? = nil,
        genre: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.artworkURL = artworkURL
        self.releaseDate = releaseDate
        self.genre = genre
    }
}
