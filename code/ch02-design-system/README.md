# iTunesSearchApp — Playbook Sample Project

A fully working iOS app that we refactor chapter by chapter. It searches the
public **iTunes Search API** (no API key needed) for **music** and **podcasts**
and presents the results in a list. There is no local database — the app simply
shows what the API returns.

The git history tracks the playbook:

- **Chapter 1 — The Monolith:** everything lives in one application target.
  See [`content/docs/01-the-monolith.md`](../../content/docs/01-the-monolith.md).
- **Chapter 2 — Extracting the Design System:** the shared UI is pulled into a
  local Swift package, `Packages/DesignSystem`, and a standalone **Catalog**
  app target is added. See [`content/docs/02-extracting-design-system.md`](../../content/docs/02-extracting-design-system.md).

This project is the Chapter 1 monolith with the design system extracted — diff
it against [`../ch01-the-monolith`](../ch01-the-monolith) to see exactly what
this chapter changes.

## Run it

You need a Mac with Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen        # one time

cd code/ch02-design-system
xcodegen generate            # creates iTunesSearchApp.xcodeproj from project.yml
open iTunesSearchApp.xcodeproj
```

Pick a scheme — **iTunesSearchApp** for the full app, or **DesignSystemCatalog**
to browse the design system in isolation — choose a simulator, and press **Run** (⌘R).

## The DesignSystem package

`Packages/DesignSystem` is a layered, reusable design system:

- **Tokens:** `DSColors` (semantic palette), `DSFont` (primitive type scale +
  semantic styles), `DSSpacing` / `DSRadius`.
- **Components (composed from tokens):** `DSText`, `DSButton`, `DSCard`,
  `DSTag`, `DSArtwork`, `DSMediaRow`, `DSSectionHeader`.

The app and the catalog both depend on it; it depends on nothing but SwiftUI.

> The `.xcodeproj` is intentionally **not** committed — it's a generated
> artifact. Re-run `xcodegen generate` any time the source layout changes.

## How the code maps to the chapter's anatomy

The chapter shows the same SwiftUI structure as the code:

| Chapter anatomy | This project | Notes |
|---|---|---|
| `App/iTunesSearchApp.swift`, `Views/RootView.swift` | same | SwiftUI `App` + `TabView` entry point |
| `Models/Track,Podcast` | `Models/` | iTunes API response types |
| `Networking/iTunesAPIClient` | `Networking/` | `async`/`await` URLSession client |
| `Views/Shared/PrimaryButton,AppColors` | `Packages/DesignSystem/` | extracted into a Swift package in Chapter 2 (`DSButton`, `DSColors`, …) |
| `Views/Music/MusicSearchView,TrackRow` | same | search + list of music tracks |
| `Views/Podcasts/PodcastsView,PodcastRow` | same | search + list of podcasts |
| `Utilities/DateFormatter+Extensions,Logger` | `Utilities/` | |

## Where the monolith hurts (on purpose)

This code is deliberately coupled so the later refactors have something real to
fix. Search the sources for `MONOLITH NOTE` to find each spot:

- **Feature views instantiate `iTunesAPIClient.shared` directly** — no protocol,
  no injection. The Music feature can't compile or be tested without networking.
- **`RootView` knows about every feature** — there's no composition root.
- **`Logger` is global** — convenient now, a placement problem once we split
  into modules.

The design coupling (`AppColors`, shared UI) is the one this chapter removes by
extracting `DesignSystem`. The rest are addressed in later chapters:

1. Ch.2 — extract the shared UI (`AppColors` / `PrimaryButton`) into a Design System module.
2. Ch.3 — extract the Domain models and the Networking infrastructure.
3. Ch.4 — slice Music / Podcasts into feature modules.
4. Ch.5 — invert dependencies behind protocols.
5. Ch.6 — assemble everything in a Composition Root.
