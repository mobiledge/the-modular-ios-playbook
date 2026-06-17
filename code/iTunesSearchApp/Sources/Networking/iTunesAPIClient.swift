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

    private struct SearchResponse<T: Decodable>: Decodable {
        let resultCount: Int
        let results: [T]
    }

    func searchMusic(term: String) async throws -> [Track] {
        try await search(term: term, media: "music", entity: "song")
    }

    func searchMovies(term: String) async throws -> [Movie] {
        try await search(term: term, media: "movie", entity: "movie")
    }

    func searchAudiobooks(term: String) async throws -> [Audiobook] {
        try await search(term: term, media: "audiobook", entity: "audiobook")
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
