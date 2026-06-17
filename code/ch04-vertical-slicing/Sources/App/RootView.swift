import SwiftUI
import DesignSystem
import FeatureMusicSearch
import FeatureMovies
import FeatureAudiobooks
import FeatureLibrary

/// The app target is now thin: it only *composes* the feature modules into a
/// tab bar. Each tab is the public entry point of an independent feature package.
struct RootView: View {
    var body: some View {
        TabView {
            MusicSearchView()
                .tabItem { Label("Music", systemImage: "music.note") }

            MoviesView()
                .tabItem { Label("Movies", systemImage: "film") }

            AudiobooksView()
                .tabItem { Label("Audiobooks", systemImage: "headphones") }

            LibraryView()
                .tabItem { Label("Library", systemImage: "books.vertical") }
        }
        .tint(DSColors.brand)
    }
}
