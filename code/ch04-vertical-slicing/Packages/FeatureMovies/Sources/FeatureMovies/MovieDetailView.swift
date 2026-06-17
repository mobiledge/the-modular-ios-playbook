import SwiftUI
import DesignSystem
import Domain
import Infrastructure

/// Internal to the Movies feature — its list pushes to this detail screen.
struct MovieDetailView: View {
    let movie: Movie

    private let library: LibraryRepository = CoreDataLibraryRepository()
    @State private var isSaved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                DSArtwork(url: movie.artworkURL, size: 140)

                DSText(movie.title, style: .title)
                DSText(movie.artist, style: .callout)

                HStack(spacing: DSSpacing.sm) {
                    if let genre = movie.genre {
                        DSTag(genre)
                    }
                    if let price = movie.price {
                        DSTag(String(format: "$%.2f", price), color: DSColors.success)
                    }
                }

                if let releaseDate = movie.releaseDate {
                    DSText("Released \(releaseDate.mediumString)", style: .caption)
                }

                if let overview = movie.overview {
                    DSText(overview, style: .body)
                }

                DSButton(
                    isSaved ? "Saved to Library" : "Save to Library",
                    systemImage: isSaved ? "checkmark" : "plus",
                    style: isSaved ? .secondary : .primary
                ) {
                    toggleSave()
                }
                .padding(.top, DSSpacing.sm)
            }
            .padding(DSSpacing.lg)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isSaved = library.isSaved(id: movie.id, mediaType: .movie)
        }
    }

    private func toggleSave() {
        if isSaved {
            library.remove(id: movie.id, mediaType: .movie)
        } else {
            library.save(
                SavedItem(
                    id: movie.id,
                    title: movie.title,
                    subtitle: movie.artist,
                    artworkURL: movie.artworkURL,
                    mediaType: .movie,
                    savedAt: Date()
                )
            )
        }
        isSaved.toggle()
    }
}
