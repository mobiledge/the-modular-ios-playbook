import Foundation

/// A single iTunes Search API endpoint.
///
/// Each case represents one kind of search, and knows the `media`/`entity` it
/// maps to. The case *is* the request: ask it for `url` and it hands back the
/// fully-formed URL. Adding a new kind of search means adding a case here — the
/// API client never has to learn about media or entity values.
///
/// Docs: https://performance-partners.apple.com/search-api
enum Endpoint {
    case music(term: String)
    case podcasts(term: String)

    /// The fully-formed request URL for this endpoint.
    var url: URL {
        switch self {
        case let .music(term):
            return Self.searchURL(term: term, media: "music", entity: "song")
        case let .podcasts(term):
            return Self.searchURL(term: term, media: "podcast", entity: "podcast")
        }
    }

    // MARK: - URL building

    private static let baseURL = URL(string: "https://itunes.apple.com")!

    private static func searchURL(term: String, media: String, entity: String, limit: Int = 25) -> URL {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("search"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: media),
            URLQueryItem(name: "entity", value: entity),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        return components.url!
    }
}
