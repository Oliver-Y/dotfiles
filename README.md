# dotfiles

My dev environment config — zsh, tmux, and Ghostty with a Tokyo Night dark theme.

## What's included

- **zsh** — Oh My Zsh + Powerlevel10k prompt, autosuggestions, syntax highlighting, fzf, zoxide
- **tmux** — Tokyo Night theme, vim-style pane navigation, pane border labels, 50k scrollback
- **Ghostty** — GPU-accelerated terminal with Tokyo Night Night theme and MesloLGS NF font

## Setup

```bash
git clone git@github.com:Oliver-Y/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script detects your package manager (Homebrew, apt, dnf, pacman), installs all dependencies, symlinks configs, and sets up plugins. Existing files are backed up before being replaced.

## Post-install

1. Open Ghostty
2. Run `tmux new -s main`
3. If the prompt looks off, run `p10k configure`
