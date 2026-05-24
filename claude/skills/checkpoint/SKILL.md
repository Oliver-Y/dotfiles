---
name: checkpoint
description: Summarize current session state (work done, open questions, next steps) for continuity across /clear or new sessions
---

Summarize the current session state for continuity. This is used before /clear or at the end of a work session so the next session can pick up seamlessly.

Structure your checkpoint as:

1. **What was done** — Bullet list of completed work this session. Include file paths modified.
2. **Current state** — Where things stand right now. Does it build? Do tests pass? Any uncommitted changes?
3. **Open questions** — Decisions that were deferred or ambiguities that remain.
4. **Next steps** — What should be done next, in priority order.
5. **Key context** — Anything the next session needs to know that isn't obvious from the code (e.g., "the API changed upstream but hasn't been merged yet", "this approach was tried and abandoned because X").

Save this checkpoint to a scratch file at `.claude/checkpoint.md` (ask before overwriting if one exists). Also consider whether any learnings from this session should be persisted to memory or CLAUDE.md files.
