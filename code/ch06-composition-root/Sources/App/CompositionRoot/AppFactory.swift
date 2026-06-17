import SwiftUI
import Domain
import Infrastructure
import AppInterfaces
import FeatureMusicSearch
import FeatureMovies
import FeatureAudiobooks
import FeatureLibrary

/// The Composition Root.
///
/// This is the ONE type that imports every module and knows every concrete
/// implementation. It owns the singletons (the repositories), builds each
/// feature screen with its dependencies injected, and supplies the routing
/// destinations. Nothing else in the app constructs a concrete repository.
@MainActor
final class AppFactory {
    private let search: MediaSearchRepository
    private let library: LibraryRepository

    init(
        search: MediaSearchRepository = ITunesSearchRepository(),
        library: LibraryRepository = CoreDataLibraryRepository()
    ) {
        self.search = search
        self.library = library
    }

    // MARK: Feature screens

    func makeMusicSearch() -> some View {
        MusicSearchView(searchRepository: search, libraryRepository: library)
    }

    func makeMovies() -> some View {
        MoviesView(searchRepository: search, libraryRepository: library)
    }

    func makeAudiobooks() -> some View {
        AudiobooksView(searchRepository: search, libraryRepository: library)
    }

    func makeLibrary() -> some View {
        LibraryView(libraryRepository: library, router: AppRouter(factory: self))
    }

    // MARK: Routing destinations (used by AppRouter)

    func destination(for item: SavedItem) -> AnyView {
        switch item.mediaType {
        case .movie:
            let movie = Movie(
                id: item.id,
                title: item.title,
                artist: item.subtitle ?? "",
                artworkURL: item.artworkURL
            )
            return AnyView(MovieDetailView(movie: movie, library: library))
        case .music, .audiobook:
            return AnyView(SavedItemDetailView(item: item))
        }
    }
}
