import SwiftUI
import DesignSystem
import Domain

/// The Audiobooks feature. Dependencies injected as domain protocols.
public struct AudiobooksView: View {
    @State private var term = "Stephen King"
    @State private var books: [Audiobook] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let search: SearchMediaUseCase
    private let library: LibraryRepository

    public init(searchRepository: MediaSearchRepository, libraryRepository: LibraryRepository) {
        self.search = SearchMediaUseCase(repository: searchRepository)
        self.library = libraryRepository
    }

    public var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    DSText(errorMessage, style: .callout, color: DSColors.danger)
                }
                ForEach(books) { book in
                    DSMediaRow(
                        title: book.title,
                        subtitle: book.author,
                        caption: book.genre,
                        artworkURL: book.artworkURL
                    ) {
                        Button {
                            toggleSave(book)
                        } label: {
                            Image(systemName: library.isSaved(id: book.id, mediaType: .audiobook) ? "checkmark.circle.fill" : "plus.circle")
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
            .onSubmit(of: .search) { Task { await runSearch() } }
            .overlay { if isLoading { ProgressView() } }
            .task { await runSearch() }
        }
    }

    private func toggleSave(_ book: Audiobook) {
        if library.isSaved(id: book.id, mediaType: .audiobook) {
            library.remove(id: book.id, mediaType: .audiobook)
        } else {
            library.save(
                SavedItem(
                    id: book.id,
                    title: book.title,
                    subtitle: book.author,
                    artworkURL: book.artworkURL,
                    mediaType: .audiobook,
                    savedAt: Date()
                )
            )
        }
    }

    private func runSearch() async {
        isLoading = true
        errorMessage = nil
        do {
            books = try await search.audiobooks(matching: term)
        } catch {
            errorMessage = "Failed to load: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
