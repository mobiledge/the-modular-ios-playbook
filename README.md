# The Modular iOS Playbook

A practical, step-by-step guide to evolving an iOS application from a tangled monolith to a scalable, modular architecture. 

Throughout this playbook, we follow the journey of a fictional application, **iTunesSearchApp** (searching for music, movies, and audiobooks). We start with a single, massive Xcode target and progressively refactor it, extracting utilities, data layers, and eventually slicing it vertically into isolated features.

This playbook demonstrates how to solve the real scaling challenges of iOS development: slow build times, frequent merge conflicts, and "spaghetti" coupling.

---

## Table of Contents

1. [Chapter 1: The Monolith (The Starting Point)](chapters/01-the-monolith.md)
2. [Chapter 2: Extracting the Design System](chapters/02-extracting-design-system.md)
3. [Chapter 3: Separating the Data Layer](chapters/03-separating-data-layer.md)
4. [Chapter 4: Vertical Slicing (Feature Modules)](chapters/04-vertical-slicing.md)
5. [Chapter 5: Dependency Inversion & Interfaces](chapters/05-dependency-inversion.md)
6. [Chapter 6: The Composition Root](chapters/06-composition-root.md)
7. [Chapter 7: Advanced Granularity & Micro-Features](chapters/07-advanced-granularity.md)