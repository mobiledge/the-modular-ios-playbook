import SwiftUI
import Domain
import Infrastructure
import AppInterfaces
import FeatureLibrary

/// A "preview app" for the Library feature — and a perfect illustration that a
/// demo app is just a *miniature composition root*. It injects a real Core Data
/// repository and a trivial router (no other features required).
@main
struct FeatureLibraryDemoApp: App {
    var body: some Scene {
        WindowGroup {
            LibraryView(
                libraryRepository: CoreDataLibraryRepository(),
                router: PreviewRouter()
            )
        }
    }
}

/// The demo doesn't need real cross-feature navigation, so it stubs the router.
@MainActor
struct PreviewRouter: LibraryRouter {
    func destination(for item: SavedItem) -> AnyView {
        AnyView(Text(item.title).font(.title))
    }
}
