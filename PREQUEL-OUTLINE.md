# The Well-Built Monolith — Outline

*A prequel to The Modular iOS Playbook.*

## Why this book

The Playbook's Chapter 1 opens on an already well-organized monolith: typed models, an
extracted API client, a tokenized design system in `Views/Shared`, cross-cutting services
behind protocols, XcodeGen. Getting to that point is itself a book's worth of craft — the
craft of building a *good* monolith. This book tells that story. It begins with everything
crammed into a single SwiftUI view and, one Single Responsibility Principle extraction at a
time, arrives **byte-for-byte at [`code/ch01-the-monolith`](code/ch01-the-monolith)** — the
exact app The Modular iOS Playbook picks up on its first page.

No modules, no packages, no architecture patterns. Just the discipline of giving every piece
of code one job, and the taste to stop there.

## Audience and prerequisites

You can build SwiftUI screens, manage `@State`, and call an API with async/await — but your
projects tend to grow into one enormous view file, and you can feel it. This book teaches
structure, judgment, and restraint. It does not teach Swift or SwiftUI.

(If your *team* is growing and you already keep a tidy monolith, you may be ready for the
sequel instead.)

## The narrative

A solo founder builds iTunesSearchApp — Music search, then Podcasts — from weekend prototype
to the v1 that a two-person startup ships at the start of The Modular iOS Playbook. Every
chapter opens with a real moment in that growth (a bug, a feature request, a merge conflict)
that motivates exactly one extraction.

## The recurring device: the responsibility ledger

Chapter 1 writes down every job the one-and-only view is currently doing:

| # | Job | Retired in |
|---|-----|-----------|
| 1 | Parse API responses | Ch 2 — Models |
| 2 | Talk to the network | Ch 3 — API client |
| 3 | Render every pixel of the screen | Ch 4 — View decomposition |
| 4 | Be the whole app (navigation/composition) | Ch 5 — RootView + features |
| 5 | Define the app's look (colors, type, spacing) | Ch 6 — Tokens & components |
| 6 | Log, track, report, and flag | Ch 7 — Service contracts |
| 7 | Describe the project itself | Ch 8 — project.yml |

Each chapter retires exactly one row. The epilogue shows the empty ledger — every job now has
one home — and then asks what the compiler thinks of all these tidy folders. (Answer: nothing.
That's the sequel.)

## Chapters

### Ch 1 — The One-File App
**Beat:** Friday night idea, Sunday night App Store build. **State:** a single `ContentView`
holding an inline `URLSession` call, `JSONSerialization` dictionaries, hex color literals, and
magic paddings. The chapter is honest: *this is the right way to start* — shipping beat
structure, and structure earned nothing this weekend. Then it introduces SRP as the book's
lens, opens the responsibility ledger, and names the itch: this view has seven jobs.
**Trap left open:** everything.

### Ch 2 — Models: Give Data a Type
**Beat:** the first crash — a missing key in a dictionary, discovered by a user.
**Extraction:** `Codable` structs (`Track`) decoded once, at the boundary; optionality modeled
honestly instead of defensively; `Sources/Models` appears. **Ledger:** the view stops being a
parser. **Trap:** the view still *fetches*.

### Ch 3 — Networking: One Client, One Job
**Beat:** the search endpoint needs an extra parameter, and the change touches view code.
**Extraction:** `iTunesAPIClient` — URL building, async/await, status codes, typed errors —
as a `.shared` singleton. Honest sidebar: a singleton is *fine* at this scale; it's the
simplest thing that works, and the day it stops being fine is a different book (wink).
**Ledger:** the view stops being a networker. **Trap:** the screen is still one 400-line view.

### Ch 4 — Views That Do One Thing
**Beat:** changing the artwork corner radius breaks the search field layout.
**Extraction:** decompose the mega-view — `MusicSearchView` owns state and flow; `TrackRow`
and `ArtworkView` just render what they're given. Where `@State` should live, passing values
down, and why small view structs cost nothing. SRP applied to UI itself. **Ledger:** the view
stops rendering every pixel. **Trap:** there's still only one screen — and a feature request
incoming.

### Ch 5 — The Second Feature: Resist the Copy-Paste
**Beat:** users want podcasts. The founder's first instinct is ⌘C on the music screen.
**Extraction:** `Podcast` model, `PodcastsView` + `PodcastRow`, a `RootView` `TabView`, and
folders that mean something: `Views/Music`, `Views/Podcasts`. The judgment chapter: *share*
the API client (one job, two callers) but *duplicate* the row views — the rule of three, and
why premature abstraction is the more expensive mistake. **Ledger:** the view stops being the
whole app. **Trap:** two screens now disagree about what "brand blue" is.

### Ch 6 — A Design Language, Not Scattered Constants
**Beat:** a designer friend looks at the app and asks why there are three slightly different
blues and four paddings. **Extraction:** tokens — `AppColors`, `AppFont` (`Typography.swift`),
`AppSpacing`/`AppRadius` (`Layout.swift`) — and the components built from them (`AppText`,
`CardView`, `TagView`, `PrimaryButton`) into `Views/Shared`. Consistency becomes a feature you
ship. This folder is, quietly, the seed of the sequel's Chapter 2 design system. **Ledger:**
the views stop defining the app's look. **Trap:** debugging is still `print("here 3")`.

### Ch 7 — Cross-Cutting Services Behind Contracts
**Beat:** the app misbehaves on a stranger's phone, and the founder realizes they have no
logs, no crash reports, and no idea which features people use. **Extraction:** four small
protocols — `Logger`, `CrashReporter`, `AnalyticsTracker`, `FeatureFlagProvider` — with typed
`AnalyticsEvent`/`FeatureFlag` vocabularies, console implementations, the `Services` facade,
and the `MOCK_SERVICES` build-configuration switch so debug builds never ship real analytics.
"Depend on what you need, not on who provides it" — SRP for side effects. **Ledger:** the
views stop owning logging/tracking. **Trap:** the `.xcodeproj` file just caused its first
merge conflict.

### Ch 8 — Project Hygiene: The Invisible Structure
**Beat:** a second developer is about to join; the founder cleans house. **Extraction:** the
project file itself becomes code — XcodeGen and `project.yml` (where `MOCK_SERVICES` visibly
lives); folder layout as the app's table of contents; `Utilities` for the boring helpers
(`DateFormatter+Extensions`). And the book's defining restraint sidebar: *"you may be itching
for MVVM — hold that thought."* At this size, logic in views is a feature, not a failure; the
app doesn't yet have the problems view models solve. **Ledger:** the last row retires.
**Trap:** none the founder can see. That's the point.

### Epilogue — The Well-Built Monolith and Its Limits
Tour the finished app — which is, byte for byte, the Playbook's
[`code/ch01-the-monolith`](code/ch01-the-monolith). Every file has one job; the ledger is
empty; a new developer can find anything in seconds. Then the turn: every boundary in this
app is a *convention*. Folders are suggestions the compiler ignores; nothing stops tomorrow's
tired developer from reaching across any line. Measure the baseline scoreboard (clean build,
color-change loop, test time) — the same numbers the sequel spends eight chapters knocking
down — and hand off: the team is about to grow from two to twenty, and that story is
**The Modular iOS Playbook, Chapter 1**.

## Companion code (not built yet)

Mirror the Playbook's structure: one runnable folder per chapter (`prequel/ch01-one-file-app`
… `prequel/ch08-project-hygiene`), each the end state of its chapter. The defining acceptance
test of the entire book is a single command:

```bash
diff -r prequel/ch08-project-hygiene code/ch01-the-monolith   # → empty
```

The prequel's last commit and the Playbook's first page are the same app.
