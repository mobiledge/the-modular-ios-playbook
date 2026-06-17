import SwiftUI
import DesignSystem

/// A single row in the music list (the SwiftUI equivalent of `TrackCell`).
///
/// Notice how little styling lives here now: the whole row is a `DSMediaRow`
/// from the design system, with just a save button as the trailing accessory.
///
/// MONOLITH NOTE: the row still reaches straight into `CoreDataManager.shared`.
/// The *design* coupling is gone (Chapter 2), but the *data* coupling remains —
/// that's Chapter 3's job.
struct TrackRow: View {
    let track: Track

    private let db = CoreDataManager.shared
    @State private var isSaved = false

    var body: some View {
        DSMediaRow(
            title: track.trackName,
            subtitle: track.artistName,
            caption: track.releaseDate?.mediumString,
            artworkURL: track.artworkUrl100
        ) {
            Button(action: toggleSave) {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundStyle(DSColors.brand)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
        }
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
