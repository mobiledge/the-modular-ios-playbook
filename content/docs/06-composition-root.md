---
title: "Chapter 6: The Composition Root"
weight: 6
---

In [Chapter 5]({{< relref "05-dependency-inversion" >}}), we established strict boundaries. Feature modules only depend on abstractions (protocols) defined in an `Interfaces` module. Concrete implementations, like our `CoreDataLayer`'s `APIClient`, are hidden away.

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
import FeatureLibrary          // To access LibraryViewController
import CoreDataLayer           // To access concrete iTunesAPIClient
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

For many teams, reaching this level of modularity is enough. However, for massive applications (hundreds of developers), even feature modules can become too large. In our final chapter, we will look at how to decompose features into micro-features.

## Hands-On

[`code/ch06-composition-root`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch06-composition-root) has the same module graph as Chapter 5, but the wiring moves into `Sources/App/CompositionRoot/`:

- `AppFactory` is the single type that imports every module, owns the repository instances, and builds each screen with dependencies injected (`makeMusicSearch()`, `makeLibrary()`, …).
- `AppRouter` implements `LibraryRouter` by delegating to the factory — the SwiftUI equivalent of a Coordinator.
- `RootView` becomes trivial: it just calls `factory.make…()` for each tab and knows nothing about repositories or routers.

The `FeatureLibraryDemo` target is, as the chapter notes, a miniature composition root: it injects a real repository and a stub router exactly as `AppFactory` does.

---

> **Next:** [Chapter 7: Advanced Granularity & Micro-Features]({{< relref "07-advanced-granularity" >}})
