# Chapter 2: Extracting the Design System

A designer and a developer are looking at the same build of iTunesSearchApp. They are about to discover they do not agree on what the app actually looks like — and that neither of them can prove it.

> **Maya (design):** Quick one — the track cards in search results are using the wrong corner radius. They should be 12. They look like 8 in the build.
>
> **Sam (dev):** Let me check. Cards use the `mediumRadius` token… yeah, `mediumRadius` is 8.
>
> **Maya:** Right, but medium is 12 now. We bumped the whole radius scale three weeks ago in the design file.
>
> **Sam:** Updated where? The code still says 8. As far as the codebase knows, medium has always been 8. So which cards are wrong — just these, or every card in the app?
>
> **Maya:** …all of them should be 12. Are you saying they're all 8?
>
> **Sam:** I'm saying everything using `mediumRadius` is 8, and I can't tell you how many places that is without grepping. Could be cards, modals, the bottom sheet. And some of those might not even use the token — someone may have hardcoded an 8.
>
> **Maya:** Hardcoded? So even if you change the token, some things won't update?
>
> **Sam:** Maybe. I can't tell you which screens pull from the token and which have a magic number baked in without going screen by screen.
>
> **Maya:** This is what I keep hitting. I make a change to the system and I have no idea if it landed in the app. I see something off in a build and I can't tell if it's a bug, an old value, or a component that was never moved onto the new system.
>
> **Sam:** And from my side, I can't tell if what you're showing me in Figma is the agreed system or just your working file. Last time I chased a value, it turned out to be an experiment that got reverted.
>
> **Maya:** So neither of us actually knows what's true right now.
>
> **Sam:** Right. You have a source of truth in Figma. I have one in code. There's no place we can both look and agree "this is medium radius, this is what it renders as, and these are the components that use it."
>
> **Maya:** What I want is to point at a running screen and go "that — that's the card, that's its *real* radius, straight from the code." If it doesn't match Figma, we know exactly where the gap is.
>
> **Sam:** A live gallery of every primitive and component, rendered from the actual code the app ships. Not a screenshot, not a doc that goes stale. You'd open it, see "medium radius = 8," and know it's wrong — and I'd know it's a one-line token change that fixes every component at once, because they all pull from the same source.
>
> **Maya:** And I'd catch drift myself, instead of finding it by accident three sprints later.

Neither of them is careless. The friction is structural: there are **two separate sources of truth with no shared, rendered reference between them.** Every disagreement — *which screens? is it hardcoded? is that value even final?* — turns into a manual investigation, because no single artifact is both rendered from the real code *and* inspectable without reading it.

That artifact is what this chapter builds. The fix to Maya and Sam's standoff is the same first move we'd make for any of the monolith's pains: pull the design system out into its own module. Once it's standalone, we can run it on its own — a **catalog app** that renders every color, every radius, every component straight from the code the app actually ships. It collapses "your truth vs. my truth" into one thing both sides can point at, and it's the forcing function for our first real module boundary.

**The pain this chapter attacks: the gap between what design intends and what the code actually renders.** Maya and Sam don't have a bug; they have two sources of truth and no shared, authoritative reference between them. By the end of this chapter, they will — a standalone catalog that renders every primitive and component straight from the shipping code. It gives the design team something to *point at*: not a screenshot, not a spec that drifts, but the real component with its real radius, color, and padding. When it doesn't match Figma, the gap is obvious and the fix is one place.

That transparency is the headline win, and it lands immediately — you get it the first day the catalog exists, whether or not you ever modularize a single feature. The faster build loop comes along for the ride: because the catalog is its own module, tweaking a card's radius or a brand color no longer recompiles the whole app target (~40s a cycle) — it's a five-second loop in the catalog. But speed is the bonus. The point is that Maya and Sam can finally look at the same thing and agree on what's true.

## Why the Design System Goes First

In [Chapter 1](./01-the-monolith.md), we explored the pains of maintaining our growing monolith, **iTunesSearchApp**. The first step to unknotting this spaghetti is *not* to extract a massive feature like the "Library" right away. That usually leads to frustration because features are heavily intertwined with other parts of the app.

Instead, we start from the bottom up by identifying code that has **many incoming dependencies, but few outgoing dependencies**. In almost every app, the most prominent example of this is the **Design System** — almost every screen depends on it, while it depends on little more than Apple's UI frameworks. That property is exactly what makes it safe to pull out first, and what lets the catalog app Maya and Sam need exist at all: a module you can render on its own, independent of the app's business logic or network states.

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

## Checkpoint: One Source of Truth

Maya and Sam now have the thing they were missing: a standalone **Catalog app** that renders every primitive and component straight from the shipping code. When a value looks wrong, the gap between design and code is visible in one place — and the fix is a one-line token change that updates every component at once. Faster iteration follows: a color or radius tweak shows up in seconds, without compiling `iTunesSearchApp` at all.

| What you do | Monolith (Ch1 baseline) | After this chapter |
| --- | --- | --- |
| Confirm a component's *real* radius/color | Read code or hunt through app screens | Open Catalog — rendered from shipping code |
| Review every component | Click through real app screens | Launch Catalog, all in isolation |
| Change a color and see it | ~40s — app target recompiles | ~5s — Catalog app only |
| Misuse a domain model in UI | Compiles fine, breaks later | Won't compile — boundary enforced |

*Illustrative figures; measure your own in `code/ch02-design-system`. The headline win is the shared, authoritative reference — the ~40s → ~5s loop is what keeps it honest.*

## The Next Crack: a Tangled Data Layer

The design system was the safe first win — many screens depend on it, it depends on almost nothing. But the *core* of the app is still knotted: models, networking, and the database all live in the app target, entangled with UI and view models. You still can't test a single business rule without building everything. In the next chapter we untangle that with a **Domain** and **Infrastructure** layer.

---

> **Next Chapter:** [Chapter 3: Domain and Infrastructure Layers](./03-domain-and-infrastructure.md)
