Audit and optimize CLAUDE.md files using a research-then-verify workflow.

This skill runs the same iterative review loop that was developed manually: research best practices, fact-check claims, compare against current file, propose specific edits. It saves tokens by encoding the workflow rather than re-explaining it each time.

## Arguments

- `$ARGUMENTS` — optional: "global" (default), "project", or "all" to specify which CLAUDE.md to audit.

## Workflow

### Phase 1: Snapshot current state

1. Read the target CLAUDE.md file(s):
   - Global: `~/.claude/CLAUDE.md` + any `@`-referenced files
   - Project: `.claude/CLAUDE.md` in the current repo
2. Read `~/.claude/settings.json` for hooks (compaction rules live there, not in CLAUDE.md).
3. Count lines and estimate token cost (~1.3 tokens/word for English markdown).
4. Present: line count, section inventory, estimated token cost per turn.

### Phase 2: Research (parallel agents)

Launch TWO background agents simultaneously:

**Agent 1 — Research** (subagent_type: deep-dive, run_in_background: true):
- Search for the latest CLAUDE.md best practices (WebSearch: "CLAUDE.md best practices 2026", "claude code CLAUDE.md tips", site:code.claude.com)
- Check official docs at code.claude.com for any changes to how CLAUDE.md, rules, hooks, and memory interact
- Look for novel patterns the current file doesn't use
- Report: what's new, what's changed, what the file is missing

**Agent 2 — Fact-checker** (model: sonnet, subagent_type: deep-dive, run_in_background: true):
- For each section in the current file, verify:
  1. Is this instruction correct about how Claude Code works?
  2. Is this redundant with Claude Code's built-in system prompt?
  3. Does this add value or is it noise (would removing it change behavior)?
- Check official docs for each claim
- Report: KEEP / CUT / MOVE-TO-HOOK / MOVE-TO-RULES for each section, with rationale

### Phase 3: Synthesize (after both agents return)

1. Combine findings from both agents.
2. For each proposed change, categorize:
   - **Cut**: redundant with built-in behavior or defaults
   - **Keep**: adds genuine value, changes behavior
   - **Move**: belongs in hooks (deterministic) or rules (path-scoped) instead of CLAUDE.md
   - **Add**: new pattern from research that's worth adopting
3. Present a diff-style summary of proposed changes. Don't apply yet.

### Phase 4: Apply (with approval)

1. Ask Oliver to approve/reject each proposed change.
2. Apply approved changes.
3. Report final: line count, token estimate, what changed.

## Rules

- Never auto-apply changes. Always present the diff first.
- The goal is FEWER lines, not more. Every line must pass: "would removing this cause Claude to make mistakes?"
- Don't add instructions that duplicate Claude Code's system prompt (conciseness, tool usage, etc. are already built in).
- Hooks > CLAUDE.md for anything that must happen deterministically.
- Rules files > CLAUDE.md for anything that should only load in specific contexts.
- Memory > CLAUDE.md for discovered preferences that don't need to be re-read every turn.
- Check that `@` import paths resolve correctly (relative to the importing file).
- Check that PreCompact hook in settings.json is consistent with any compaction-related CLAUDE.md content.
