# Chapter 3: Separating the Data Layer

In the previous chapters, we laid the groundwork by extracting our `CoreUtilities` and `DesignSystem`. These modules provided foundational pieces that didn't rely on the rest of the app.

Now, we must address one of the most critical structural issues in a monolith: **Data and State Management**. In our ShopApp monolith, the `Networking` API clients, the `Database` CoreData managers, and the core `Models` (`Product`, `CartItem`, `User`) are all mixed in with the UI and ViewModels.

## The Problem with Data in the Monolith

Why is having the data layer in the main target a problem?

1.  **Global Access:** Any View Controller can reach out and make a network request directly. This makes it impossible to track data flow and leads to "spaghetti state."
2.  **Hard to Mock:** Testing a view model that directly instantiates a concrete `APIClient` means your unit tests will hit live network endpoints. This makes tests slow, flaky, and reliant on internet access.
3.  **Lack of Reusability:** If you want to create an App Clip or a Widget, you'll need those exact same `Product` models and network calls. If they are locked inside the massive `ShopApp` target, you can't easily share them with the widget target.

## Step 1: Creating the CoreData Layer

We will create a new module, let's call it `CoreDataLayer` (or just `Data` or `Network`).

1.  **Create the Module:** Create a new target/package named `CoreDataLayer`.
2.  **Move Models:** Move `Product.swift`, `CartItem.swift`, and `User.swift` into this module.
3.  **Move Infrastructure:** Move `APIClient.swift`, `Endpoints.swift`, and `CoreDataManager.swift` into this module.
4.  **Resolve Dependencies:** Wait! `APIClient` uses our custom `Logger`. This means our new `CoreDataLayer` must depend on our `CoreUtilities` module.

```text
// In CoreDataLayer/APIClient.swift
import CoreUtilities

public class APIClient {
    public func fetchProducts() {
        Logger.log("Fetching products...")
        // ...
    }
}
```

## The New Architecture Graph

Let's look at how our dependency graph is evolving.

```text
    ┌─────────────┐
    │             │
    │   ShopApp   │
    │             │
    └─┬───────┬─┬─┘
      │       │ │
      │       │ └──────────────┐
      ▼       │                ▼
┌─────────┐   │         ┌──────────────┐
│         │   │         │              │
│ Core    │◄──┘         │ Design       │
│ Data    │             │ System       │
│ Layer   │             │              │
└────┬────┘             └──────────────┘
     │
     │
     ▼
┌─────────┐
│         │
│ Core    │
│ Util    │
│         │
└─────────┘
```

Notice the flow:
- `ShopApp` depends on `CoreDataLayer`, `CoreUtilities`, and `DesignSystem`.
- `CoreDataLayer` depends on `CoreUtilities`.
- Crucially, `CoreDataLayer` does **not** depend on `DesignSystem`. A network client shouldn't know about UI colors! This is an architectural boundary enforced by the compiler.

## The Payoff: Reusability and the Widget Target

Now, imagine management asks you to build an iOS Widget that shows the "Deal of the Day" product.

In the old monolith, you would have to duplicate the network code or somehow link the giant `ShopApp` target to the widget, which isn't feasible due to size limits.

With our new architecture, the Widget target simply imports `CoreDataLayer`.

```text
    ┌─────────────┐        ┌─────────────┐
    │             │        │             │
    │   ShopApp   │        │ ShopWidget  │
    │             │        │             │
    └──────┬──────┘        └──────┬──────┘
           │                      │
           ▼                      ▼
        ┌────────────────────────────┐
        │                            │
        │       CoreDataLayer        │
        │                            │
        └────────────────────────────┘
```

The widget gets access to the exact same `APIClient` and `Product` model, perfectly reused, without pulling in any of the heavy UI code from the main app.

Our foundational layers are solid. But the UI and features in `ShopApp` are still a massive, tangled web. In the next chapter, we will introduce "Vertical Slicing" to break apart the features themselves.

---

> **Next Chapter:** [Chapter 4: Vertical Slicing (Feature Modules)](./04-vertical-slicing.md)
