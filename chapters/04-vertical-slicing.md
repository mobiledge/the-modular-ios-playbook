# Chapter 4: Vertical Slicing (Feature Modules)

**The pain this chapter attacks: teams stepping on each other.** Every feature still lives in one app target, so two teams edit the same files, fight the same merge conflicts, and wait on the same multi-minute build to try a one-feature change. By the end of this chapter, a feature builds and runs on its own, and two teams can ship in parallel without touching the same target.

We have successfully extracted our horizontal layers: `CoreUtilities`, `DesignSystem`, and `CoreDataLayer`. However, if you look at the `iTunesSearchApp` main target, it is still massive. It contains the views, view models, and controllers for every single feature: Music Search, Movie Details, and Audiobooks.

This is where horizontal layering fails to scale. If Team A works on Music Search and Team B works on Audiobooks, they are still editing the same target, dealing with the same slow build times, and facing the same merge conflicts.

The solution is **Vertical Slicing**.

## What is Vertical Slicing?

Instead of grouping code by its technical function (e.g., all views together, all view models together), we group code by the **feature** it delivers to the user.

We take a single slice of functionality from the UI all the way down to its specific business logic and package it into its own module.

## Step 1: Extracting the Feature

Let's extract the Library feature into a new module called `FeatureLibrary`.

1.  **Create the Module:** Create a new target/package named `FeatureLibrary`.
2.  **Move the Code:** Move `LibraryViewController.swift` (and any associated ViewModels or specialized views) out of `iTunesSearchApp` and into `FeatureLibrary`.
3.  **Add Dependencies:** The `FeatureLibrary` module needs to display the UI (using `DesignSystem`) and fetch user data (using `CoreDataLayer`). Therefore, `FeatureLibrary` must declare dependencies on both.

```swift
// In FeatureLibrary/LibraryViewController.swift
import UIKit
import DesignSystem
import CoreDataLayer

public class LibraryViewController: UIViewController {
    let apiClient: iTunesAPIClient
    // ...
}
```

## The Power of the Preview App

Once `FeatureLibrary` is in its own module, we unlock a superpower: **The Preview App** (sometimes called a Demo App or Example App).

We can create a tiny, lightweight application target (e.g., `FeatureLibraryDemoApp`) whose sole purpose is to launch directly into the `LibraryViewController`.

Because this Demo App only compiles the `FeatureLibrary` module (and its dependencies, `CoreDataLayer` and `DesignSystem`), it compiles in seconds, not minutes. Developers can iterate on the Library UI rapidly without ever launching the main `iTunesSearchApp`.

## Extracting More Features

We repeat this process for the other major features:
- Create `FeatureMusicSearch` and move `MusicSearchViewController`.
- Create `FeatureAudiobooks` and move `AudiobooksViewController`.

Our architecture now looks significantly better:

```text
               ┌───────────────────┐
               │  iTunesSearchApp  │ (Main Target - Mostly empty now!)
               └─┬───────────────┬─┘
                 │               │
       ┌─────────▼─┐           ┌─▼─────────┐
       │ Feature   │           │ Feature   │
       │ Music     │           │ Library   │
       │ Search    │           │           │
       └────┬──────┘           └─────┬─────┘
            │                  │
            ▼                  ▼
      ┌───────────┐      ┌───────────┐
      │ Core      │      │ Design    │
      │ Data      │      │ System    │
      │ Layer     │      │           │
      └───────────┘      └───────────┘
```

*Note: Lines showing dependencies to Core Utilities are omitted for clarity, but they still exist.*

## Checkpoint: Team Collisions, Relieved

You can now build and run `FeatureLibrary` on its own via a tiny demo app, and two teams can work on two features without ever editing the same target.

| What you do | Monolith (Ch1 baseline) | After this chapter |
| --- | --- | --- |
| Build/iterate one feature | ~3m — the whole app | ~10s — `FeatureLibraryDemo` only |
| Team A + Team B on two features | Same target → merge conflicts | Separate packages → ~0 conflicts |
| Find where a feature's code lives | Scattered by technical layer | One package per feature |

*Illustrative figures; measure your own in `code/ch04-vertical-slicing`. The ~3m → ~10s feature loop is the win.*

## The Hidden Trap: Feature-to-Feature Coupling

We have solved the build time and ownership problems. But consider this scenario:

Inside the `FeatureMusicSearch`, the user taps a track to see its details. This means `MusicSearchViewController` needs to present `MovieDetailViewController` (perhaps the track is from a movie soundtrack).

If we put `MovieDetailViewController` in a `FeatureMovieDetail` module, then `FeatureMusicSearch` must `import FeatureMovieDetail`.

```swift
// In FeatureMusicSearch
import FeatureMovieDetail // <--- DANGER!

func didSelectTrack(_ track: Track) {
    if let movieID = track.associatedMovieID {
        let detailVC = MovieDetailViewController(movieID: movieID)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
```

If we allow feature modules to depend directly on other feature modules, we will quickly recreate the spaghetti monolith, just at the module level instead of the file level. A change in the Movie Detail module will force a recompilation of the Music Search module.

How do we navigate between features without importing them? We solve this using **Dependency Inversion**, which we will cover in the next chapter.

---

> **Next Chapter:** [Chapter 5: Dependency Inversion & Interfaces](./05-dependency-inversion.md)
