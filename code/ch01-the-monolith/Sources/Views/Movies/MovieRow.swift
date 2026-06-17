import SwiftUI

/// A single row in the movies list. Deliberately parallel to `TrackRow` in the
/// Music feature: pure presentation of a `Movie`, with nothing to save.
struct MovieRow: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(url: movie.artworkUrl100)

            VStack(alignment: .leading, spacing: 2) {
                Text(movie.trackName).font(.headline).lineLimit(2)
                Text(movie.artistName)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                if let releaseDate = movie.releaseDate {
                    Text(releaseDate.mediumString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
