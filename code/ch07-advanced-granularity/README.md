# iTunesSearchApp — Chapter 7: Advanced Granularity & Micro-Features

End state of the playbook. One feature — Music Search — is decomposed into
micro-modules to show the pattern.

## The micro-feature split

`Packages/FeatureMusicSearch` now produces three libraries:

- **`MusicSearchInterface`** — the `MusicSearchViewModeling` protocol (the
  contract). Depends only on `Domain`.
- **`MusicSearchUI`** — `MusicSearchScreen` + `TrackRow`. Pure SwiftUI, generic
  over the interface. Depends on `MusicSearchInterface` + `DesignSystem`.
- **`MusicSearchLogic`** — `MusicSearchViewModel`, conforming to the interface,
  using injected domain repositories. No SwiftUI.

`MusicSearchUI` and `MusicSearchLogic` **do not depend on each other** — only on
`MusicSearchInterface`. The composition root (`AppFactory.makeMusicSearch()`)
builds the view model from Logic and hands it to the screen from UI.

```
        iTunesSearchApp (Composition Root)
          │                 │
          ▼                 ▼
   MusicSearchUI      MusicSearchLogic
          │                 │
          └──────┬──────────┘
                 ▼
        MusicSearchInterface
```

## Why

- Change a color in `MusicSearchUI` → only the UI module recompiles.
- Unit-test `MusicSearchLogic` without linking SwiftUI.
- It is physically impossible to put business logic in a view, because the UI
  module can't see the repositories.

## When to stop

The other three features are deliberately left as single modules. Only split a
feature into micro-modules when *that* feature becomes painful to work on —
modularization solves human-scaling problems, not an academic checklist.

## Run it

```bash
cd code/ch07-advanced-granularity
xcodegen generate
open iTunesSearchApp.xcodeproj
```

Schemes: **iTunesSearchApp**, **FeatureLibraryDemo**, **DesignSystemCatalog**.
