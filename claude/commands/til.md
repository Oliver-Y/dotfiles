Write a TIL (Today I Learned) note to Oliver's Obsidian knowledge vault.

## Pre-flight checks (mandatory before writing)

1. Read all existing TIL filenames and tags in `~/knowledge/TIL/` from the last 7 days.
2. Check if an existing TIL already covers this topic. If so, append a new section to it instead of creating a new file.
3. Collect the set of existing tags across all TILs for reuse.

## How to capture

1. Ask Oliver: "What's the core insight?" — get it in one sentence.
2. Ask: "What were you doing when you hit this?" — debugging, reading, reviewing, etc.
3. Write the note to `~/knowledge/TIL/` using the filename format: `YYYY-MM-DD-<slug>.md`

## Note format

```markdown
---
date: YYYY-MM-DD
tags: [relevant, topic, tags]
source: "PR/ticket/file/paper that prompted this"
related: ["[[other-note-name]]"]
---

<2-3 line summary. Jog memory at a glance.>

---

<Full detail. Diagrams, examples, tools. Read when you need to actually remember.>

---

## Review
```

## Linking rules

After writing the TIL:
1. Read all existing files in `~/knowledge/TIL/`, `~/knowledge/Synthesis/`, and `~/knowledge/Open Questions/`.
2. For any related TIL: add `[[new-note]]` to the related note's `related:` frontmatter, and add `[[related-note]]` to the new note's `related:` frontmatter.
3. For any open question that this TIL answers or advances: add a `[[new-note]]` link next to the question.
4. For any synthesis note this TIL feeds into: add `[[new-note]]` to the synthesis and link back.
5. If no related notes exist, that's fine — don't force connections.

## Style rules

- Distill knowledge, not debugging process. No "what would have saved time" narratives.
- Keep it atomic: one concept per TIL. If there are multiple, write multiple files.
- **Tags must reuse existing tags.** Before assigning tags, scan `~/knowledge/TIL/` for existing tags and reuse them. Only create a new tag if nothing fits. Tags should map to synthesis-level topics (e.g., `gpu-memory-hierarchy`, `gpu-system-ipc`, `gpu-execution-model`), not generic buzzwords like `performance` or `memory`. 2-4 tags per TIL.
- **Use the Agent tool for research.** After writing the TIL content, launch a background Agent (model: sonnet, run_in_background: true) to WebSearch/WebFetch for relevant official docs, blog posts, or diagrams. Append results as a `## References` section (URLs + brief descriptions). Don't block on this -- write the TIL first, append when the agent returns.
- Source should reference the concrete artifact — a file path, PR number, paper title, or ticket ID.
- Prefer diagrams (Mermaid) and visuals over dense text where they aid understanding.
- Don't be verbose. These are for future-Oliver to scan quickly.
