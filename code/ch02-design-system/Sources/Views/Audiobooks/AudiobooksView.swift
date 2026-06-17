import SwiftUI
import DesignSystem

/// Searches and lists audiobooks, with a save-to-library toggle per row.
struct AudiobooksView: View {
    @State private var term = "Stephen King"
    @State private var books: [Audiobook] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let api = iTunesAPIClient.shared
    private let db = CoreDataManager.shared

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    DSText(errorMessage, style: .callout, color: DSColors.danger)
                }
                ForEach(books) { book in
                    DSMediaRow(
                        title: book.collectionName,
                        subtitle: book.artistName,
                        caption: book.primaryGenreName,
                        artworkURL: book.artworkUrl100
                    ) {
                        Button {
                            toggleSave(book)
                        } label: {
                            Image(systemName: db.isSaved(id: Int64(book.collectionId), mediaType: "audiobook") ? "checkmark.circle.fill" : "plus.circle")
                                .foregroundStyle(DSColors.brand)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Audiobooks")
            .searchable(text: $term, prompt: "Search audiobooks")
            .onSubmit(of: .search) { Task { await search() } }
            .overlay { if isLoading { ProgressView() } }
            .task { await search() }
        }
    }

    private func toggleSave(_ book: Audiobook) {
        let id = Int64(book.collectionId)
        if db.isSaved(id: id, mediaType: "audiobook") {
            db.remove(id: id, mediaType: "audiobook")
        } else {
            db.save(
                SavedItem(
                    id: id,
                    title: book.collectionName,
                    subtitle: book.artistName,
                    artworkURL: book.artworkUrl100?.absoluteString,
                    mediaType: "audiobook",
                    savedAt: Date()
                )
            )
        }
    }

    private func search() async {
        guard !term.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            books = try await api.searchAudiobooks(term: term)
        } catch {
            errorMessage = "Failed to load: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
