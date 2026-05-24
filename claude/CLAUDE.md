# Global Preferences

## Autonomy & Flow

- Only pause to ask when: the decision is irreversible, there's genuine ambiguity about intent, or you're about to touch shared/external state.
- When I correct you, draft the specific CLAUDE.md edit and ask to apply it — don't just mention the idea.

---

## Communication

- Typos in my messages are just typos — interpret intent, don't call them out.
- When something fails, lead with what went wrong and what you'll try next, not an apology.

---

## Workflow
- Keep responses concise — prefer code over explanation
- Run tests after making changes when a test suite exists
- Prefer editing existing files over creating new ones
- Don't add unnecessary comments, docstrings, or type annotations to unchanged code
- Don't refactor adjacent code unless it's directly relevant to the task.
- Use parallel tool calls aggressively when calls are independent.
- Use `/clear` between unrelated tasks to keep context fresh.

---

## Subagent Strategy

@subagent-strategy.md

---

## Environment
- Shell: zsh with oh-my-zsh + powerlevel10k
- Terminal: Ghostty (Tokyo Night dark)
- Multiplexer: tmux with vim-style navigation (prefix: C-s)
- Dotfiles: ~/dotfiles (git tracked)
