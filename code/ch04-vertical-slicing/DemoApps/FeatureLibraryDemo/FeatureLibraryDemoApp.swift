import SwiftUI
import FeatureLibrary

/// A "preview app" for the Library feature. It compiles only FeatureLibrary and
/// its dependencies — not the other features — so it builds in seconds and lets
/// a developer iterate on the Library UI in isolation.
///
/// The same pattern works for every feature; we ship one here as the example.
@main
struct FeatureLibraryDemoApp: App {
    var body: some Scene {
        WindowGroup {
            LibraryView()
        }
    }
}
