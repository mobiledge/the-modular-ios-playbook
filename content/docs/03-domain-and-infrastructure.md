---
title: "Chapter 3: Domain and Infrastructure Layers"
weight: 3
---

**The pain this chapter attacks: business logic you can't test without the whole world.** Today, validating a search query or a "save to library" rule means compiling the network stack, the database, and the UI — a minute-plus per run — and swapping a data source touches code everywhere. By the end of this chapter, the core rules run in milliseconds against a mock, and the outside world is swappable.

In the previous chapter, we established our foundational UI building blocks by extracting the `DesignSystem`.

Now, we must address the core logic and side-effects of our application. In our iTunesSearchApp monolith, the network clients, the data models (`Track`, `Movie`), the database managers, and third-party services are all entangled with UI components and ViewModels.

To untangle this, we turn to the primary motivation behind adopting a layered architecture: **Separation of Concerns**, heavily inspired by [Uncle Bob's Clean Architecture pattern](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html).

## The Clean Architecture Philosophy

The core rule of Clean Architecture is the Dependency Rule: *source code dependencies must point only inward, toward higher-level policies.*

This means that our core business rules (the "Domain") should not know anything about the outside world. They shouldn't know if data comes from a REST API, a local database, or a mock file. By separating these concerns, our application becomes highly testable, maintainable, and flexible to change.

We will achieve this by creating two distinct layers: the **Domain** layer and the **Infrastructure** layer.

## Step 1: The Domain Layer

The Domain layer is the heart of your application. It encapsulates the core business rules, entities, and use cases. It must be completely isolated and have **zero** dependencies on outside frameworks or infrastructure details.

1.  **Create the Module:** Create a new target or package named `Domain`.
2.  **Move Entities:** Move your core models like `Track.swift`, `Movie.swift`, and `Audiobook.swift` here. These should be plain Swift structs or classes.
3.  **Define Interfaces (Protocols):** This is crucial. The Domain layer dictates what it needs from the outside world using protocols, but it does *not* implement them. For example, it might define a `TrackRepository` protocol, but it won't contain the code to actually fetch from the iTunes API.

## Step 2: The Infrastructure Layer

The Infrastructure layer contains everything where the app talks to the "outside world." If it involves I/O, it belongs here.

This includes:
- **Networking:** HTTP clients, API routers, and parsing logic.
- **File System & Databases:** CoreData, Realm, or UserDefaults wrappers.
- **Third-Party Vendor Services:** Analytics, telemetry, feature flags, crash reporting, etc.

1.  **Create the Module:** Create a new target or package named `Infrastructure`.
2.  **Implement Domain Interfaces:** This module will depend on the `Domain` module. It will contain concrete implementations of the protocols defined in the Domain. For instance, `iTunesAPITrackRepository` will implement the `TrackRepository` protocol, containing the actual `URLSession` code.
3.  **Move External Integrations:** Move your `iTunesAPIClient.swift`, third-party analytics SDK wrappers, and crash reporter initializations into this module.

## The New Architecture Graph

Let's look at how our dependency graph is evolving based on these Clean Architecture principles:

```text
    ┌──────────────┐
    │              │
    │ iTunesSearch │
    │     App      │
    └─┬──────────┬─┘
      │          │
      ▼          ▼
┌─────────┐ ┌──────────────┐
│         │ │              │
│ Infra-  │ │    Domain    │
│structure│ │              │
│         │ │              │
└────┬────┘ └──────▲───────┘
     │             │
     └─────────────┘
```

Notice the flow:
- `iTunesSearchApp` depends on both `Infrastructure` (to inject dependencies) and `Domain` (to use use cases and entities).
- `Infrastructure` depends on `Domain` to implement its protocols and return its entities.
- Crucially, `Domain` depends on **nothing**. It is completely isolated from the specific details of networking or databases.

## The Payoff: True Separation

By applying Uncle Bob's Clean Architecture concepts, we gain massive advantages:

1.  **Testability:** Because the Domain layer has no external dependencies, we can write blazing-fast unit tests for our core business logic without ever making a network request or writing to a disk. We simply pass in mock implementations of our Infrastructure protocols.
2.  **Flexibility:** Want to swap out your third-party analytics provider? Or move from CoreData to Realm? You only need to change the `Infrastructure` module. The `Domain` layer and the `iTunesSearchApp` remain completely unaffected.

## Hands-On: Split into Domain and Infrastructure

The [`code/ch03-domain-infrastructure`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch03-domain-infrastructure) project applies both steps. Diff it against `ch02-design-system` to see exactly what moved.

### The Domain package

[`Packages/Domain`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch03-domain-infrastructure/Packages/Domain) contains only plain Swift:

- **Entities** — `Track`, `Movie`, `Audiobook`, `SavedItem`, and a `MediaType` enum. Notice they use concept-first names (`name`, `artist`, `artworkURL`) rather than the iTunes JSON names. They are no longer `Decodable`; decoding is an outside concern.
- **Repository protocols** — `MediaSearchRepository` and `LibraryRepository`. The domain declares *what* it needs, not *how*.
- **Cross-cutting service contracts** — `Logger`, `CrashReporter`, `AnalyticsTracker`, and `FeatureFlagProvider`, plus the typed `AnalyticsEvent` and `FeatureFlag`, in `Observability/Contracts.swift`. These are the same four protocols we seeded into the Chapter 1 monolith; now they move *inward* to the layer that owns contracts. They belong here for the same reason the repositories do — they describe what the app needs ("log this", "track that", "is this flag on?") without naming a vendor.
- **A use case** — `SearchMediaUseCase`, which trims and validates a query before delegating to a repository.

Crucially, the Domain's `Package.swift` declares **no dependencies**, and no file in it imports SwiftUI, Core Data, or any networking API.

### The Infrastructure package

[`Packages/Infrastructure`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch03-domain-infrastructure/Packages/Infrastructure) `depends on Domain` and provides the concrete details:

- `SearchDTOs.swift` holds the `Decodable` DTOs that know the iTunes JSON shape (`trackName`, `artworkUrl100`, …) and map themselves to domain entities. This is the *only* file that changes if the API's JSON changes.
- `ITunesSearchRepository` implements `MediaSearchRepository` with `URLSession`.
- `CoreDataLibraryRepository` (over an internal `CoreDataStack`) implements `LibraryRepository`.
- `Observability/ConsoleServices.swift` holds `ConsoleLogger`, `ConsoleAnalytics`, `ConsoleCrashReporter`, and `LocalFeatureFlags` — the same console implementations from Chapter 1, now sitting where the real vendor adapters (a `RemoteLogger`, a Crashlytics or Amplitude wrapper) would go. Note that `ConsoleLogger` *replaces* the old internal `Logger` enum: logging is now the same kind of injectable contract as everything else, so `ITunesSearchRepository` and the Core Data stack take a `Logger` rather than reaching for a global. The `#if MOCK_SERVICES` global is gone too; in the next two chapters the *choice* of implementation moves out of the code entirely and into a composition root.

### What the app looks like now

The feature views import `Domain` and `Infrastructure`. They program against the protocols and entities, and only reach for a concrete type to *construct* it:

```swift
private let search = SearchMediaUseCase(repository: ITunesSearchRepository())
private let library: LibraryRepository = CoreDataLibraryRepository()
```

That inline construction is the last bit of coupling; Chapter 6's composition root removes it.

### The payoff, made real

Because `SearchMediaUseCase` depends only on a protocol, [`Packages/Domain/Tests/DomainTests`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch03-domain-infrastructure/Packages/Domain/Tests/DomainTests) verifies its logic with a hand-written mock repository — no network, no disk, milliseconds to run:

```swift
func testBlankQueryReturnsEmptyAndNeverHitsRepository() async throws {
    let repo = MockSearchRepository()
    let useCase = SearchMediaUseCase(repository: repo)
    let results = try await useCase.music(matching: "   ")
    XCTAssertEqual(results, [])
    XCTAssertEqual(repo.musicCallCount, 0)
}
```

## Checkpoint: Untestable Logic, Relieved

You can now run your core business-logic tests in milliseconds — no network, no database, no app target — and swap a data source by touching only `Infrastructure`.

| What you do | Monolith (Ch1 baseline) | After this chapter |
| --- | --- | --- |
| Run the business-logic tests | Compile whole app first, ~1m+ | `Domain` tests, ~0.3s, no I/O |
| Swap CoreData → Realm (or analytics vendor) | Ripples through app + UI | Touches `Infrastructure` only |
| Reach the network from a domain rule | Easy — nothing stops it | Won't compile — `Domain` imports nothing |

*Illustrative figures; measure your own in [`code/ch03-domain-infrastructure`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch03-domain-infrastructure). A sub-second domain test suite is the headline.*

## The Next Crack: One Giant Feature Bucket

Our core business logic is now safe and isolated. But the UI and features in `iTunesSearchApp` are still a massive, tangled web of screens in a single target — Team A and Team B still edit the same files, and feature work still triggers slow, app-wide builds. In the next chapter, we introduce **Vertical Slicing** to break apart the features themselves.

---

> **Next:** [Chapter 4: Vertical Slicing (Feature Modules)]({{< relref "04-vertical-slicing" >}})
