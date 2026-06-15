# Chapter 2: Extracting the Design System

In [Chapter 1](./01-the-monolith.md), we explored the pains of maintaining our growing monolith, **iTunesSearchApp**. The first step to unknotting this spaghetti is not to extract a massive feature like the "Library" right away. That usually leads to frustration because features are heavily intertwined with other parts of the app.

Instead, we start from the bottom up by identifying code that has **many incoming dependencies, but few outgoing dependencies**. In almost every app, the most prominent example of this is the **Design System**.

## The Motivation for a Standalone Design System

Why start with the Design System? Beyond just cleaning up dependencies, extracting your design system provides a massive workflow benefit. 

When your UI components are trapped inside the main app, reviewing them requires navigating through the app's actual screens. This can be cumbersome for designers and developers alike. By moving the Design System into its own module, you unlock the ability to build a **standalone "Catalog" app**. 

This catalog app can showcase all your design primitives—fonts, colors, icons, and spacing—alongside your branded components like buttons, labels, and text fields. Designers can run this catalog app to review these components in isolation, entirely independent of the main app's business logic or network states. It gives the design team a dedicated frame of reference to ensure the components implemented in code match their design choices perfectly.

## Identifying the Base Layers

Let's look at our monolithic structure from Chapter 1 again:

```text
iTunesSearchApp/
├── Views/
│   ├── Shared/
│   │   ├── PrimaryButton.swift
│   │   └── AppColors.swift
│   ├── ...
└── ...
```

Files like `AppColors.swift` and `PrimaryButton.swift` are used by almost every screen in the application. 
- `MusicSearchViewController` uses `AppColors`.
- `LibraryViewController` uses `PrimaryButton`.

Crucially, what do these files depend on? Usually, only Apple's UI frameworks (UIKit or SwiftUI). They don't depend on `Track`, `Movie`, or any networking code. This makes them the perfect candidates for our first extraction.

## Step 1: Extracting the Design System

We will extract our UI components into a new `DesignSystem` module.

1.  **Create the Module:** Depending on your setup (Xcode Workspaces, Swift Package Manager, Tuist), create a new target or package named `DesignSystem`.
2.  **Move the Code:** Move files like `PrimaryButton.swift`, `AppColors.swift`, and other shared typography or icon assets out of the main `iTunesSearchApp` target and into `DesignSystem`.
3.  **Adjust Access Control:** Inside the main app, these components were implicitly `internal`. In a separate module, we must make the classes, structs, and their initializers `public` so `iTunesSearchApp` can use them.
    ```swift
    // In DesignSystem module
    public struct AppColors {
        public static let primaryAction = Color("BrandBlue")
    }
    ```
4.  **Import:** In `iTunesSearchApp`, add `import DesignSystem` at the top of any file that uses these UI components.

## The New Architecture

After this refactoring, our architectural graph looks like this:

```text
    ┌─────────────┐
    │             │
    │ iTunesSearch│ (Main Target)
    │     App     │
    └──────┬──────┘
           │
           ▼
    ┌──────────────┐
    │              │
    │ DesignSystem │ 
    │              │
    └──────────────┘
```

Notice the direction of the arrow. The dependency points **downwards**. `iTunesSearchApp` depends on `DesignSystem`. Importantly, `DesignSystem` does **not** depend on `iTunesSearchApp`.

## The Benefits Realized

With this extraction, we start seeing immediate benefits:

1.  **The Catalog App:** As discussed, we can now build a lightweight app target that solely imports `DesignSystem` to showcase our components, bridging the gap between design and engineering.
2.  **Faster UI Iteration:** If a developer is working purely on tweaking a button style, they can compile just the `DesignSystem` module and its catalog app, completely bypassing the compilation of the massive `iTunesSearchApp` target.
3.  **Clearer Boundaries:** It is now architecturally impossible for `AppColors.swift` to accidentally import or use a domain model like `Track.swift`. The compiler will throw an error, protecting our foundation.

We have established a solid foundation. In the next chapter, we will tackle the core of our business logic: the data layer.

---

> **Next Chapter:** [Chapter 3: Domain and Infrastructure Layers](./03-domain-and-infrastructure.md)
