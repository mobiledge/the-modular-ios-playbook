# Chapter 7: Advanced Granularity & Micro-Features

**The pain this chapter attacks: a feature module that has itself become a monolith.** When `FeatureMusicSearch` swells with caching, animations, analytics, and view logic, even a font tweak can trigger a 30-second recompile of the entire feature. By the end of this chapter, a UI change recompiles only the UI, and logic tests run without linking a single view.

If you have successfully implemented the architecture described in chapters 1 through 6, you are in an excellent position. Your app builds faster, teams are isolated, and dependencies are managed cleanly through abstractions.

However, in very large organizations with hundreds of iOS developers and millions of lines of code, even a "Feature Module" can become a mini-monolith.

Imagine `FeatureMusicSearch` grows to contain complex caching logic, massive UI data sources, intricate animations, and analytics tracking. Modifying a label's font in this feature might still trigger a 30-second recompile of the entire module.

This is where we introduce the concept of **Micro-Features**.

## Splitting the Feature

Instead of a single `FeatureMusicSearch` module, we slice the feature horizontally *within* its vertical slice.

A common pattern (popularized by architectures like RIBs or point-free's TCA, but applicable anywhere) is to split a feature into three to four sub-modules:

1.  **MusicSearchInterface:** Contains only protocols, structs (models), and enums. It defines the public API of the feature.
2.  **MusicSearchUI:** Contains only `UIView` subclasses, SwiftUI `View` structs, and perhaps simple UI formatters. It does not know where data comes from.
3.  **MusicSearchLogic (or BusinessLogic):** Contains the ViewModels, Interactors, or Reducers. It handles state management and network requests (via injected services).
4.  **MusicSearchTesting (Optional):** Contains mock implementations of the interfaces to aid in unit testing other modules.

### The Dependency Graph of a Micro-Feature

```text
    ┌───────────────────────────────────┐
    │                                   │
    │  iTunesSearchApp (Main Target)    │
    │        (Composition Root)         │
    │                                   │
    └─────┬──────────────────────┬──────┘
          │                      │
          ▼                      ▼
  ┌───────────────┐      ┌───────────────┐
  │ MusicSearch   │      │ MusicSearch   │
  │ UI            │      │ Logic         │
  └───────┬───────┘      └───────┬───────┘
          │                      │
          ▼                      ▼
    ┌───────────────────────────────────┐
    │ MusicSearch                       │
    │ Interface                         │
    └───────────────────────────────────┘
```

Notice that `MusicSearchUI` and `MusicSearchLogic` **do not depend on each other**. They both depend only on `MusicSearchInterface`.

The `iTunesSearchApp` Composition Root is responsible for importing both `UI` and `Logic`, instantiating the view model from `Logic`, and passing it into the view controller from `UI`.

## The Extreme Benefits

Why go through this extra effort?

1.  **Lightning Fast UI Iteration:** If you change a color in `MusicSearchUI`, you only recompile the UI module. You don't recompile the logic, the caching mechanisms, or the analytics tracking. Build times for UI tweaks drop to milliseconds.
2.  **Logic Testing without UIKit:** You can run unit tests on `MusicSearchLogic` without linking `UIKit` or compiling a single view. Tests run instantly.
3.  **True Separation of Concerns:** It becomes physically impossible to put business logic inside a UI component because the UI module doesn't have access to the services required to execute that logic.

## Checkpoint: The Mini-Monolith, Relieved

You can now iterate on a feature's UI without recompiling its logic, and test its logic without compiling a single view.

| What you do | One feature module | After splitting into micro-features |
| --- | --- | --- |
| Change a color in the feature | ~30s — whole feature recompiles | <2s — `MusicSearchUI` only |
| Test the feature's logic | Links UIKit/SwiftUI | `MusicSearchLogic`, no UI linked, instant |
| Put logic in a UI file | Possible, just discouraged | Impossible — UI can't see the services |

*Illustrative; trace it in `code/ch07-advanced-granularity`, where only Music Search is split into `Interface` / `UI` / `Logic`.*

## The Last Trap Is You: When to Stop Modularizing?

The final trap in this book isn't in the code — it's the temptation to apply all seven chapters to every screen. It is entirely possible to over-engineer your architecture. Creating four modules for a screen that displays static text is a waste of time and adds unnecessary build overhead (Xcode still has to link those modules).

**The Rule of Thumb:**
Start with the vertical slicing we discussed in Chapter 4. Only split a feature into micro-features (UI/Logic/Interface) when that specific feature becomes painful to work on (e.g., slow build times, frequent merge conflicts, complex logic that needs isolated testing).

Modularization is a tool to solve human scaling problems, not an academic exercise. Scale your architecture as your team scales.

---

**Congratulations!** You've completed the Modular iOS Playbook journey, evolving a tangled monolith into a highly scalable, granular architecture.
