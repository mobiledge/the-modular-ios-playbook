import SwiftUI
import Domain

/// The abstraction that lets `FeatureLibrary` navigate to a saved item's detail
/// screen WITHOUT importing the feature that owns that screen (e.g. FeatureMovies).
///
/// FeatureLibrary depends only on this protocol. The Composition Root in the app
/// target implements it and decides which concrete screen to build. This is how
/// we break feature-to-feature coupling.
@MainActor
public protocol LibraryRouter {
    /// Returns the detail screen for a saved item, type-erased so the caller
    /// needn't know the concrete view type.
    func destination(for item: SavedItem) -> AnyView
}
