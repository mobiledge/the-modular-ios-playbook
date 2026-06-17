import SwiftUI
import DesignSystem

/// Shows details for a single movie and lets the user save it to the library.
struct MovieDetailView: View {
    let movie: Movie

    private let db = CoreDataManager.shared
    @State private var isSaved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                DSArtwork(url: movie.artworkUrl100, size: 140)

                DSText(movie.trackName, style: .title)
                DSText(movie.artistName, style: .callout)

                HStack(spacing: DSSpacing.sm) {
                    if let genre = movie.primaryGenreName {
                        DSTag(genre)
                    }
                    if let price = movie.trackPrice {
                        DSTag(String(format: "$%.2f", price), color: DSColors.success)
                    }
                }

                if let releaseDate = movie.releaseDate {
                    DSText("Released \(releaseDate.mediumString)", style: .caption)
                }

                if let description = movie.longDescription {
                    DSText(description, style: .body)
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
            isSaved = db.isSaved(id: Int64(movie.trackId), mediaType: "movie")
        }
    }

    private func toggleSave() {
        if isSaved {
            db.remove(id: Int64(movie.trackId), mediaType: "movie")
        } else {
            db.save(
                SavedItem(
                    id: Int64(movie.trackId),
                    title: movie.trackName,
                    subtitle: movie.artistName,
                    artworkURL: movie.artworkUrl100?.absoluteString,
                    mediaType: "movie",
                    savedAt: Date()
                )
            )
        }
        isSaved.toggle()
    }
}
