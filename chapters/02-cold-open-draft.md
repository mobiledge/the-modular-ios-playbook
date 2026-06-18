<!-- DRAFT: proposed cold open for Chapter 2. Insert above the current
"**The pain this chapter attacks...**" line. The short prose bridge at the
end is meant to flow directly into the existing "Motivation for a Standalone
Design System" section (which can then be trimmed, since the dialogue now
does the motivating). -->

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
