---
name: map
description: Map the structure of a directory, module, or subsystem — files, abstractions, interfaces, and build targets
---

Map the structure of a directory, module, or subsystem. The user will point you at an area of the codebase.

Use Explore subagents to survey the area. Return a concise structural overview.

Structure your map as:

1. **Overview** — What is this module/directory responsible for? 2-3 sentences.
2. **File layout** — Tree view of key files with one-line descriptions. Skip generated files, build artifacts, and boilerplate unless relevant.
3. **Key abstractions** — The main classes, interfaces, or types that define the module's API. What are the nouns and verbs?
4. **Internal structure** — How do the pieces relate? Which files own which responsibilities? Where is the entry point?
5. **External interfaces** — What does this module export? What does it depend on from outside?
6. **Build targets** — Relevant Bazel targets for building and testing.
7. **Where to start reading** — If someone is new to this module, which 2-3 files should they read first and in what order?

$ARGUMENTS
