---
name: trace
description: Trace a data or control flow path end-to-end through the codebase with file:line references
---

Trace a data or control flow path end-to-end through the codebase. The user will describe a starting point, an endpoint, or a behavior to trace.

Use Explore subagents to investigate call chains without polluting the main context.

Structure your trace as:

1. **Entry point** — Where the flow begins (file:line).
2. **Step-by-step path** — Each hop in the chain: function calls, message passing, RPC, file I/O, shared state. Include file:line for every hop.
3. **Transformations** — How does the data change shape at each step? Types, serialization, filtering, aggregation.
4. **Branching points** — Where does the flow fork or have conditional paths? What determines which branch is taken?
5. **Terminal point** — Where the flow ends or produces its final effect.
6. **Diagram** — ASCII diagram of the full path if it spans more than 3 hops.

If the trace crosses workspace boundaries, note where that happens.

$ARGUMENTS
