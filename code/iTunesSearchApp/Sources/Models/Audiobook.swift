import Foundation

/// An audiobook returned by the iTunes Search API (`media=audiobook`).
/// Audiobooks are keyed on `collectionId`/`collectionName` rather than track fields.
struct Audiobook: Decodable, Identifiable, Hashable {
    let collectionId: Int
    let collectionName: String
    let artistName: String
    let artworkUrl100: URL?
    let releaseDate: Date?
    let primaryGenreName: String?
    let description: String?

    var id: Int { collectionId }
}
