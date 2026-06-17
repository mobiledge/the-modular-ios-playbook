---
title: "Chapter 1: The Monolith"
weight: 1
---

Welcome to the starting point of our journey. Before we can appreciate the benefits of a modular architecture, we must first understand the problems we are trying to solve. To do this, we'll start where almost every iOS application begins: **The Monolith**.

## What is a Monolith?

In the context of iOS development, a monolithic architecture means that all your application code—UI elements, network requests, database models, business logic, and third-party integrations—resides in a single app target. When you open Xcode and click "Create a new Xcode project," you are creating a monolith.

This isn't inherently a bad thing. In fact, for very small projects, prototypes, or indie apps maintained by a single developer, a monolithic structure is often the fastest and simplest way to build.

## Our Sample Application: iTunesSearchApp

Throughout this playbook, we will be refactoring a fictional media search application called **iTunesSearchApp**.

iTunesSearchApp has a few core features:
1.  **Music Search:** A list of music tracks fetched from the iTunes API.
2.  **Movie Details:** A screen showing details for a specific movie.
3.  **Audiobooks:** A screen displaying audiobook results.
4.  **Library:** A local database storing the user's saved items.

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
    │   ├── Movie.swift
    │   └── Audiobook.swift
    ├── Networking/
    │   ├── iTunesAPIClient.swift
    │   └── Endpoints.swift
    ├── Database/
    │   └── CoreDataManager.swift
    ├── Views/
    │   ├── Shared/
    │   │   ├── PrimaryButton.swift
    │   │   └── AppColors.swift
    │   ├── MusicSearch/
    │   │   ├── MusicSearchViewController.swift
    │   │   └── TrackCell.swift
    │   ├── MovieDetail/
    │   │   └── MovieDetailViewController.swift
    │   ├── Audiobooks/
    │   │   └── AudiobooksViewController.swift
    │   └── Library/
    │       └── LibraryViewController.swift
    └── Utilities/
        ├── DateFormatter+Extensions.swift
        └── Logger.swift
```

Everything is neatly organized into folders, but from the compiler's perspective, this is all one giant bucket of code. `MusicSearchViewController` can directly instantiate `iTunesAPIClient`, which can directly access `CoreDataManager`, which might use `AppColors`.

## The Breaking Point

As iTunesSearchApp becomes more successful, the team grows from 1 developer to 5, and then to 20. New features are added rapidly. This is when the monolith starts to show its cracks.

Here are the typical problems teams face when scaling a monolith:

1.  **Slow Build Times:** Every time you make a change to a single view, Xcode might need to recompile a significant portion of the entire application. Waiting for 3-5 minutes just to see a color change becomes normal.
2.  **Merge Conflicts:** With 20 developers working in the same target, editing the same `iTunesAPIClient.swift` or `AppColors.swift`, Git merge conflicts become a daily, painful occurrence.
3.  **Tight Coupling (The "Spaghetti" Problem):** Because there are no boundaries enforced by the compiler, it's easy for developers to take shortcuts. The `MusicSearchViewController` might directly reach into the `Library` module to check a setting, creating hidden dependencies.
4.  **Difficult to Test:** Testing the `MusicSearch` means you have to compile the entire app, including the `Audiobooks` and `Library` features, even though they aren't relevant to the test.
5.  **Scaling Teams:** It becomes difficult to assign ownership. If a bug occurs in the network layer, who owns it? If team A is working on Music and Team B is working on Movies, they are constantly stepping on each other's toes.

## The Goal of Modularization

Our goal is not to modularize for the sake of modularization. Our goal is to solve the specific problems listed above. We want to:

*   **Improve Build Times** by only compiling the code that has changed.
*   **Reduce Merge Conflicts** by isolating features so teams can work independently.
*   **Enforce Boundaries** using the compiler to prevent spaghetti code.
*   **Enable Isolated Testing** so we can run unit tests for a specific feature in seconds, not minutes.

In the next chapter, we will take our first step in decomposing the iTunesSearchApp monolith by extracting our shared utilities and design system into their own independent modules.

## Hands-On: Build the Monolith

Theory only goes so far. A working version of the iTunesSearchApp monolith lives in the [`code/iTunesSearchApp`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/iTunesSearchApp) folder of this repository. It is a single application target containing everything—models, networking, a Core Data layer, UI, and utilities—mirroring the anatomy above. The app searches the public iTunes Search API and lets you save results to a local library.

To run it, you'll need a Mac with Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen        # one time

cd code/iTunesSearchApp
xcodegen generate            # creates iTunesSearchApp.xcodeproj from project.yml
open iTunesSearchApp.xcodeproj
```

Pick an iOS Simulator and press **Run** (⌘R). You'll get a four-tab app—Music, Movies, Audiobooks, and Library—that fetches live results and persists saved items.

We use [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project from a small `project.yml` rather than committing the `.xcodeproj`. This keeps the project file out of source control, which—conveniently—eliminates one of the biggest sources of merge conflicts in a monolith. It also makes the structural changes in later chapters easy to express as plain text.

### Feel the Coupling

The sample code is deliberately tangled to make later chapters' refactors concrete. Search the sources for `MONOLITH NOTE` to find each pain point:

*   **Feature views instantiate `iTunesAPIClient.shared` directly.** There is no protocol or injection, so the Music feature cannot compile or be tested without the networking layer.
*   **List rows reach straight into `CoreDataManager.shared`.** The UI is welded to the database.
*   **`RootView` knows about every feature**, and shared tokens like `AppColors` and `Logger` are global to the whole target.

These are exactly the knots we'll untie. By the end of the playbook, each will be replaced by an explicit, compiler-enforced boundary.

---

> **Next:** [Chapter 2: Extracting the Design System]({{< relref "02-extracting-design-system" >}})
