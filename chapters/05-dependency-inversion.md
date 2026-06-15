# Chapter 5: Dependency Inversion & Interfaces

At the end of [Chapter 4](./04-vertical-slicing.md), we ran into a critical problem: **Feature-to-Feature Coupling**.

If `FeatureProductFeed` needs to navigate to `FeatureProductDetail`, and it imports that module directly, we have coupled two feature modules together. This defeats the purpose of vertical slicing. If we change the Detail module, the Feed module must recompile.

Furthermore, we might have a similar problem with our data layer. What if we want to mock the `APIClient` during testing so we don't hit the real network? If our ViewModels directly instantiate `APIClient()`, we cannot easily swap it out for a `MockAPIClient`.

The solution to both problems is the 'D' in SOLID: **Dependency Inversion**.

> **Dependency Inversion Principle:** High-level modules should not import anything from low-level modules. Both should depend on abstractions (e.g., interfaces/protocols).

## Step 1: Inverting Data Dependencies

Let's look at our `FeatureProfile`. Currently, it depends directly on the concrete `APIClient` from `CoreDataLayer`.

```swift
// BAD: Direct coupling to concrete class
import CoreDataLayer

class ProfileViewModel {
    let apiClient = APIClient() // Tightly coupled!
}
```

We fix this by introducing a protocol. We can place this protocol inside the `FeatureProfile` module itself, or in a shared `FeatureInterfaces` module. For simplicity, let's say we define it within the feature that needs it.

```swift
// In FeatureProfile
public protocol ProfileDataService {
    func fetchUserProfile() -> User
}

class ProfileViewModel {
    let dataService: ProfileDataService

    // Injected via initializer
    init(dataService: ProfileDataService) {
        self.dataService = dataService
    }
}
```

Notice that `FeatureProfile` no longer needs to import `CoreDataLayer` just to define its dependencies! It only depends on the *abstraction* (`ProfileDataService`).

## Step 2: Inverting Feature Dependencies (Navigation)

How do we solve the navigation problem between `FeatureProductFeed` and `FeatureProductDetail`?

We use the same principle. `FeatureProductFeed` should not know about `ProductDetailViewController`. It should only know that *some object* exists that can handle routing to the detail screen.

```swift
// In FeatureProductFeed
public protocol ProductFeedRouter {
    func routeToProductDetail(for productID: String)
}

class ProductFeedViewModel {
    let router: ProductFeedRouter

    init(router: ProductFeedRouter) {
        self.router = router
    }

    func didTapProduct(_ product: Product) {
        // We delegate the navigation!
        router.routeToProductDetail(for: product.id)
    }
}
```

## The "Interfaces" Module Strategy

In a large app, defining these protocols inside every single feature module can get messy. A common pattern is to extract these protocols into one or more `Interfaces` or `Contracts` modules.

Let's create a `ShopAppInterfaces` module.

1.  **Create the Module:** Create `ShopAppInterfaces`.
2.  **Move Protocols:** Move `ProfileDataService` and `ProductFeedRouter` into this module.

Now, our architectural graph looks like this:

```text
               ┌─────────────┐
               │ ShopApp     │ (Main Target)
               └─┬─────────┬─┘
                 │         │
       ┌─────────▼─┐     ┌─▼─────────┐
       │ Feature   │     │ Feature   │
       │ Product   │     │ Profile   │
       │ Feed      │     │           │
       └────┬──────┘     └─────┬─────┘
            │                  │
            ▼                  ▼
      ┌───────────┐      ┌───────────┐
      │           │      │           │
      │ ShopApp   │◄─────┤ Core      │
      │ Interfaces│      │ Data      │
      │           │      │ Layer     │
      └───────────┘      └───────────┘
```

Notice the brilliant architectural trick here:
1.  `FeatureProductFeed` depends on `ShopAppInterfaces` (to see the `Router` protocol).
2.  `CoreDataLayer` depends on `ShopAppInterfaces` (so `APIClient` can explicitly conform to the `ProfileDataService` protocol).

**No feature module depends on another feature module.**
**Feature modules do not depend on the concrete Core Data Layer.**

They all depend on abstractions.

## Who wires it all together?

If `ProfileViewModel` needs a `ProfileDataService`, but it doesn't instantiate `APIClient` itself, who creates the `APIClient` and passes it in?
If `ProductFeedViewModel` calls `router.routeToProductDetail`, who actually performs the `navigationController.push`?

The answer is the highest-level module in our application: the one that knows about *everything*. The Composition Root. We will explore this in the next chapter.

---

> **Next Chapter:** [Chapter 6: The Composition Root](./06-composition-root.md)
