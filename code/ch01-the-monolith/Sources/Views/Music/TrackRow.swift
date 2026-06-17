import SwiftUI

/// A single row in the music list (the SwiftUI equivalent of `TrackCell`).
///
/// The row is pure presentation: it takes a `Track` and draws it. There is no
/// persistence and nothing to toggle — the app simply shows what the network
/// returned.
struct TrackRow: View {
    let track: Track

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(url: track.artworkUrl100)

            VStack(alignment: .leading, spacing: 2) {
                Text(track.trackName).font(.headline).lineLimit(1)
                Text(track.artistName)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                if let releaseDate = track.releaseDate {
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
