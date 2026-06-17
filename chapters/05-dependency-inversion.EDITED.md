# Chapter 5: Dependency Inversion & Interfaces

> **Editor's note (model pass).** This is a line-edited version of Chapter 5,
> rewritten to demonstrate the recommendations in `EDITORIAL-MEMO.md`. The
> substantive changes: (1) every name now matches the actual code in
> `code/ch05-dependency-inversion` — `LibraryRepository`, `CoreDataLibraryRepository`,
> `AppInterfaces`, `LibraryRouter`; (2) the snippets are SwiftUI, like the repo,
> not UIKit view controllers; (3) the chapter follows a Pain → Diagnosis →
> Refactor → Verify → New-trap rhythm; (4) a "Try it yourself" block and an
> end-of-chapter checkpoint connect the prose to the runnable project; (5) a
> short, honest note on the cost. Use it as a template for the other chapters.

At the end of [Chapter 4](./04-vertical-slicing.md) we shipped four feature packages — but we left two cracks in the wall. This chapter is about sealing them with one idea: the **D** in SOLID, **Dependency Inversion**.

## The Pain

Open the Chapter 4 project and look at `FeatureLibrary`. To load the user's saved items, it reaches straight for the concrete Core Data class:

```swift
// FeatureLibrary, end of Chapter 4 — the trap we left open
import Infrastructure   // <-- a feature importing the concrete data layer

public struct LibraryView: View {
    private let library = CoreDataLibraryRepository()   // concrete. fixed. unmockable.
    // ...
}
```

Two concrete problems fall out of that one `import`:

1. **You can't test `FeatureLibrary` without Core Data.** Every test spins up a real database, because the view *is* the thing that constructs `CoreDataLibraryRepository`.
2. **Features can't talk to each other without importing each other.** When the user taps a saved movie, the Library needs to push a detail screen owned by `FeatureMovies`. If `FeatureLibrary` imports `FeatureMovies`, we've rebuilt the monolith one level up — change the detail screen and the Library recompiles.

## The Diagnosis

Both problems have the same root cause: a high-level module (a feature) depends on a low-level module (the database; another feature). The Dependency Inversion Principle names the fix directly:

> **Dependency Inversion Principle:** High-level modules should not depend on low-level modules. Both should depend on abstractions — in Swift, protocols.

So we stop depending on *things* and start depending on *protocols*. The rest of the chapter applies that twice: once to data, once to navigation.

## Refactor, Part 1 — Invert the Data Dependency

The protocol already exists. Back in Chapter 3 the **Domain** layer declared *what it needs* without saying *how*:

```swift
// Domain — the abstraction (no Core Data, no UIKit, no knowledge of "how")
public protocol LibraryRepository {
    func save(_ item: SavedItem)
    func remove(id: Int, mediaType: MediaType)
    func isSaved(id: Int, mediaType: MediaType) -> Bool
    func fetchAll() -> [SavedItem]
}
```

`CoreDataLibraryRepository` (in **Infrastructure**) already conforms to it. So `FeatureLibrary` can drop its `import Infrastructure` entirely and ask for the protocol instead:

```swift
// FeatureLibrary — depends on the Domain abstraction, not the concrete database
import Domain   // for LibraryRepository — note: no Infrastructure import

public struct LibraryView: View {
    @StateObject private var model: LibraryViewModel

    public init(libraryRepository: LibraryRepository) {   // injected, not constructed
        _model = StateObject(wrappedValue: LibraryViewModel(library: libraryRepository))
    }
}
```

`FeatureLibrary` no longer knows Core Data exists. It depends only on a protocol from `Domain`. In a test you hand it an in-memory stub; in the app you hand it the real thing — the feature can't tell the difference.

## Refactor, Part 2 — Invert the Navigation Dependency

Now the harder one: how does the Library push a movie-detail screen it isn't allowed to import?

Same principle. `FeatureLibrary` shouldn't know *which* screen it's navigating to — only that *something* can produce a destination for a saved item. We capture that as a protocol. But where does it live? Not in `FeatureLibrary` (then `FeatureMovies` would have to import the Library), and not in any feature. It belongs in a small, shared **`AppInterfaces`** module that holds nothing but contracts:

```swift
// AppInterfaces — protocols only, no feature code
import SwiftUI
import Domain

@MainActor
public protocol LibraryRouter {
    func destination(for item: SavedItem) -> AnyView
}
```

`FeatureLibrary` takes a `LibraryRouter` and asks it for a view — without ever naming `FeatureMovies`:

```swift
// FeatureLibrary
import AppInterfaces   // for the LibraryRouter protocol — NOT for any feature

NavigationLink {
    router.destination(for: item)   // "give me the right screen" — owner unknown
} label: {
    DSMediaRow(title: item.title, subtitle: item.subtitle, /* ... */)
}
```

## Verify: the New Dependency Graph

Here is what those two refactors buy us. Every arrow now points at an abstraction:

```text
        ┌───────────────────────────┐
        │   iTunesSearchApp (app)   │   (wires it all up — Chapter 6)
        └───┬───────────────────┬───┘
            │                   │
   ┌────────▼────────┐ ┌────────▼────────┐
   │  FeatureLibrary │ │  FeatureMovies  │   features never import each other
   └───┬─────────┬───┘ └────────┬────────┘
       │         │              │
       ▼         ▼              ▼
   ┌────────┐ ┌──────────────────────────┐
   │ Domain │ │       AppInterfaces      │   abstractions only
   └────▲───┘ └──────────────────────────┘
        │
   ┌────┴───────────┐
   │ Infrastructure │   conforms to Domain protocols (CoreDataLibraryRepository)
   └────────────────┘
```

Read the two guarantees off the picture:

- **No feature imports another feature.** Library reaches `FeatureMovies` only through `LibraryRouter`.
- **No feature imports `Infrastructure`.** Features depend on `Domain` and `AppInterfaces` — abstractions, never the concrete database or network.

The compiler now enforces what used to be a code-review rule.

## Try It Yourself

In `code/ch05-dependency-inversion`:

1. Run `xcodegen generate && open iTunesSearchApp.xcodeproj`.
2. Open `FeatureLibrary/Package.swift` and confirm its dependencies are `DesignSystem`, `Domain`, and `AppInterfaces` — **not** `Infrastructure`.
3. Try to add `import Infrastructure` inside `LibraryView.swift`. It still builds (the package can't see it), which is the point: the boundary is real, not a convention.

## Checkpoint

You can now build and test any feature against protocols alone — no database, no network, and no other feature in the build graph.

## The New Trap

We've made every feature depend on abstractions. But an abstraction can't run. *Someone* still has to construct the real `CoreDataLibraryRepository`, build the real movie-detail screen, and hand both to `FeatureLibrary`. Who is allowed to know about *everything* at once?

That place has a name — the **Composition Root** — and it's where Chapter 6 begins.

## A Note on the Cost

Inversion isn't free. You now maintain a protocol for every seam, plus the `AppInterfaces` module, and a `destination(for:)` call is less direct to read than `MovieDetailView(id:)`. On a small app that overhead can outweigh the benefit. The payoff scales with the number of *people* touching the code, not the number of screens — apply it where features are genuinely worked on in parallel, and leave the simple ones concrete.

---

> **Next Chapter:** [Chapter 6: The Composition Root](./06-composition-root.md)
