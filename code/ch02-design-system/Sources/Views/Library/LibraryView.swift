import SwiftUI
import DesignSystem

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
                                caption: item.mediaType.capitalized,
                                artworkURL: item.artworkURL.flatMap(URL.init(string:))
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

/// MONOLITH NOTE: the view model talks directly to `CoreDataManager.shared`.
/// There is no repository protocol between the UI and the database, so the
/// Library feature is welded to Core Data. Chapter 3 introduces that boundary.
final class LibraryViewModel: ObservableObject {
    @Published var items: [SavedItem] = []

    private let db = CoreDataManager.shared

    func reload() {
        items = db.fetchAll()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            db.remove(id: item.id, mediaType: item.mediaType)
        }
        reload()
    }
}
