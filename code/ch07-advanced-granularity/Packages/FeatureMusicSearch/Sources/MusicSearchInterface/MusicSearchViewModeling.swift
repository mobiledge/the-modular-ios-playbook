import Foundation
import Combine
import Domain

/// The contract between the UI and the Logic. Both micro-modules depend on this
/// interface; neither depends on the other. The UI renders whatever conforms to
/// this; the Logic provides a conforming view model.
@MainActor
public protocol MusicSearchViewModeling: ObservableObject {
    var query: String { get set }
    var tracks: [Track] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func search() async
    func isSaved(_ track: Track) -> Bool
    func toggleSave(_ track: Track)
}
