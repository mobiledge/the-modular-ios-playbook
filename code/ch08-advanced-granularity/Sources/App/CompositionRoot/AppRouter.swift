import SwiftUI
import Domain
import AppInterfaces

/// Implements the routing protocols the features depend on. It owns no logic of
/// its own — it delegates to the `AppFactory` to build destination screens.
/// (In a UIKit app this role is usually played by a Coordinator.)
@MainActor
struct AppRouter: LibraryRouter {
    let factory: AppFactory

    func destination(for item: SavedItem) -> AnyView {
        factory.destination(for: item)
    }
}
