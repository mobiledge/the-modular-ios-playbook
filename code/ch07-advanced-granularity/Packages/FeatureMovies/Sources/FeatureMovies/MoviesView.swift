import SwiftUI
import DesignSystem
import Domain

/// The Movies feature. Search + library are injected as domain protocols.
public struct MoviesView: View {
    @State private var term = "Star Wars"
    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let search: SearchMediaUseCase
    private let library: LibraryRepository

    public init(searchRepository: MediaSearchRepository, libraryRepository: LibraryRepository) {
        self.search = SearchMediaUseCase(repository: searchRepository)
        self.library = libraryRepository
    }

    public var body: some View {
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
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie, library: library)
            }
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
