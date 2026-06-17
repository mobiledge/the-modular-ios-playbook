# Chapter 1: The Monolith

Welcome to the starting point of our journey. Before we can appreciate the benefits of a modular architecture, we must first understand the problems we are trying to solve. To do this, we'll start where almost every iOS application begins: **The Monolith**.

## What is a Monolith?

In the context of iOS development, a monolithic architecture means that all your application code—UI elements, network requests, database models, business logic, and third-party integrations—resides in a single app target. When you open Xcode and click "Create a new Xcode project," you are creating a monolith.

This isn't inherently a bad thing. In fact, for very small projects, prototypes, or indie apps maintained by a single developer, a monolithic structure is often the fastest and simplest way to build.

## Our Sample Application: iTunesSearchApp

Throughout this playbook, we will be refactoring a fictional media search application called **iTunesSearchApp**.

iTunesSearchApp has a couple of core features:
1.  **Music Search:** A searchable list of music tracks fetched from the iTunes API.
2.  **Podcast Search:** A searchable list of podcasts fetched from the iTunes API.

Both features work the same way: type a query, hit the network, and present the results in a list. There is no local database — the app simply shows what the API returns.

### The Anatomy of the iTunesSearchApp Monolith

If we look at the Xcode project structure for our initial monolithic iTunesSearchApp, it might look something like this:

```text
iTunesSearchApp/
├── iTunesSearchApp.xcodeproj
└── iTunesSearchApp/
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    ├── Models/
    │   ├── Track.swift
    │   └── Podcast.swift
    ├── Networking/
    │   ├── iTunesAPIClient.swift
    │   └── Endpoint.swift
    ├── Views/
    │   ├── Shared/
    │   │   ├── PrimaryButton.swift
    │   │   └── AppColors.swift
    │   ├── Music/
    │   │   ├── MusicSearchViewController.swift
    │   │   └── TrackCell.swift
    │   └── Podcasts/
    │       ├── PodcastsViewController.swift
    │       └── PodcastCell.swift
    └── Utilities/
        ├── DateFormatter+Extensions.swift
        └── Logger.swift
```

Everything is neatly organized into folders, but from the compiler's perspective, this is all one giant bucket of code. `MusicSearchViewController` can directly instantiate `iTunesAPIClient`, which can freely reach for shared globals like `Logger` and `AppColors`. Nothing in the compiler stops any file from touching any other.

## The Breaking Point

As iTunesSearchApp becomes more successful, the team grows from 1 developer to 5, and then to 20. New features are added rapidly. This is when the monolith starts to show its cracks.

Here are the typical problems teams face when scaling a monolith:

1.  **Slow Build Times:** Every time you make a change to a single view, Xcode might need to recompile a significant portion of the entire application. Waiting for 3-5 minutes just to see a color change becomes normal.
2.  **Merge Conflicts:** With 20 developers working in the same target, editing the same `iTunesAPIClient.swift` or `AppColors.swift`, Git merge conflicts become a daily, painful occurrence.
3.  **Tight Coupling (The "Spaghetti" Problem):** Because there are no boundaries enforced by the compiler, it's easy for developers to take shortcuts. The `MusicSearchViewController` might directly reach into the `Podcasts` feature's code, creating hidden dependencies. Folders are only a suggestion — nothing *stops* this. Over time, every part of the app can touch every other part, and the structure you see in the file tree no longer reflects how the code actually connects. When something breaks, there is no longer an obvious place to look.
4.  **Difficult to Test:** Testing the `MusicSearch` means you have to compile the entire app, including the `Podcasts` feature, even though it isn't relevant to the test.
5.  **Scaling Teams:** It becomes difficult to assign ownership. If a bug occurs in the network layer, who owns it? If team A is working on Music and Team B is working on Podcasts, they are constantly stepping on each other's toes.

## The Goal of Modularization

Our goal is not to modularize for the sake of modularization. Our goal is to solve the specific problems listed above. Several of these benefits matter, but one stands above the rest.

### The headline win: boundaries the compiler enforces

The single most important reason to modularize is this: **you can use the compiler to enforce boundaries that prevent spaghetti code.**

In a monolith, separation of concerns is a matter of discipline. You *intend* for the network layer and the database layer to stay separate, but nothing stops a tired developer at 5pm from reaching across that line. Folders don't enforce anything. Code review catches some of it, but not reliably, and not forever.

When each concern lives in its own module, the boundary stops being a suggestion and becomes a rule. If `MusicSearch` is not *allowed* to import `Podcasts`, the code simply won't compile. The architecture you drew on the whiteboard is now the architecture you actually have, because the build system refuses to let it drift. This buys you two things that compound every single day:

*   **Separation of concerns is enforced, not hoped for.** A module can only touch what it explicitly depends on. Shortcuts and hidden dependencies become compile errors instead of landmines you discover six months later.
*   **You always know where to look.** When something breaks, the boundaries tell you where the problem can and cannot be. And before you ever open a file, the module graph gives you a true, high-level map of how the app fits together — what depends on what, and where any given piece of logic belongs.

That last point is the quiet superpower. In a healthy modular codebase, you can reason about the whole system without reading all of it, and a new engineer can understand the shape of the app on their first day.

### The other benefits

Everything else is real, but think of it as the bonus that good boundaries make possible:

*   **Improve Build Times** by only compiling the code that has changed.
*   **Reduce Merge Conflicts** by isolating features so teams can work independently.
*   **Enable Isolated Testing** so we can run unit tests for a specific feature in seconds, not minutes.

Faster builds, fewer conflicts, and isolated tests all *follow* from drawing hard lines between parts of the app. Get the boundaries right and the rest tends to come for free.

In the next chapter, we will take our first step in decomposing the iTunesSearchApp monolith by extracting our shared utilities and design system into their own independent modules.

---

> **Next Chapter:** [Chapter 2: Extracting the Design System](./02-extracting-design-system.md)
