import SwiftUI
import Domain
import AppInterfaces
import DesignSystem
import FeatureMovies

/// The app's implementation of `LibraryRouter`. Because the app target is allowed
/// to import every module, it can decide that a saved *movie* should open
/// FeatureMovies' `MovieDetailView` — while FeatureLibrary stays oblivious to
/// FeatureMovies entirely.
@MainActor
struct AppLibraryRouter: LibraryRouter {
    let library: LibraryRepository

    func destination(for item: SavedItem) -> AnyView {
        switch item.mediaType {
        case .movie:
            let movie = Movie(
                id: item.id,
                title: item.title,
                artist: item.subtitle ?? "",
                artworkURL: item.artworkURL
            )
            return AnyView(MovieDetailView(movie: movie, library: library))
        case .music, .audiobook:
            return AnyView(SavedItemDetailView(item: item))
        }
    }
}

/// A minimal fallback detail for media types without their own feature screen.
private struct SavedItemDetailView: View {
    let item: SavedItem

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            DSArtwork(url: item.artworkURL, size: 140)
            DSText(item.title, style: .title)
            if let subtitle = item.subtitle {
                DSText(subtitle, style: .callout)
            }
            DSTag(item.mediaType.rawValue.capitalized)
        }
        .padding(DSSpacing.lg)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
