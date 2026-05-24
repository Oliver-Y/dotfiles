Review Oliver's TIL notes from the past week via interactive recall and synthesis.

This is a **learning exercise**, not a document generation task. The goal is for Oliver to actively recall, connect, and articulate what he learned. Claude guides the process, pushes back, and asks questions. The synthesis doc is the output of that conversation, not a substitute for it.

## Phase 1: Inventory

1. Read all files in `~/knowledge/TIL/` from the last 7 days (by filename date prefix).
2. If no TILs exist for the period, say so and stop.
3. Present a summary table: TIL title, date, tags. Group by tag clusters.
4. Ask Oliver: "Does this grouping make sense, or would you organize these differently?"

## Phase 2: Review Pass (interactive, one TIL at a time)

For each TIL:
1. Show only the **title and tags** (not the content).
2. **Active recall prompt:** "Without looking, what's the core insight from this one?"
3. Wait for Oliver's response.
4. Then show the TIL summary (the 2-3 line header). Compare to what Oliver said:
   - If he nailed it: confirm, move on.
   - If he missed something: "You got X but the TIL also covers Y -- does that ring a bell?"
   - If he got it wrong: "Actually the TIL says Z. What do you think went wrong in your recall?"
5. Check the `## Review` section:
   - If empty: ask Oliver to fill it in now. "What clicked? What's still fuzzy? What's missing?"
   - If filled: read it and note the feedback for synthesis.
6. Move to next TIL. Don't rush -- this is the learning step.

## Phase 3: Synthesis Conversation (interactive)

After all TILs are reviewed:

1. **Prompt for connections:** Ask Oliver to identify how the TILs relate to each other.
   - "You have N TILs on [tag cluster]. How do they connect?"
   - "What's the unifying principle across these?"
   - "If you had to explain [topic] to a new team member in 2 minutes, what would you say?"

2. **Challenge and probe:**
   - "You said X in TIL-A but Y in TIL-B -- how do those reconcile?"
   - "What would happen if [scenario]?" (test understanding, not just recall)
   - "What's the gap between what you know now and what you'd need to debug [real scenario]?"

3. **Identify open edges:**
   - "What questions came up during review that you couldn't answer?"
   - Cross-reference with `~/knowledge/Open Questions/questions.md`

4. **Ask Oliver to propose the synthesis structure** before writing anything:
   - "What sections would this synthesis doc have?"
   - "What's the title / one-line thesis?"

## Phase 4: Write the Synthesis Doc

Only after Phase 3 conversation is done:

1. Draft the synthesis based on what Oliver articulated (not what Claude would write independently).
2. Present draft to Oliver for approval before writing to `~/knowledge/Synthesis/`.
3. Use the template at `~/knowledge/.config/templates/synthesis.md`.
4. Filename: `<topic-slug>.md` -- named by topic, no date prefix. Living documents.
5. If a synthesis on the topic already exists, update it.

## Phase 5: Wrap-up

1. Update `~/knowledge/Open Questions/questions.md` -- link questions to relevant TILs.
2. **Review feedback analysis**: Surface patterns from the `## Review` blocks:
   - Which formats worked? (diagrams, tables, mini examples)
   - Which topics had gaps?
   - Save format preferences as feedback memory if pattern is clear.
3. Report stats: total TILs, tag distribution, recall accuracy (how many did Oliver nail vs miss).

## Linking rules

- Synthesis notes link to all source TILs via `[[note-name]]`.
- Update each source TIL's `related:` frontmatter to link back to the synthesis.
- Cross-link open questions to relevant TILs and synthesis notes.

## Rules

- **Never skip Phase 2.** The recall exercise is the point.
- **Never auto-generate synthesis without the conversation.** The doc reflects what Oliver said, not what Claude would write.
- Don't force connections that aren't there. 1-2 unrelated TILs is fine.
- Keep the tone direct -- these are for Oliver, not documentation.
- **Source verification is mandatory.** Before confirming or challenging any claim in a TIL, use the Agent tool (model: sonnet, run_in_background: true) to WebFetch the original source cited in the `source:` frontmatter. Compare against source material, not your own mental model. Launch these in parallel across TILs at the start of Phase 2 so results are ready by the time you discuss each TIL.
- **Use the Agent tool strategically throughout.** Use Agent with subagent_type: Explore for codebase searches (checking if patterns/files mentioned in TILs still exist). Use Agent with WebSearch/WebFetch for fetching external docs. Keep the main session focused on the interactive conversation with Oliver.
