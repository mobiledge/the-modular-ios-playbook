# iTunesSearchApp — Chapter 1: The Monolith

This is the starting point for the playbook: a fully working iOS app built as a
**single application target**. Every layer — models, networking, UI, and
utilities — lives in one bucket, exactly as described in
[Chapter 1](../../content/docs/01-the-monolith.md). Later chapters progressively
break it apart (see the `ch02-design-system`, `ch03-…` folders).

The app searches the public **iTunes Search API** (no API key needed) for
**music** and **movies** and presents each as a simple, searchable list. It is
deliberately minimal: results come straight from the network and are shown to
the user — there is no persistence and nothing to save.

## Run it

You need a Mac with Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen        # one time

cd code/ch01-the-monolith
xcodegen generate            # creates iTunesSearchApp.xcodeproj from project.yml
open iTunesSearchApp.xcodeproj
```

Then pick an iOS Simulator and press **Run** (⌘R). You'll get a two-tab app —
Music and Movies — that fetches live results and lists them.

> The `.xcodeproj` is intentionally **not** committed — it's a generated
> artifact. Re-run `xcodegen generate` any time the source layout changes.

## How the code maps to the chapter's anatomy

The chapter shows a UIKit folder tree. This implementation uses the SwiftUI app
lifecycle, so a couple of files are renamed but the structure is the same:

| Chapter anatomy | This project | Notes |
|---|---|---|
| `AppDelegate` / `SceneDelegate` | `App/iTunesSearchApp.swift`, `Views/RootView.swift` | SwiftUI `App` + `TabView` replace the UIKit lifecycle |
| `Models/Track,Movie` | `Models/` | iTunes API response types |
| `Networking/iTunesAPIClient,Endpoints` | `Networking/` | `async`/`await` URLSession client |
| `Views/Shared/PrimaryButton,AppColors` | `Views/Shared/` | plus a small `ArtworkView` helper |
| `Views/Music/...ViewController,TrackCell` | `Views/Music/MusicSearchView.swift`, `TrackRow.swift` | search + list |
| `Views/Movies/...ViewController,MovieCell` | `Views/Movies/MoviesView.swift`, `MovieRow.swift` | search + list (mirrors Music) |
| `Utilities/DateFormatter+Extensions,Logger` | `Utilities/` | |

## Where the monolith hurts (on purpose)

This code is deliberately coupled so the later refactors have something real to
fix. Search the sources for `MONOLITH NOTE` to find each spot:

- **Feature views instantiate `iTunesAPIClient.shared` directly** — no protocol,
  no injection. The Music and Movies features can't compile or be tested without
  networking.
- **`RootView` knows about every feature** — there's no composition root.
- **`AppColors` / `Logger` are global** — convenient now, a placement problem
  once we split into modules.

Each of these is addressed in a later chapter:

1. Ch.2 — extract `AppColors` / `PrimaryButton` into a Design System module.
2. Ch.3 — extract the Domain models and the Networking infrastructure.
3. Ch.4 — slice Music and Movies into feature modules.
4. Ch.5 — invert dependencies behind protocols.
5. Ch.6 — assemble everything in a Composition Root.
