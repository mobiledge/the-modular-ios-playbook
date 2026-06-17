# iTunesSearchApp — Chapter 4: Vertical Slicing

End state of Chapter 4. Each user-facing feature is now its own Swift package,
and the app target only composes them.

## Packages

- `DesignSystem` (Ch.2) — colors, typography, components, the `Date.mediumString` helper.
- `Domain` (Ch.3) — entities, repository protocols, use cases.
- `Infrastructure` (Ch.3) — concrete iTunes + Core Data implementations.
- `FeatureMusicSearch`, `FeatureMovies`, `FeatureAudiobooks`, `FeatureLibrary` (Ch.4)
  — one vertical slice each, depending on DesignSystem + Domain + Infrastructure.

The app target (`Sources/App`) is down to two files: the `@main` entry and a
`RootView` that wires the four feature views into a `TabView`.

## Run it

```bash
brew install xcodegen        # one time
cd code/ch04-vertical-slicing
xcodegen generate
open iTunesSearchApp.xcodeproj
```

Schemes: **iTunesSearchApp** (full app), **FeatureLibraryDemo** (the Library
feature in isolation — the "preview app"), **DesignSystemCatalog**.

## What this chapter demonstrates

- **Ownership & build isolation:** a team can work on `FeatureAudiobooks`
  without touching the others' code.
- **Preview apps:** `FeatureLibraryDemo` compiles only `FeatureLibrary` and its
  dependencies, so it builds in seconds. The same pattern works for any feature.

## The trap this leaves open

Features still depend on the concrete `Infrastructure` package (they construct
`ITunesSearchRepository()` / `CoreDataLibraryRepository()` inline), and there is
no clean way yet for one feature to navigate into another without importing it.
Chapter 5 inverts those dependencies; Chapter 6 adds the composition root.
