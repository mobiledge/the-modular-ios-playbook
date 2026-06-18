# Chapter 6: The Composition Root

**The pain this chapter attacks: a perfectly decoupled app that can't actually run.** We've hidden every concrete behind a protocol — which means *nothing* is wired, and if each feature wires its own dependencies the spaghetti creeps back. Someone has to instantiate the real client and connect the routes, in exactly one place. By the end of this chapter, swapping an implementation app-wide is a one-file change and no feature module moves.

In [Chapter 5](./05-dependency-inversion.md), we established strict boundaries. Feature modules only depend on abstractions (protocols) defined in an `Interfaces` module. Concrete implementations, like our `CoreDataLayer`'s `APIClient`, are hidden away.

But an interface cannot execute code. At some point, the app must instantiate the concrete `iTunesAPIClient` and hand it to the `LibraryViewModel`. Furthermore, when a user taps a movie soundtrack in `FeatureMusicSearch`, *someone* has to know how to instantiate the `MovieDetailViewController` to push it onto the navigation stack.

This "someone" is the **Composition Root**.

## What is a Composition Root?

The Composition Root is a unique location in an application where modules are composed together. It is the only place in the entire application that knows about *every* module.

In an iOS app, the Composition Root is almost always located in the main app target (e.g., our `iTunesSearchApp` target).

```text
               ┌───────────────────┐
               │ iTunesSearchApp   │ <--- THE COMPOSITION ROOT
               │ (Main App)        │
               └─┬─────────┬─┘
                 │         │
                 ▼         ▼
             (Imports Everything)
```

Because `iTunesSearchApp` is the final executable that gets built and shipped to the App Store, it is perfectly acceptable for it to import `FeatureLibrary`, `FeatureMusicSearch`, `CoreDataLayer`, and `iTunesSearchInterfaces`.

## Step 1: Wiring up Dependencies

Let's look at how the Composition Root creates the `LibraryViewController`.

```swift
// In the Main iTunesSearchApp Target (e.g., inside a Coordinator or AppDependencyContainer)

import UIKit
import FeatureLibrary     // To access LibraryViewController
import CoreDataLayer      // To access concrete iTunesAPIClient
import iTunesSearchInterfaces  // To satisfy protocol requirements

class AppFactory {
    // 1. Instantiate the concrete dependency
    let apiClient = iTunesAPIClient()

    func makeLibraryScreen() -> UIViewController {
        // 2. Inject the concrete dependency into the ViewModel
        // (iTunesAPIClient conforms to LibraryDataService in CoreDataLayer)
        let viewModel = LibraryViewModel(dataService: apiClient)
        
        // 3. Create the view controller
        return LibraryViewController(viewModel: viewModel)
    }
}
```

This pattern is called **Dependency Injection** (specifically, Constructor Injection). The `LibraryViewModel` never asks for an `iTunesAPIClient`; it is *given* one by the Composition Root.

## Step 2: Wiring up Navigation (Routing)

Now, let's solve the routing problem. `FeatureMusicSearch` needs to navigate to `MovieDetail`, but it only knows about the `MusicSearchRouter` protocol.

The Composition Root will implement this protocol. A common pattern is to use **Coordinators**.

```swift
// In the Main iTunesSearchApp Target

import UIKit
import FeatureMusicSearch
import FeatureMovieDetail
import iTunesSearchInterfaces

class MainCoordinator: MusicSearchRouter {
    var navigationController: UINavigationController
    let factory: AppFactory

    init(navigationController: UINavigationController, factory: AppFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }

    func start() {
        // We pass 'self' as the router because MainCoordinator 
        // conforms to MusicSearchRouter
        let searchVM = MusicSearchViewModel(router: self)
        let searchVC = MusicSearchViewController(viewModel: searchVM)
        navigationController.pushViewController(searchVC, animated: false)
    }

    // Implementing the protocol requirement from FeatureMusicSearch
    func routeToMovieDetail(for movieID: String) {
        // The Coordinator knows about the Detail module!
        let detailVC = factory.makeMovieDetailScreen(movieID: movieID)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
```

## The Beauty of the Composition Root

By pushing all instantiation and routing logic to the very top of the application structure, we achieve true modularity.

-   **Plug and Play:** If we want to replace `iTunesAPIClient` with a new `GraphQLClient` next year, we only change the code in *one place*: the `AppFactory` in the Composition Root. The feature modules do not change.
-   **A/B Testing:** The Composition Root can easily decide to inject `FeatureMovieDetailV1` for 50% of users and `FeatureMovieDetailV2` for the other 50%.
-   **Demo Apps:** Remember the Preview Apps from Chapter 4? A Demo App is simply a *miniature Composition Root*. It injects mock data services instead of the real `iTunesAPIClient`.

## Checkpoint: Scattered Wiring, Relieved

You can now swap a concrete implementation across the entire app by editing one file — the `AppFactory` — and no feature module changes at all.

| What you do | Before this chapter | After this chapter |
| --- | --- | --- |
| Replace `iTunesAPIClient` → `GraphQLClient` | Edit every call site | Edit one file; features change: 0 |
| A/B two versions of a screen | Conditionals scattered in features | One decision at the root |
| Find where the app is wired together | Spread across features | A single composition root |

*Illustrative; trace it in `code/ch06-composition-root` — `AppFactory` is the only type that imports every module.*

## The Next Crack: Features That Grow Into Monoliths

For many teams, reaching this level of modularity is enough. However, for massive applications (hundreds of developers), even a single feature module can swell into a mini-monolith — caching, animations, analytics, and logic all recompiling together on every tweak. In our final chapter, we look at how to decompose a feature into **micro-features**.

---

> **Next Chapter:** [Chapter 7: Advanced Granularity & Micro-Features](./07-advanced-granularity.md)
