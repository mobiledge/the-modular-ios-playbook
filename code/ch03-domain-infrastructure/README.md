# iTunesSearchApp — Chapter 3: Domain & Infrastructure

A fully working iOS app that we refactor chapter by chapter. It searches the
public **iTunes Search API** (no API key needed) for music, movies, and
audiobooks, and lets you save items to a local **Core Data** library.

This folder is the **end state of Chapter 3**. The app now sits on top of three
local Swift packages:

- **`Packages/DesignSystem`** (Ch.2) — colors, typography, and components.
- **`Packages/Domain`** (Ch.3) — pure entities (`Track`, `Movie`, `Audiobook`,
  `SavedItem`), repository protocols (`MediaSearchRepository`,
  `LibraryRepository`), and a `SearchMediaUseCase`. **Depends on nothing.**
- **`Packages/Infrastructure`** (Ch.3) — DTOs + the concrete implementations
  (`ITunesSearchRepository`, `CoreDataLibraryRepository`). **Depends on Domain.**

## Run it

You need a Mac with Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen        # one time

cd code/ch03-domain-infrastructure
xcodegen generate            # creates iTunesSearchApp.xcodeproj from project.yml
open iTunesSearchApp.xcodeproj
```

Pick a scheme — **iTunesSearchApp** for the full app, or **DesignSystemCatalog**
to browse the design system in isolation — choose a simulator, and press **Run** (⌘R).

## The dependency rule

```
        iTunesSearchApp
          │        │
          ▼        ▼
   Infrastructure  Domain ◄── (Domain depends on nothing)
          │        ▲
          └────────┘
```

Source dependencies point inward, toward the Domain. Concretely:

- The **Domain** has no `import` of SwiftUI, Core Data, or networking. It only
  declares *what* it needs via protocols.
- The **Infrastructure** implements those protocols. The iTunes JSON field names
  (`trackName`, `artworkUrl100`, …) exist only in `SearchDTOs.swift`; everything
  else speaks in clean domain entities.
- The **app** depends on both — on Domain to use entities and the use case, and
  on Infrastructure only to *construct* the concrete repositories (inline for
  now; Chapter 6 moves construction into a single composition root).

## The payoff: fast, isolated tests

`Packages/Domain/Tests/DomainTests` unit-tests `SearchMediaUseCase` with a
hand-written mock repository — no network, no database. Run them from the
`Domain` scheme (or `swift test` inside `Packages/Domain`).

## Chapter map

1. Ch.1 — the monolith (`ch01-the-monolith`).
2. Ch.2 — extract the Design System (`ch02-design-system`).
3. Ch.3 — extract Domain & Infrastructure (**this folder**).
4. Ch.4 — vertical slicing into feature modules.
5. Ch.5 — dependency inversion behind protocols.
6. Ch.6 — the composition root.

> The `.xcodeproj` is intentionally **not** committed — it's generated. Re-run
> `xcodegen generate` any time the source layout changes.
