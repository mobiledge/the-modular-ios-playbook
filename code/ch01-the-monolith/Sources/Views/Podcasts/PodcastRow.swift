import SwiftUI

/// A single row in the podcasts list. Deliberately parallel to `TrackRow` in the
/// Music feature: pure presentation of a `Podcast`, with nothing to save.
struct PodcastRow: View {
    let podcast: Podcast

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(url: podcast.artworkUrl100)

            VStack(alignment: .leading, spacing: 2) {
                Text(podcast.collectionName).font(.headline).lineLimit(2)
                Text(podcast.artistName)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                if let releaseDate = podcast.releaseDate {
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
