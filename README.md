# The Modular iOS Playbook

A practical, step-by-step guide to evolving an iOS application from a tangled monolith to a scalable, modular architecture. 

Throughout this playbook, we follow the journey of a fictional application, **iTunesSearchApp** (searching for music, movies, and audiobooks). We start with a single, massive Xcode target and progressively refactor it, extracting utilities, data layers, and eventually slicing it vertically into isolated features.

This playbook demonstrates how to solve the real scaling challenges of iOS development: slow build times, frequent merge conflicts, and "spaghetti" coupling.

📖 **Read it online: [The Modular iOS Playbook](https://mobiledge.github.io/the-modular-ios-playbook/)**

---

## Table of Contents

1. [Chapter 1: The Monolith](https://mobiledge.github.io/the-modular-ios-playbook/docs/01-the-monolith/)
2. [Chapter 2: Extracting the Design System](https://mobiledge.github.io/the-modular-ios-playbook/docs/02-extracting-design-system/)
3. [Chapter 3: Domain and Infrastructure](https://mobiledge.github.io/the-modular-ios-playbook/docs/03-domain-and-infrastructure/)
4. [Chapter 4: Vertical Slicing](https://mobiledge.github.io/the-modular-ios-playbook/docs/04-vertical-slicing/)
5. [Chapter 5: The Feature That Broke the Graph](https://mobiledge.github.io/the-modular-ios-playbook/docs/05-dependency-inversion/)
6. [Chapter 6: The Composition Root](https://mobiledge.github.io/the-modular-ios-playbook/docs/06-composition-root/)
7. [Chapter 7: The Proof: Add One, Delete One](https://mobiledge.github.io/the-modular-ios-playbook/docs/07-the-proof/)
8. [Chapter 8: Advanced Granularity — and When to Stop](https://mobiledge.github.io/the-modular-ios-playbook/docs/08-advanced-granularity/)

> The chapter source lives in [`content/docs/`](content/docs/) and is published with [Hugo](https://gohugo.io/) via GitHub Pages.