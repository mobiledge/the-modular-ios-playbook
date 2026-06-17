import SwiftUI
import DesignSystem
import Domain
import Infrastructure

/// Displays everything the user has saved locally, across all media types.
struct LibraryView: View {
    @StateObject private var model = LibraryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if model.items.isEmpty {
                    ContentUnavailableView(
                        "Your Library is Empty",
                        systemImage: "books.vertical",
                        description: Text("Save songs, movies, and audiobooks to see them here.")
                    )
                } else {
                    List {
                        ForEach(model.items) { item in
                            DSMediaRow(
                                title: item.title,
                                subtitle: item.subtitle,
                                caption: item.mediaType.rawValue.capitalized,
                                artworkURL: item.artworkURL
                            )
                        }
                        .onDelete(perform: model.delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Library")
            .toolbar {
                if !model.items.isEmpty { EditButton() }
            }
            .onAppear { model.reload() }
        }
    }
}

/// The view model now depends on the domain's `LibraryRepository` protocol.
/// The concrete Core Data implementation is supplied by default for now;
/// Chapter 6 will inject it from the composition root, which also makes this
/// view model trivially testable with a mock repository.
final class LibraryViewModel: ObservableObject {
    @Published var items: [SavedItem] = []

    private let library: LibraryRepository

    init(library: LibraryRepository = CoreDataLibraryRepository()) {
        self.library = library
    }

    func reload() {
        items = library.fetchAll()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            library.remove(id: item.id, mediaType: item.mediaType)
        }
        reload()
    }
}
