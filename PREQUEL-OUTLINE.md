# The Well-Built Monolith — Outline

*A prequel to The Modular iOS Playbook. The reader finishes with a disciplined MVVM-C
monolith — the app the Playbook will pick up on its first page.*

> **Contract with the sequel:** the Playbook will be revised so its Chapter 1 monolith IS this
> book's end state (that revision is planned separately). The prequel therefore owns the road
> from "one giant view" to "well-factored MVVM-C monolith"; the Playbook owns the road from
> there to compiler-enforced modules.

## Why this book

Almost every architecture book starts at chapter three of the real story: the app already has
models, view models, a navigation layer, tidy folders. This book is chapters one and two — the
craft of getting there. It begins with everything crammed into a single SwiftUI view and, one
Single Responsibility Principle extraction at a time, arrives at a monolith with a clear
architecture: **MVVM-C** — views that only render, view models that shape data for
presentation and hold screen state, and a coordinator that owns navigation.

No SwiftPM packages, no repositories, no use cases, no dependency graphs. One target, one
team, one job per type — and the taste to stop there.

## Audience and prerequisites

You can build SwiftUI screens, manage `@State`, and call an API with async/await — but your
projects grow into one enormous view file and you can feel it. This book teaches structure,
judgment, and restraint. It does not teach Swift or SwiftUI. (If you already keep a tidy
monolith and your *team* is what's growing, start with the sequel.)

## The narrative

A solo founder builds **iTunesSearchApp** — Music search, then Podcasts — from weekend
prototype to the v1 a two-person startup ships at the start of The Modular iOS Playbook.
Every chapter opens with a real moment in that growth (a crash, a feature request, a test
that can't be written) that motivates exactly one extraction.

## The recurring device: the responsibility ledger

Chapter 1 writes down every job the one-and-only view is doing. Each chapter retires exactly
one row. The epilogue shows the empty ledger — and then asks what the compiler thinks of all
these tidy boundaries. (Answer: nothing. That's the sequel.)

| # | Job the view is doing | Retired in |
|---|---|---|
| 1 | Parse API responses | Ch 2 — Models |
| 2 | Talk to the network | Ch 3 — API client |
| 3 | Render every pixel of the screen | Ch 4 — View decomposition |
| 4 | Shape data for display + hold screen state | Ch 5 — View models |
| 5 | Prove itself correct | Ch 6 — Tests |
| 6 | Be the whole app | Ch 7 — Second feature |
| 7 | Define the app's look | Ch 8 — Design language |
| 8 | Decide where to go next | Ch 9 — Coordinator |
| 9 | Log, track, report, and flag | Ch 10 — Service contracts |
| 10 | Describe the project itself | Ch 11 — project.yml |

## Chapters

### Ch 1 — The One-File App
**Beat:** Friday night idea, Sunday night TestFlight build. A single `ContentView` holds an
inline `URLSession` call, `JSONSerialization` dictionaries, hex color literals, magic
paddings, and a `Bool` for every screen condition. The chapter is honest: *this is the right
way to start* — shipping beat structure, and structure earned nothing this weekend. Introduce
SRP as the book's lens, open the responsibility ledger, and name the destination: by the last
page, this app will have an architecture with a name. **Trap left open:** everything.

### Ch 2 — Models: Give Data a Type
**Beat:** the first crash — a missing dictionary key, found by a user. **Extraction:**
`Codable` structs (`Track`), decoded once at the boundary; optionality modeled honestly.
`Models/` appears. **Ledger:** the view stops being a parser. **Trap:** it still fetches.

### Ch 3 — Networking: One Client, One Job
**Beat:** the search endpoint needs a new parameter and the change touches view code.
**Extraction:** `iTunesAPIClient` — URL building, async/await, status codes, typed errors.
Crucially, it's fronted by a small protocol (`SearchClient`) and *handed to* whoever needs it,
not grabbed as a global — a two-line habit now that pays off enormously in Ch 6. **Ledger:**
the view stops being a networker. **Trap:** the screen is still one 400-line view.

### Ch 4 — Views That Do One Thing
**Beat:** changing the artwork corner radius breaks the search-field layout. **Extraction:**
decompose the mega-view — `MusicSearchView` owns flow; `TrackRow` and `ArtworkView` render
what they're given. Where `@State` should live; why small view structs are free. **Ledger:**
the view stops rendering every pixel. **Trap:** the view still *thinks* — formatting dates,
juggling `isLoading`/`error`/`results` booleans, deciding what "empty" means.

### Ch 5 — The View Model: Presentation Gets a Home  *(MVVM enters)*
**Beat:** track durations render as `247.0`, release dates as ISO strings, and a
three-`Bool` state tangle produces the famous "loading and error at once" screenshot.
**Extraction:** `MusicSearchViewModel` (`@Observable`) — owns a single `ViewState` enum
(`idle/loading/loaded/empty/failed`), triggers the fetch through the injected `SearchClient`,
and transforms `Track` into a display-ready row model (formatted duration, date, artwork
URL): *the view model shapes data for presentation; the view just renders it.* Views become
declarative mirrors of view-model state. **Ledger:** the view stops shaping data and holding
screen logic. **Trap:** all this logic still has never been proven correct.

### Ch 6 — Tests Without a Simulator  *(the MVVM payoff)*
**Beat:** a formatting bug ships *twice*. **Work:** the first test target. A fake
`SearchClient` returns canned tracks; unit tests drive `MusicSearchViewModel` through
loading/loaded/empty/failed and assert on formatted output — in milliseconds, no simulator.
This chapter is the argument that Ch 5 paid for itself: presentation logic became *checkable*
the moment it left the view. **Ledger:** the app can prove itself correct. **Trap:** there's
still only one feature — and a request incoming.

### Ch 7 — The Second Feature: Resist the Copy-Paste
**Beat:** users want podcasts; the founder's cursor hovers over ⌘C. **Extraction:** `Podcast`
model, `PodcastsView` + `PodcastsViewModel` + `PodcastRow`, a `RootView` `TabView`, and
feature folders that mean something: `Features/Music/`, `Features/Podcasts/` (view, view
model, and rows live together — the shape the sequel will later cut along). The judgment
chapter: *share* the client, *duplicate* the rows — rule of three vs premature abstraction.
The MVVM pattern proves itself as a template: the second view model takes an afternoon.
**Ledger:** the view stops being the whole app. **Trap:** two features disagree about what
"brand blue" is.

### Ch 8 — A Design Language, Not Scattered Constants
**Beat:** a designer friend counts three slightly different blues and four paddings.
**Extraction:** tokens (`AppColors`, `AppFont`, `AppSpacing`/`AppRadius`) and the components
built from them (`AppText`, `CardView`, `TagView`, `PrimaryButton`) into `DesignSystem/` —
one target-internal folder, deliberately named for what the sequel will one day make a
package. **Ledger:** the views stop defining the app's look. **Trap:** a track detail screen
just got approved, and nobody owns the word "navigate."

### Ch 9 — Navigation Gets an Owner: The Coordinator  *(the C arrives)*
**Beat:** tap a track → detail screen; a settings sheet; marketing wants a deep link to a
specific track "someday." `NavigationLink`s hard-coded in row views start binding screens to
each other. **Extraction:** `AppCoordinator` (`@Observable`) owns the `NavigationStack` path
and sheet state per tab; views stop navigating and start *reporting intent* ("user tapped
track") via closures the coordinator wires; destinations become an enum the coordinator maps
to screens. View models present, views render, the coordinator steers — **MVVM-C is now
complete and named.** Deep links become a ten-line switch. **Ledger:** the views stop deciding
where to go next. **Trap:** debugging is still `print("here 3")`, and the app has no idea
what users do.

### Ch 10 — Cross-Cutting Services Behind Contracts
**Beat:** the app misbehaves on a stranger's phone: no logs, no crash reports, no analytics.
**Extraction:** four small protocols — `Logger`, `CrashReporter`, `AnalyticsTracker`,
`FeatureFlagProvider` — with typed `AnalyticsEvent`/`FeatureFlag` vocabularies and console
implementations, selected by a `MOCK_SERVICES` build flag so debug builds never ship real
analytics. Services are *injected into view models and the coordinator through initializers*,
same as the `SearchClient` — which quietly concentrates all construction in one place at app
startup (the app struct + coordinator), a de facto assembly point the sequel will one day
formalize. **Ledger:** the views and view models stop owning side effects. **Trap:** the
`.xcodeproj` just caused its first merge conflict.

### Ch 11 — Project Hygiene: The Invisible Structure
**Beat:** a second developer is about to join; the founder cleans house. **Extraction:** the
project file becomes code — XcodeGen and `project.yml` (where `MOCK_SERVICES` visibly lives);
folder layout as the app's table of contents; `Utilities/` for the boring helpers. And the
book's restraint sidebar: *"you may be itching for repositories, use cases, and modules —
hold that thought."* At this size, view models talking to the client directly is a feature,
not a failure; the app doesn't yet have the problems those layers solve. **Ledger:** the last
row retires. **Trap:** none the founder can see. That's the point.

### Epilogue — The Well-Built Monolith and Its Limits
Tour the finished app: views render, view models present, the coordinator steers, services
hide behind contracts, the project file is text. The ledger is empty; a new developer finds
anything in seconds; the whole architecture fits in one diagram. Then the turn: every
boundary in this app is a *convention*. Nothing stops tomorrow's tired developer from calling
the API client inside a view or importing a feature sideways — the compiler has no opinion
about your folders. Measure the baseline scoreboard (clean build, color-change loop, test
time) and hand off: the team is about to grow from two to twenty, and making these boundaries
*rules* is the story of **The Modular iOS Playbook**.

## End state (the sequel's new starting line)

```text
iTunesSearchApp/
├── project.yml
├── Sources/
│   ├── App/            # @main, RootView (TabView), AppCoordinator
│   ├── Models/         # Track, Podcast
│   ├── Networking/     # SearchClient protocol, iTunesAPIClient
│   ├── Features/
│   │   ├── Music/      # MusicSearchView, MusicSearchViewModel, TrackDetailView, TrackRow
│   │   └── Podcasts/   # PodcastsView, PodcastsViewModel, PodcastRow
│   ├── DesignSystem/   # tokens + shared components (target-internal folder)
│   ├── Services/       # Logger/CrashReporter/AnalyticsTracker/FeatureFlagProvider + console impls
│   └── Utilities/
└── Tests/              # view-model tests with fake SearchClient
```

## Companion code (not built yet)

Mirror the Playbook's structure: one runnable folder per chapter (`prequel/ch01-one-file-app`
… `prequel/ch11-project-hygiene`), each the end state of its chapter. The defining acceptance
test of the entire two-book arc: the prequel's final folder and the revised Playbook's
`code/ch01` are the same app —

```bash
diff -r prequel/ch11-project-hygiene code/ch01-the-monolith   # → empty (after the Playbook revision)
```
