import SwiftUI
import DesignSystem
import Domain
import Infrastructure
import FeatureMusicSearch
import FeatureMovies
import FeatureAudiobooks
import FeatureLibrary

/// The app target is the only place that knows the concrete implementations.
/// It constructs them and injects them into the feature views. (Chapter 6
/// formalizes this wiring into a dedicated AppFactory + AppRouter.)
struct RootView: View {
    private let search: MediaSearchRepository = ITunesSearchRepository()
    private let library: LibraryRepository = CoreDataLibraryRepository()

    var body: some View {
        TabView {
            MusicSearchView(searchRepository: search, libraryRepository: library)
                .tabItem { Label("Music", systemImage: "music.note") }

            MoviesView(searchRepository: search, libraryRepository: library)
                .tabItem { Label("Movies", systemImage: "film") }

            AudiobooksView(searchRepository: search, libraryRepository: library)
                .tabItem { Label("Audiobooks", systemImage: "headphones") }

            LibraryView(libraryRepository: library, router: AppLibraryRouter(library: library))
                .tabItem { Label("Library", systemImage: "books.vertical") }
        }
        .tint(DSColors.brand)
    }
}
