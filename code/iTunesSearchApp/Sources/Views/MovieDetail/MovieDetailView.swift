import SwiftUI

/// Shows details for a single movie and lets the user save it to the library.
struct MovieDetailView: View {
    let movie: Movie

    private let db = CoreDataManager.shared
    @State private var isSaved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ArtworkView(url: movie.artworkUrl100, size: 140)

                Text(movie.trackName).font(.title).bold()
                Text(movie.artistName).foregroundStyle(AppColors.secondaryText)

                if let releaseDate = movie.releaseDate {
                    Label(releaseDate.mediumString, systemImage: "calendar")
                        .font(.subheadline)
                }
                if let price = movie.trackPrice {
                    Label(String(format: "$%.2f", price), systemImage: "tag")
                        .font(.subheadline)
                }
                if let description = movie.longDescription {
                    Text(description).font(.body)
                }

                PrimaryButton(
                    isSaved ? "Saved to Library" : "Save to Library",
                    systemImage: isSaved ? "checkmark" : "plus"
                ) {
                    toggleSave()
                }
                .padding(.top, 8)
            }
            .padding()
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
