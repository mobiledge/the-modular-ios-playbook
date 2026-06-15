# A Vertical Slice (Music Domain)

The Music domain owns everything required to fetch, store, and present music, isolated entirely from Movies or Audiobooks.

### 1. Music Interface

Defines the boundary. Contains no implementation details.

```swift
// Music/Interface/Song.swift
public struct Song: Identifiable, Sendable, Decodable { ... }

// Music/Interface/MusicRepository.swift
public protocol MusicRepository: Sendable {
    func search(term: String) async throws -> [Song]
}

// Music/Interface/MusicStore.swift
@MainActor
public protocol MusicStore: AnyObject, Observable {
    var results: [Song] { get }
    var isLoading: Bool { get }
    func search(term: String) async
}

```

### 2. Music Implementation

Contains the concrete classes. It imports `MusicInterface` (to conform to its protocols) and `CoreInfrastructure` (to log errors or check flags).

```swift
import MusicInterface
import CoreInfrastructureInterface

@Observable
@MainActor
public final class MusicStoreImpl: MusicStore {
    public private(set) var results: [Song] = []
    public private(set) var isLoading = false
    
    private let repository: any MusicRepository
    private let analytics: any AnalyticsService

    public init(repository: any MusicRepository, analytics: any AnalyticsService) {
        self.repository = repository
        self.analytics = analytics
    }

    public func search(term: String) async {
        isLoading = true
        analytics.trackEvent("Music_Search", properties: ["term": term])
        
        do {
            results = try await repository.search(term: term)
        } catch {
            // Handle error, optionally log to TelemetryService
        }
        isLoading = false
    }
}

```

### 3. Music UI

Depends ONLY on `MusicInterface` and `CoreInfrastructureInterface`. It never imports `MusicImplementation`.

**Unidirectional Data Flow:**
Using the `@Observable` macro in conjunction with the Store pattern creates a natural unidirectional flow:
* **State flows down:** The SwiftUI view reads state directly from the `MusicStore`. When the store updates, the view automatically invalidates and redraws.
* **Events flow up:** The view cannot mutate the store's state directly. Instead, it sends *intents* (e.g., `store.search(term:)`) which trigger asynchronous work. The store updates its own internal state when the work completes, completing the cycle.

```swift
import SwiftUI
import MusicInterface
import CoreInfrastructureInterface

@MainActor
@Observable
public final class MusicViewModel {
    private let store: any MusicStore
    private let featureFlags: any FeatureFlagService

    public init(store: any MusicStore, featureFlags: any FeatureFlagService) {
        self.store = store
        self.featureFlags = featureFlags
    }
    
    // ... presentation logic ...
}

```
