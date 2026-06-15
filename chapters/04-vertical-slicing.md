# Chapter 4: Vertical Slicing (Feature Modules)

We have successfully extracted our horizontal layers: `CoreUtilities`, `DesignSystem`, and `CoreDataLayer`. However, if you look at the `ShopApp` main target, it is still massive. It contains the views, view models, and controllers for every single feature: the Product Feed, the Cart, and the User Profile.

This is where horizontal layering fails to scale. If Team A works on the Cart and Team B works on the Profile, they are still editing the same target, dealing with the same slow build times, and facing the same merge conflicts.

The solution is **Vertical Slicing**.

## What is Vertical Slicing?

Instead of grouping code by its technical function (e.g., all views together, all view models together), we group code by the **feature** it delivers to the user.

We take a single slice of functionality from the UI all the way down to its specific business logic and package it into its own module.

## Step 1: Extracting the Feature

Let's extract the User Profile feature into a new module called `FeatureProfile`.

1.  **Create the Module:** Create a new target/package named `FeatureProfile`.
2.  **Move the Code:** Move `ProfileViewController.swift` (and any associated ViewModels or specialized views) out of `ShopApp` and into `FeatureProfile`.
3.  **Add Dependencies:** The `FeatureProfile` module needs to display the UI (using `DesignSystem`) and fetch user data (using `CoreDataLayer`). Therefore, `FeatureProfile` must declare dependencies on both.

```swift
// In FeatureProfile/ProfileViewController.swift
import UIKit
import DesignSystem
import CoreDataLayer

public class ProfileViewController: UIViewController {
    let apiClient: APIClient
    // ...
}
```

## The Power of the Preview App

Once `FeatureProfile` is in its own module, we unlock a superpower: **The Preview App** (sometimes called a Demo App or Example App).

We can create a tiny, lightweight application target (e.g., `FeatureProfileDemoApp`) whose sole purpose is to launch directly into the `ProfileViewController`.

Because this Demo App only compiles the `FeatureProfile` module (and its dependencies, `CoreDataLayer` and `DesignSystem`), it compiles in seconds, not minutes. Developers can iterate on the Profile UI rapidly without ever launching the main `ShopApp`.

## Extracting More Features

We repeat this process for the other major features:
- Create `FeatureProductFeed` and move `ProductFeedViewController`.
- Create `FeatureCart` and move `CartViewController`.

Our architecture now looks significantly better:

```text
               ┌─────────────┐
               │   ShopApp   │ (Main Target - Mostly empty now!)
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
      │ Core      │      │ Design    │
      │ Data      │      │ System    │
      │ Layer     │      │           │
      └───────────┘      └───────────┘
```

*Note: Lines showing dependencies to Core Utilities are omitted for clarity, but they still exist.*

## The Hidden Trap: Feature-to-Feature Coupling

We have solved the build time and ownership problems. But consider this scenario:

Inside the `FeatureProductFeed`, the user taps a product to see its details. This means `ProductFeedViewController` needs to present `ProductDetailViewController`.

If we put `ProductDetailViewController` in a `FeatureProductDetail` module, then `FeatureProductFeed` must `import FeatureProductDetail`.

```swift
// In FeatureProductFeed
import FeatureProductDetail // <--- DANGER!

func didSelectProduct(_ product: Product) {
    let detailVC = ProductDetailViewController(product: product)
    navigationController?.pushViewController(detailVC, animated: true)
}
```

If we allow feature modules to depend directly on other feature modules, we will quickly recreate the spaghetti monolith, just at the module level instead of the file level. A change in the Detail module will force a recompilation of the Feed module.

How do we navigate between features without importing them? We solve this using **Dependency Inversion**, which we will cover in the next chapter.

---

> **Next Chapter:** [Chapter 5: Dependency Inversion & Interfaces](./05-dependency-inversion.md)
