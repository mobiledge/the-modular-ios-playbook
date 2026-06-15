# Chapter 6: The Composition Root

In [Chapter 5](./05-dependency-inversion.md), we established strict boundaries. Feature modules only depend on abstractions (protocols) defined in an `Interfaces` module. Concrete implementations, like our `CoreDataLayer`'s `APIClient`, are hidden away.

But an interface cannot execute code. At some point, the app must instantiate the concrete `APIClient` and hand it to the `ProfileViewModel`. Furthermore, when a user taps a product in `FeatureProductFeed`, *someone* has to know how to instantiate the `ProductDetailViewController` to push it onto the navigation stack.

This "someone" is the **Composition Root**.

## What is a Composition Root?

The Composition Root is a unique location in an application where modules are composed together. It is the only place in the entire application that knows about *every* module.

In an iOS app, the Composition Root is almost always located in the main app target (e.g., our `ShopApp` target).

```text
               ┌─────────────┐
               │ ShopApp     │ <--- THE COMPOSITION ROOT
               │ (Main App)  │
               └─┬─────────┬─┘
                 │         │
                 ▼         ▼
             (Imports Everything)
```

Because `ShopApp` is the final executable that gets built and shipped to the App Store, it is perfectly acceptable for it to import `FeatureProfile`, `FeatureProductFeed`, `CoreDataLayer`, and `ShopAppInterfaces`.

## Step 1: Wiring up Dependencies

Let's look at how the Composition Root creates the `ProfileViewController`.

```swift
// In the Main ShopApp Target (e.g., inside a Coordinator or AppDependencyContainer)

import UIKit
import FeatureProfile     // To access ProfileViewController
import CoreDataLayer      // To access concrete APIClient
import ShopAppInterfaces  // To satisfy protocol requirements

class AppFactory {
    // 1. Instantiate the concrete dependency
    let apiClient = APIClient()

    func makeProfileScreen() -> UIViewController {
        // 2. Inject the concrete dependency into the ViewModel
        // (APIClient conforms to ProfileDataService in CoreDataLayer)
        let viewModel = ProfileViewModel(dataService: apiClient)
        
        // 3. Create the view controller
        return ProfileViewController(viewModel: viewModel)
    }
}
```

This pattern is called **Dependency Injection** (specifically, Constructor Injection). The `ProfileViewModel` never asks for an `APIClient`; it is *given* one by the Composition Root.

## Step 2: Wiring up Navigation (Routing)

Now, let's solve the routing problem. `FeatureProductFeed` needs to navigate to `ProductDetail`, but it only knows about the `ProductFeedRouter` protocol.

The Composition Root will implement this protocol. A common pattern is to use **Coordinators**.

```swift
// In the Main ShopApp Target

import UIKit
import FeatureProductFeed
import FeatureProductDetail
import ShopAppInterfaces

class MainCoordinator: ProductFeedRouter {
    var navigationController: UINavigationController
    let factory: AppFactory

    init(navigationController: UINavigationController, factory: AppFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }

    func start() {
        // We pass 'self' as the router because MainCoordinator 
        // conforms to ProductFeedRouter
        let feedVM = ProductFeedViewModel(router: self)
        let feedVC = ProductFeedViewController(viewModel: feedVM)
        navigationController.pushViewController(feedVC, animated: false)
    }

    // Implementing the protocol requirement from FeatureProductFeed
    func routeToProductDetail(for productID: String) {
        // The Coordinator knows about the Detail module!
        let detailVC = factory.makeProductDetailScreen(productID: productID)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
```

## The Beauty of the Composition Root

By pushing all instantiation and routing logic to the very top of the application structure, we achieve true modularity.

-   **Plug and Play:** If we want to replace `APIClient` with a new `GraphQLClient` next year, we only change the code in *one place*: the `AppFactory` in the Composition Root. The feature modules do not change.
-   **A/B Testing:** The Composition Root can easily decide to inject `FeatureProductDetailV1` for 50% of users and `FeatureProductDetailV2` for the other 50%.
-   **Demo Apps:** Remember the Preview Apps from Chapter 4? A Demo App is simply a *miniature Composition Root*. It injects mock data services instead of the real `APIClient`.

For many teams, reaching this level of modularity is enough. However, for massive applications (hundreds of developers), even feature modules can become too large. In our final chapter, we will look at how to decompose features into micro-features.

---

> **Next Chapter:** [Chapter 7: Advanced Granularity & Micro-Features](./07-advanced-granularity.md)
