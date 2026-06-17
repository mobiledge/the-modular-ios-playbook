import SwiftUI

/// Searches the iTunes catalog for movies and lists the results.
///
/// This mirrors `MusicSearchView` exactly: search, fetch, list. No detail
/// screen, no persistence — just present what the network returned.
///
/// MONOLITH NOTE: like the Music feature, this view holds a direct reference to
/// the concrete `iTunesAPIClient.shared`. There is no injected dependency and no
/// protocol, so Movies cannot be compiled or tested without the networking code.
struct MoviesView: View {
    @State private var term = "Star Wars"
    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = iTunesAPIClient.shared

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
                ForEach(movies) { movie in
                    MovieRow(movie: movie)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Movies")
            .searchable(text: $term, prompt: "Search movies")
            .onSubmit(of: .search) { Task { await search() } }
            .overlay { if isLoading { ProgressView() } }
            .task { await search() }
        }
    }

    private func search() async {
        guard !term.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            movies = try await api.searchMovies(term: term)
        } catch {
            errorMessage = "Failed to load: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
