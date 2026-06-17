import SwiftUI

/// Searches movies and pushes to a detail screen on tap.
struct MoviesView: View {
    @State private var term = "Star Wars"
    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = iTunesAPIClient.shared

    var body: some View {
        NavigationStack {
            List(movies) { movie in
                NavigationLink(value: movie) {
                    HStack(spacing: 12) {
                        ArtworkView(url: movie.artworkUrl100)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(movie.trackName).font(.headline).lineLimit(2)
                            if let genre = movie.primaryGenreName {
                                Text(genre)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Movies")
            .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
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
