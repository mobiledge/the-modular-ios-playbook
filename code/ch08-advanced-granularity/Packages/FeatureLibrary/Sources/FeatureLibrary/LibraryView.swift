import SwiftUI
import DesignSystem
import Domain
import AppInterfaces

/// The Library feature. It is injected with a `LibraryRepository` (data) and a
/// `LibraryRouter` (navigation). It can send the user to a movie's detail screen
/// without importing FeatureMovies — it just asks the router for a destination.
public struct LibraryView: View {
    @StateObject private var model: LibraryViewModel
    private let router: LibraryRouter

    public init(libraryRepository: LibraryRepository, router: LibraryRouter) {
        _model = StateObject(wrappedValue: LibraryViewModel(library: libraryRepository))
        self.router = router
    }

    public var body: some View {
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
                            NavigationLink {
                                router.destination(for: item)
                            } label: {
                                DSMediaRow(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    caption: item.mediaType.rawValue.capitalized,
                                    artworkURL: item.artworkURL
                                )
                            }
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

final class LibraryViewModel: ObservableObject {
    @Published var items: [SavedItem] = []

    private let library: LibraryRepository

    init(library: LibraryRepository) {
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
