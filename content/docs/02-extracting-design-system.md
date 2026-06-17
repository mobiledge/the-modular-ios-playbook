---
title: "Chapter 2: Extracting the Design System"
weight: 2
---

In [Chapter 1]({{< relref "01-the-monolith" >}}), we explored the pains of maintaining our growing monolith, **iTunesSearchApp**. The first step to unknotting this spaghetti is not to extract a massive feature like the "Library" right away. That usually leads to frustration because features are heavily intertwined with other parts of the app.

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

## Hands-On: Extract the DesignSystem

The [`code/ch02-design-system`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch02-design-system) project now contains a real, extracted design system as a local Swift package under [`Packages/DesignSystem`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch02-design-system/Packages/DesignSystem). (It is the Chapter 1 monolith from [`code/ch01-the-monolith`](https://github.com/mobiledge/the-modular-ios-playbook/tree/main/code/ch01-the-monolith) with the design system pulled out — diff the two folders to see exactly what this chapter changes.)

### A realistic design system, not just colors

A design system is more than a color palette. Ours is built in layers:

*   **Tokens** — the primitives. `DSColors` is a small semantic palette (brand, surfaces, text, status). `DSFont` defines a single font *design*, a fixed type *scale*, and a set of weights, then composes them into semantic styles (`largeTitle`, `headline`, `body`, …). `DSSpacing` and `DSRadius` give a consistent rhythm.
*   **Components** — built *by composing tokens*. `DSText` pairs a font with a default color. `DSButton`, `DSCard`, and `DSTag` combine color, type, and radius. The highest-level component, `DSMediaRow`, is assembled entirely from `DSArtwork` + `DSText` + spacing — so every media list in the app (Music, Audiobooks, Library) looks identical for free.

Because everything is composed from a handful of tokens, the entire app can be re-themed by editing one or two files.

### How the extraction was done

The package is wired into the project via [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```yaml
packages:
  DesignSystem:
    path: Packages/DesignSystem

targets:
  iTunesSearchApp:
    dependencies:
      - package: DesignSystem
```

Three things made this work, exactly as outlined above:

1.  The shared UI files moved out of `Sources/Views/Shared/` and into the package.
2.  Their types became `public` (along with their initializers), since the app now consumes them across a module boundary.
3.  Every feature file that uses them now starts with `import DesignSystem`.

The compiler now *enforces* the boundary: it is impossible for a design-system component to reach back into `Track`, `iTunesAPIClient`, or `CoreDataManager`.

### The payoff: a Catalog app

The project includes a second app target, **DesignSystemCatalog**, that imports *only* the design system — no models, no networking, no database. Run it to review every token and component in isolation:

```bash
cd code/ch02-design-system
xcodegen generate
open iTunesSearchApp.xcodeproj   # then choose the "DesignSystemCatalog" scheme
```

Because it depends on nothing but `DesignSystem`, it compiles almost instantly — the "faster UI iteration" benefit, made concrete.

We have established a solid foundation. In the next chapter, we will tackle the core of our business logic: the data layer.

---

> **Next:** [Chapter 3: Domain and Infrastructure Layers]({{< relref "03-domain-and-infrastructure" >}})
