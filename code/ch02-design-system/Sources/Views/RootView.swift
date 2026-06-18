import SwiftUI
import DesignSystem

/// The app's root tab bar, wiring together the two core features.
///
/// With the SwiftUI app lifecycle this composition lives here in a `TabView`
/// (in the UIKit world it would have lived in the `SceneDelegate`). Note how the
/// root knows about every feature directly — another hallmark of the monolith
/// we'll untangle in the Composition Root chapter.
struct RootView: View {
    var body: some View {
        TabView {
            MusicSearchView()
                .tabItem { Label("Music", systemImage: "music.note") }

            PodcastsView()
                .tabItem { Label("Podcasts", systemImage: "mic") }
        }
        .tint(DSColors.brand)
    }
}

#Preview {
    RootView()
}
