import SwiftUI
import DesignSystem
import Domain
import Infrastructure

/// Searches movies and pushes to a detail screen on tap.
struct MoviesView: View {
    @State private var term = "Star Wars"
    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let search = SearchMediaUseCase(repository: ITunesSearchRepository())

    var body: some View {
        NavigationStack {
            List(movies) { movie in
                NavigationLink(value: movie) {
                    DSMediaRow(
                        title: movie.title,
                        subtitle: movie.genre,
                        artworkURL: movie.artworkURL
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("Movies")
            .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
            .searchable(text: $term, prompt: "Search movies")
            .onSubmit(of: .search) { Task { await runSearch() } }
            .overlay { if isLoading { ProgressView() } }
            .task { await runSearch() }
        }
    }

    private func runSearch() async {
        isLoading = true
        errorMessage = nil
        do {
            movies = try await search.movies(matching: term)
        } catch {
            errorMessage = "Failed to load: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
