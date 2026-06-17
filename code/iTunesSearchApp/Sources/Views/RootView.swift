import SwiftUI

/// The app's root tab bar, wiring together the four core features.
///
/// In the UIKit world this composition lived in the SceneDelegate; here it is
/// a SwiftUI `TabView`. Note how the root knows about every feature directly —
/// another hallmark of the monolith we'll untangle in the Composition Root chapter.
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
        .tint(AppColors.primary)
    }
}

#Preview {
    RootView()
}
