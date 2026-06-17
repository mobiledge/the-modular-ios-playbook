import Foundation

/// Talks to the iTunes Search API.
///
/// MONOLITH NOTE: this is exposed as a global `shared` singleton, and every
/// feature view instantiates it directly. There is no protocol boundary, so a
/// view in the Music feature is hard-wired to this concrete networking class.
/// Chapter 5 (Dependency Inversion) is where we fix this.
final class iTunesAPIClient {
    static let shared = iTunesAPIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    /// Decodes the iTunes envelope, skipping any individual result that fails to
    /// decode rather than failing the whole response. A single search can mix
    /// result shapes (tracks, collections, bundles), and a model only declares
    /// the fields it needs. Lossy decoding means one odd element drops out
    /// instead of emptying the entire list.
    private struct SearchResponse<T: Decodable>: Decodable {
        let results: [T]

        private enum CodingKeys: String, CodingKey { case results }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let elements = try container.decode([Failable<T>].self, forKey: .results)
            results = elements.compactMap(\.value)
        }
    }

    /// Turns a per-element decode failure into `nil` so one bad element doesn't
    /// sink the whole array.
    private struct Failable<T: Decodable>: Decodable {
        let value: T?

        init(from decoder: Decoder) throws {
            value = try? decoder.singleValueContainer().decode(T.self)
        }
    }

    func searchMusic(term: String) async throws -> [Track] {
        try await search(term: term, media: "music", entity: "song")
    }

    func searchPodcasts(term: String) async throws -> [Podcast] {
        try await search(term: term, media: "podcast", entity: "podcast")
    }

    private func search<T: Decodable>(term: String, media: String, entity: String) async throws -> [T] {
        let url = Endpoints.search(term: term, media: media, entity: entity)
        Logger.log("GET \(url.absoluteString)")

        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(SearchResponse<T>.self, from: data).results
    }
}
