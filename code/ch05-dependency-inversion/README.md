# iTunesSearchApp — Chapter 5: Dependency Inversion

End state of Chapter 5. Feature modules now depend only on **abstractions**.

## What changed from Chapter 4

- New **`AppInterfaces`** package holds the `LibraryRouter` protocol (navigation
  abstraction). It depends only on `Domain`.
- Feature packages **dropped their `Infrastructure` dependency**. They depend on
  `DesignSystem` + `Domain` (and `FeatureLibrary` also on `AppInterfaces`).
- Feature views receive their dependencies via initializer injection
  (`MediaSearchRepository`, `LibraryRepository`, `LibraryRouter`) instead of
  constructing concrete types.
- The app target constructs the concretes (`ITunesSearchRepository`,
  `CoreDataLibraryRepository`) and an `AppLibraryRouter`, and injects them.

## The two inversions

1. **Data:** `MusicSearchView`, etc. no longer know the iTunes API or Core Data
   exist — they only see `MediaSearchRepository` / `LibraryRepository`.
2. **Navigation:** `FeatureLibrary` can route to a saved movie's detail screen
   without importing `FeatureMovies`. It calls `LibraryRouter.destination(for:)`;
   the app's `AppLibraryRouter` builds the actual `MovieDetailView`.

No feature module imports another feature module, and no feature module imports
`Infrastructure`.

## Run it

```bash
cd code/ch05-dependency-inversion
xcodegen generate
open iTunesSearchApp.xcodeproj
```

Schemes: **iTunesSearchApp**, **FeatureLibraryDemo** (a miniature composition
root injecting a real repo + a stub router), **DesignSystemCatalog**.

## What's left for Chapter 6

The app wires everything inline in `RootView`. Chapter 6 extracts that into a
proper **Composition Root** (`AppFactory` for building screens, `AppRouter` for
navigation).
