# Chapter 5: Dependency Inversion & Interfaces

**The pain this chapter attacks: features chained to each other and to concrete data.** Vertical slicing bought us isolated features — but the moment one feature imports another to navigate, or grabs a concrete API client to fetch, we've smuggled the spaghetti back in at the module level and made the feature untestable. By the end of this chapter, a feature depends only on protocols: change a sibling and it won't recompile; test it against a mock instead of the network.

At the end of [Chapter 4](./04-vertical-slicing.md), we ran into a critical problem: **Feature-to-Feature Coupling**.

If `FeatureMusicSearch` needs to navigate to `FeatureMovieDetail`, and it imports that module directly, we have coupled two feature modules together. This defeats the purpose of vertical slicing. If we change the Detail module, the Search module must recompile.

Furthermore, we might have a similar problem with our data layer. What if we want to mock the `iTunesAPIClient` during testing so we don't hit the real network? If our ViewModels directly instantiate `iTunesAPIClient()`, we cannot easily swap it out for a `MockiTunesAPIClient`.

The solution to both problems is the 'D' in SOLID: **Dependency Inversion**.

> **Dependency Inversion Principle:** High-level modules should not import anything from low-level modules. Both should depend on abstractions (e.g., interfaces/protocols).

## Step 1: Inverting Data Dependencies

Let's look at our `FeatureLibrary`. Currently, it depends directly on the concrete `iTunesAPIClient` from `CoreDataLayer`.

```swift
// BAD: Direct coupling to concrete class
import CoreDataLayer

class LibraryViewModel {
    let apiClient = iTunesAPIClient() // Tightly coupled!
}
```

We fix this by introducing a protocol. We can place this protocol inside the `FeatureLibrary` module itself, or in a shared `FeatureInterfaces` module. For simplicity, let's say we define it within the feature that needs it.

```swift
// In FeatureLibrary
public protocol LibraryDataService {
    func fetchSavedItems() -> [Track]
}

class LibraryViewModel {
    let dataService: LibraryDataService

    // Injected via initializer
    init(dataService: LibraryDataService) {
        self.dataService = dataService
    }
}
```

Notice that `FeatureLibrary` no longer needs to import `CoreDataLayer` just to define its dependencies! It only depends on the *abstraction* (`LibraryDataService`).

## Step 2: Inverting Feature Dependencies (Navigation)

How do we solve the navigation problem between `FeatureMusicSearch` and `FeatureMovieDetail`?

We use the same principle. `FeatureMusicSearch` should not know about `MovieDetailViewController`. It should only know that *some object* exists that can handle routing to the detail screen.

```swift
// In FeatureMusicSearch
public protocol MusicSearchRouter {
    func routeToMovieDetail(for movieID: String)
}

class MusicSearchViewModel {
    let router: MusicSearchRouter

    init(router: MusicSearchRouter) {
        self.router = router
    }

    func didTapMovieSoundtrack(_ movieID: String) {
        // We delegate the navigation!
        router.routeToMovieDetail(for: movieID)
    }
}
```

## The "Interfaces" Module Strategy

In a large app, defining these protocols inside every single feature module can get messy. A common pattern is to extract these protocols into one or more `Interfaces` or `Contracts` modules.

Let's create an `iTunesSearchInterfaces` module.

1.  **Create the Module:** Create `iTunesSearchInterfaces`.
2.  **Move Protocols:** Move `LibraryDataService` and `MusicSearchRouter` into this module.

Now, our architectural graph looks like this:

```text
               ┌───────────────────┐
               │ iTunesSearchApp   │ (Main Target)
               └─┬───────────────┬─┘
                 │               │
       ┌─────────▼─┐           ┌─▼─────────┐
       │ Feature   │           │ Feature   │
       │ Music     │           │ Library   │
       │ Search    │           │           │
       └────┬──────┘           └─────┬─────┘
            │                        │
            ▼                        ▼
      ┌────────────┐           ┌───────────┐
      │            │           │           │
      │ iTunes     │◄──────────┤ Core      │
      │ Search     │           │ Data      │
      │ Interfaces │           │ Layer     │
      └────────────┘           └───────────┘
```

Notice the brilliant architectural trick here:
1.  `FeatureMusicSearch` depends on `iTunesSearchInterfaces` (to see the `Router` protocol).
2.  `CoreDataLayer` depends on `iTunesSearchInterfaces` (so `iTunesAPIClient` can explicitly conform to the `LibraryDataService` protocol).

**No feature module depends on another feature module.**
**Feature modules do not depend on the concrete Core Data Layer.**

They all depend on abstractions.

## Checkpoint: Feature Coupling, Relieved

You can now change one feature without recompiling its siblings, and test a feature's logic against a mock instead of the real network or database.

| What you do | Before this chapter | After this chapter |
| --- | --- | --- |
| Change a sibling feature's screen | Importer recompiles too | Untouched — it depends on a protocol |
| Test a feature's logic | Needs real `Infrastructure` | Inject a mock, ~0.2s |
| Trace what a feature can reach | Any imported module | Only the `Interfaces` it declares |

*Illustrative figures; verify the boundary mechanically in `code/ch05-dependency-inversion` — no `Feature*` package imports `Infrastructure` or another `Feature*`.*

## Who wires it all together?

If `LibraryViewModel` needs a `LibraryDataService`, but it doesn't instantiate `iTunesAPIClient` itself, who creates the `iTunesAPIClient` and passes it in?
If `MusicSearchViewModel` calls `router.routeToMovieDetail`, who actually performs the `navigationController.push`?

The answer is the highest-level module in our application: the one that knows about *everything*. The Composition Root. We will explore this in the next chapter.

---

> **Next Chapter:** [Chapter 6: The Composition Root](./06-composition-root.md)
