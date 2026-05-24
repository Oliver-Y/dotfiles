---
name: explain
description: Deep explanation of a file, function, class, or module — purpose, mechanics, interfaces, design choices, and gotchas
---

Explain the provided code in depth. The user will reference a file, function, class, or module.

Structure your explanation as:

1. **Purpose** — What does this code do? One paragraph, plain language.
2. **How it works** — Walk through the key logic. Reference specific lines. Don't just restate the code — explain the *mechanics*.
3. **Key interfaces** — What does it depend on? What depends on it? Inputs, outputs, side effects.
4. **Design choices** — Why is it written this way? Check git blame if the reasoning isn't obvious from the code.
5. **Gotchas** — Non-obvious behavior, edge cases, implicit assumptions, or things that would surprise a new reader.

Use subagents for exploration if the code touches multiple files. Keep the main context clean.

$ARGUMENTS
