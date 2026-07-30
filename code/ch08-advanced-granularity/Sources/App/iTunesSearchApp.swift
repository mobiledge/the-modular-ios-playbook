import SwiftUI

/// The app entry point.
///
/// With the SwiftUI app lifecycle, this single `App` struct replaces the
/// classic UIKit `AppDelegate` + `SceneDelegate` pair from the chapter's
/// anatomy. It is still part of the one-and-only monolith target.
@main
struct ITunesSearchApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
