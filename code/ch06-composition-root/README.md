# iTunesSearchApp — Chapter 6: The Composition Root

End state of Chapter 6. The module graph is identical to Chapter 5; what changed
is that all wiring is now concentrated in one place.

## The Composition Root

`Sources/App/CompositionRoot/`:

- **`AppFactory`** — the only type that imports every module and knows every
  concrete implementation. It owns the repository instances and builds each
  feature screen with dependencies injected (`makeMusicSearch()`, `makeMovies()`,
  `makeAudiobooks()`, `makeLibrary()`).
- **`AppRouter`** — implements `LibraryRouter` by delegating to the factory; the
  iOS equivalent of a Coordinator.
- **`SavedItemDetailView`** — glue view for media types without a feature screen.

`RootView` is now trivial — it just calls `factory.make…()` for each tab and
knows nothing about repositories or routers.

## Why this matters

- **Plug-and-play:** swapping `ITunesSearchRepository` for a different client is
  a one-line change in `AppFactory.init`; no feature changes.
- **A/B testing / mocks:** the factory can decide what to inject.
- **Demo apps are mini composition roots:** `FeatureLibraryDemo` injects a real
  repository and a stub router — exactly what `AppFactory` does, in miniature.

## Run it

```bash
cd code/ch06-composition-root
xcodegen generate
open iTunesSearchApp.xcodeproj
```

Schemes: **iTunesSearchApp**, **FeatureLibraryDemo**, **DesignSystemCatalog**.

## Next

For most teams this is the destination. Chapter 7 shows how to split a single
feature into UI / Logic / Interface micro-modules when one feature grows large.
