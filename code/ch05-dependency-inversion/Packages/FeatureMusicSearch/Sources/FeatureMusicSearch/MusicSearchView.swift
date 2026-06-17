import SwiftUI
import DesignSystem
import Domain

/// The Music Search feature. Its dependencies are now *injected* as domain
/// protocols — it has no idea the iTunes API or Core Data exist. The Composition
/// Root (Chapter 6) supplies the concrete implementations.
public struct MusicSearchView: View {
    @State private var term = "Jack Johnson"
    @State private var tracks: [Track] = []
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
            List {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
                ForEach(tracks) { track in
                    TrackRow(track: track, library: library)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Music")
            .searchable(text: $term, prompt: "Search songs")
            .onSubmit(of: .search) { Task { await runSearch() } }
            .overlay { if isLoading { ProgressView() } }
            .task { await runSearch() }
        }
    }

    private func runSearch() async {
        isLoading = true
        errorMessage = nil
        do {
            tracks = try await search.music(matching: term)
        } catch {
            errorMessage = "Failed to load: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
