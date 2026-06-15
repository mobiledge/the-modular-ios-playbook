# iOS Modular Architecture: Vertical Slices & Infrastructure

A reference summary of the modular architecture pattern for a large-scale iOS app, using an **iTunes Search** app (music, movies, audiobooks) as the concrete example.

This architecture solves the scaling challenges of monolithic codebases by combining two powerful concepts:

1. **Vertical Slices (Package by Feature):** Code is grouped by business domain (Music, Movies) rather than technical layer (DataAccess, UI).
2. **Interface/Implementation Split:** Within each vertical slice, abstractions (protocols, entities) are strictly separated from concretions (network calls, third-party SDKs, concrete stores).

Cross-cutting concerns (Network, Analytics, Feature Flags) live in a foundational **Core Infrastructure** layer, ensuring third-party dependencies never leak into domain logic.

---

## Table of Contents

1. [The Evolutionary Path to Modularization](chapters/01-evolutionary-path.md)
2. [Architecture and Package Matrix](chapters/02-architecture-and-package-matrix.md)
3. [Core Infrastructure Implementation](chapters/03-core-infrastructure.md)
4. [A Vertical Slice (Music Domain)](chapters/04-vertical-slice-implementation.md)
5. [The App Module — Composition Root](chapters/05-composition-root.md)
6. [Practical Rules for the Matrix](chapters/06-practical-rules.md)