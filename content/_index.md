---
title: "The Modular iOS Playbook"
---

# The Modular iOS Playbook

A practical, step-by-step guide to evolving an iOS application from a tangled monolith to a scalable, modular architecture.

Throughout this playbook, we follow the journey of a fictional application, **iTunesSearchApp** (searching for music, movies, and audiobooks). We start with a single, massive Xcode target and progressively refactor it, extracting utilities, data layers, and eventually slicing it vertically into isolated features.

This playbook demonstrates how to solve the real scaling challenges of iOS development: slow build times, frequent merge conflicts, and "spaghetti" coupling.

---

## Table of Contents

1. [Chapter 1: The Monolith]({{< relref "docs/01-the-monolith" >}})
2. [Chapter 2: Extracting the Design System]({{< relref "docs/02-extracting-design-system" >}})
3. [Chapter 3: Domain and Infrastructure Layers]({{< relref "docs/03-domain-and-infrastructure" >}})
4. [Chapter 4: Vertical Slicing (Feature Modules)]({{< relref "docs/04-vertical-slicing" >}})
5. [Chapter 5: Dependency Inversion & Interfaces]({{< relref "docs/05-dependency-inversion" >}})
6. [Chapter 6: The Composition Root]({{< relref "docs/06-composition-root" >}})
7. [Chapter 7: Advanced Granularity & Micro-Features]({{< relref "docs/07-advanced-granularity" >}})
