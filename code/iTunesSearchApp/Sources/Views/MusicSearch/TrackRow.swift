import SwiftUI

/// A single row in the music list (the SwiftUI equivalent of `TrackCell`).
///
/// MONOLITH NOTE: even a humble list row reaches straight into the
/// `CoreDataManager.shared` database singleton to toggle "saved" state.
/// This is exactly the kind of hidden coupling the playbook sets out to remove.
struct TrackRow: View {
    let track: Track

    private let db = CoreDataManager.shared
    @State private var isSaved = false

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

            Button(action: toggleSave) {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundStyle(AppColors.primary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .onAppear {
            isSaved = db.isSaved(id: Int64(track.trackId), mediaType: "music")
        }
    }

    private func toggleSave() {
        if isSaved {
            db.remove(id: Int64(track.trackId), mediaType: "music")
        } else {
            db.save(
                SavedItem(
                    id: Int64(track.trackId),
                    title: track.trackName,
                    subtitle: track.artistName,
                    artworkURL: track.artworkUrl100?.absoluteString,
                    mediaType: "music",
                    savedAt: Date()
                )
            )
        }
        isSaved.toggle()
    }
}
