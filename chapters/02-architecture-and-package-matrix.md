# Architecture and Package Matrix

## Why this architecture?

As codebases grow and multiple teams contribute, traditional horizontal layering (grouping all Repositories together, all Views together) creates bottlenecks. Vertical slicing addresses this:

* **Team Autonomy** — The Music team can iterate, refactor, and test the `Music` packages without touching the `Movie` packages or triggering rebuilds for other teams.
* **Encapsulation** — Implementations are hidden behind Interface packages. Domains cannot accidentally couple to each other's concrete types.
* **Swappability** — Any layer (Data Access, Analytics, Feature Flags) can be swapped for fakes at the composition root.
* **Faster Builds** — Xcode only recompiles the specific vertical slice that changed.

## The Package Matrix

Instead of a monolithic Data Access layer, the app is structured as independent Swift Packages per domain, resting on shared infrastructure.

| Domain / Layer | Interface Package (Protocols/Entities) | Implementation Package (Concrete Types) | UI Package (Views/VMs) |
| --- | --- | --- | --- |
| **Music** | `Song`, `MusicStore`, `MusicRepository` | `MusicStoreImpl`, `LiveMusicRepo`, `MockMusicRepo` | `MusicView`, `MusicViewModel` |
| **Movies** | `Movie`, `MovieStore`, `MovieRepository` | `MovieStoreImpl`, `LiveMovieRepo`, `MockMovieRepo` | `MovieView`, `MovieViewModel` |
| **Core Infra** | `AnalyticsService`, `FeatureFlagService` | `MixpanelAnalytics`, `LaunchDarklyService` | *N/A* |
| **Core Network** | *N/A* | `iTunesClient` | *N/A* |

*(Note: In smaller apps, UI can live in the Main App module. In larger apps, it is extracted into `MusicUI` to isolate SwiftUI previews and UI tests).*

**Swift Concurrency & Package Boundaries:**
By separating the `Interface` and `Implementation`, strict Swift concurrency becomes much easier to manage:
* All domain entities in the `Interface` (e.g., `Song`) must conform to `Sendable` so they can safely cross the isolation boundary from the background networking task in `Implementation` to the `@MainActor` UI.
* Protocols in the `Interface` should explicitly declare their isolation (e.g., `@MainActor public protocol MusicStore`) so the compiler enforces that UI components only interact with the store on the main thread.
