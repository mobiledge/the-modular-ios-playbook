# Chapter 2: Extracting Core Utilities & Design System

In [Chapter 1](./01-the-monolith.md), we explored the pains of maintaining our growing monolith, **ShopApp**. The first step to unknotting this spaghetti is not to extract a massive feature like the "Shopping Cart" right away. That usually leads to frustration because features are heavily intertwined with other parts of the app.

Instead, we start from the bottom up. We look for code that has **many incoming dependencies, but few outgoing dependencies**. In almost every app, these are your Core Utilities and your Design System.

## Identifying the Base Layers

Look at our monolithic structure from Chapter 1 again.

```text
ShopApp/
├── Views/
│   ├── Shared/
│   │   ├── PrimaryButton.swift
│   │   └── AppColors.swift
│   ├── ...
└── Utilities/
    ├── DateFormatter+Extensions.swift
    └── Logger.swift
```

These files are used by almost every other file in the application.
- `ProductFeedViewController` uses `AppColors`.
- `CartViewController` uses `PrimaryButton`.
- `APIClient` uses `Logger`.
- `ProfileViewController` uses `DateFormatter+Extensions`.

However, what do these files depend on? Usually, only Apple's frameworks (Foundation, UIKit, SwiftUI). They don't depend on the `Product`, the `CartItem`, or the `APIClient`.

This makes them the perfect candidates for our first extraction.

## Step 1: Extracting Core Utilities

Our first new module will be `CoreUtilities`.

1.  **Create the Module:** Depending on your setup (Xcode Workspaces, Swift Package Manager, Tuist), you create a new target/package named `CoreUtilities`.
2.  **Move the Code:** We move `DateFormatter+Extensions.swift` and `Logger.swift` out of the main `ShopApp` target and into `CoreUtilities`.
3.  **Adjust Access Control:** Inside `ShopApp`, everything was implicitly `internal` and accessible everywhere. Now that they are in a separate module, we must make the classes, structs, extensions, and methods `public` so `ShopApp` can see them.
    ```swift
    // In CoreUtilities module
    public final class Logger {
        public static func log(_ message: String) { ... }
    }
    ```
4.  **Import:** In `ShopApp`, wherever `Logger` is used, we must now add `import CoreUtilities`.

## Step 2: Extracting the Design System

Next, we extract our UI components into a `DesignSystem` module.

1.  **Create the Module:** Create a target/package named `DesignSystem`.
2.  **Move the Code:** Move `PrimaryButton.swift` and `AppColors.swift` into `DesignSystem`.
3.  **Adjust Access Control:** Make the necessary components `public`.
4.  **Import:** In `ShopApp`, add `import DesignSystem` wherever these UI components are used.

## The New Architecture

After this refactoring, our architectural graph looks like this:

```text
    ┌─────────────┐
    │             │
    │   ShopApp   │ (Main Target)
    │             │
    └──────┬──────┘
           │
      ┌────┴────┐
      ▼         ▼
┌─────────┐ ┌──────────────┐
│         │ │              │
│ Core    │ │ Design       │
│ Util    │ │ System       │
│         │ │              │
└─────────┘ └──────────────┘
```

Notice the direction of the arrows. Dependencies point **downwards**. `ShopApp` depends on `CoreUtilities` and `DesignSystem`. Importantly, `CoreUtilities` and `DesignSystem` do **not** depend on `ShopApp`, nor do they depend on each other (usually).

## The Benefits Realized

Even with this small extraction, we start seeing benefits:

1.  **Faster Builds (Sometimes):** If a developer is working purely on tweaking the UI in the `DesignSystem` module, they might only need to compile that specific module and its preview/test app, completely bypassing the compilation of the massive `ShopApp` target.
2.  **Code Reusability:** If our company decides to build a second app (e.g., `ShopApp for Delivery Drivers`), we can instantly reuse the `DesignSystem` and `CoreUtilities` modules without copying and pasting code.
3.  **Clearer Boundaries:** We have drawn our first line in the sand. It is now architecturally impossible for `AppColors.swift` to accidentally import or use `Product.swift`. The compiler will throw an error.

We have established a solid foundation. But the bulk of our app—the networking, the data models, the actual features—are still trapped in the monolith. In the next chapter, we will tackle the data layer.

---

> **Next Chapter:** [Chapter 3: Separating the Data Layer](./03-separating-data-layer.md)
