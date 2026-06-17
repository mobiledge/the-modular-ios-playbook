import SwiftUI
import DesignSystem

/// The root view is now trivial: it asks the Composition Root (`AppFactory`) to
/// build each screen. It contains no knowledge of repositories, routers, or any
/// concrete implementation — all of that lives in `AppFactory`.
struct RootView: View {
    private let factory = AppFactory()

    var body: some View {
        TabView {
            factory.makeMusicSearch()
                .tabItem { Label("Music", systemImage: "music.note") }

            factory.makeMovies()
                .tabItem { Label("Movies", systemImage: "film") }

            factory.makeAudiobooks()
                .tabItem { Label("Audiobooks", systemImage: "headphones") }

            factory.makeLibrary()
                .tabItem { Label("Library", systemImage: "books.vertical") }
        }
        .tint(DSColors.brand)
    }
}
