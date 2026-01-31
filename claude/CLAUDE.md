# Global Preferences

## Model Strategy
- Use sonnet for routine code edits, file creation, and straightforward tasks
- Use opus for debugging complex issues, architecture decisions, and multi-file refactors
- Use haiku for quick lookups, simple questions, and one-off commands

## Workflow
- Keep responses concise — prefer code over explanation
- Run tests after making changes when a test suite exists
- Prefer editing existing files over creating new ones
- Don't add unnecessary comments, docstrings, or type annotations to unchanged code

## Environment
- Shell: zsh with oh-my-zsh + powerlevel10k
- Terminal: Ghostty (Tokyo Night dark)
- Multiplexer: tmux with vim-style navigation (prefix: C-s)
- Dotfiles: ~/dotfiles (git tracked)
