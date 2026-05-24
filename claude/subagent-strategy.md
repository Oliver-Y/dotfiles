# Subagent Strategy

- Use subagents for **research and exploration** to keep the main context clean. Don't pollute the primary session with 30-file investigations.
- Use the Agent tool with `subagent_type: Explore` for read-only codebase searches (faster than general-purpose for file/grep tasks).
- For recurring specialist tasks, suggest creating custom agents in `.claude/agents/`.
- Route research/review subagents to cheaper models (Sonnet/Haiku) when the task is scoped and doesn't need heavy reasoning.
- After implementation, offer to run review subagents (safety, size, correctness) — the **"implement then audit"** pattern.
- **For TILs and external technical claims**, launch a corrector Agent (model: sonnet, run_in_background: true) to verify against official docs. Don't block on it — deliver first, surface corrections when it returns. Do NOT do this for general debugging or coding tasks.
- Subagents are read-only analysts, not parallel implementers. Keep implementation in the main session.
