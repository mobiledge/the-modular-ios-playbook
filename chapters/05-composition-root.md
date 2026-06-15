# The App Module — Composition Root

The `@main` App is the only place that imports everything. It acts as the "glue", instantiating the concrete infrastructure, concrete repositories, and injecting them into the ViewModels.

**Cross-Module Routing:**
Because `MusicFeature` and `MovieFeature` cannot import each other, navigation between them must be handled by the Composition Root. This is typically done using Closures or a Coordinator (MVVM-C) pattern:
1. **The Request:** `MusicViewModel` defines an external closure `var onNavigateToMovie: ((MovieID) -> Void)?`.
2. **The Wiring:** Inside `AppContainer`, when initializing `MusicViewModel`, the closure is assigned to trigger navigation state change.
3. **The Result:** The App injects the destination `MovieView` (which it can import) without `MusicUI` ever knowing `MovieUI` exists.

```swift
import SwiftUI
import CoreInfrastructureImpl     // Concrete Analytics, Flags
import CoreNetworkImpl            // iTunesClient
import MusicInterface             
import MusicImplementation        // Concrete Stores, Repos
import MusicUI

@MainActor
@Observable
final class AppContainer {
    let musicViewModel: MusicViewModel

    init(useMockData: Bool = false) {
        // 1. Setup Core Infrastructure
        let analytics = OSLogAnalyticsService()
        let featureFlags = MockFeatureFlagService()

        // 2. Setup Core Network
        let client = iTunesClient(session: .shared)

        // 3. Setup Vertical Slices (Repositories)
        let musicRepo: any MusicRepository = useMockData 
            ? MockMusicRepository() 
            : LiveMusicRepository(client: client)

        // 4. Inject Dependencies up the chain
        let musicStore = MusicStoreImpl(
            repository: musicRepo, 
            analytics: analytics
        )
        
        musicViewModel = MusicViewModel(
            store: musicStore, 
            featureFlags: featureFlags
        )
    }
}

@main
struct iTunesSearchApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MusicView(viewModel: container.musicViewModel)
        }
    }
}

```
