import Foundation
import Domain
import MusicSearchInterface

/// Pure logic. It conforms to the Interface's view-model contract and depends on
/// injected domain repositories. It links no SwiftUI and can be unit-tested
/// without compiling a single view.
@MainActor
public final class MusicSearchViewModel: MusicSearchViewModeling {
    @Published public var query: String
    @Published public private(set) var tracks: [Track] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let searchUseCase: SearchMediaUseCase
    private let library: LibraryRepository

    public init(
        query: String = "Jack Johnson",
        searchRepository: MediaSearchRepository,
        libraryRepository: LibraryRepository
    ) {
        self.query = query
        self.searchUseCase = SearchMediaUseCase(repository: searchRepository)
        self.library = libraryRepository
    }

    public func search() async {
        isLoading = true
        errorMessage = nil
        do {
            tracks = try await searchUseCase.music(matching: query)
        } catch {
            errorMessage = "Failed to load: \(error.localizedDescription)"
        }
        isLoading = false
    }

    public func isSaved(_ track: Track) -> Bool {
        library.isSaved(id: track.id, mediaType: .music)
    }

    public func toggleSave(_ track: Track) {
        if isSaved(track) {
            library.remove(id: track.id, mediaType: .music)
        } else {
            library.save(
                SavedItem(
                    id: track.id,
                    title: track.name,
                    subtitle: track.artist,
                    artworkURL: track.artworkURL,
                    mediaType: .music,
                    savedAt: Date()
                )
            )
        }
        // `isSaved` is computed from the store, so nudge observers to re-read it.
        objectWillChange.send()
    }
}
