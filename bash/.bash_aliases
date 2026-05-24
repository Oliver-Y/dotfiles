# Sourced by ~/.bashrc on Ubuntu (default behavior).
# Bash equivalents of the niceties from zsh/.zshrc.

# zoxide — `z <partial>` to jump
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# fzf — keybindings and completion (apt ships them under /usr/share/doc/fzf/examples)
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  . /usr/share/doc/fzf/examples/key-bindings.bash
fi
if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
  . /usr/share/doc/fzf/examples/completion.bash
fi

# fd on Ubuntu is installed as fdfind; alias for parity
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd=fdfind
fi

# Aliases
alias gs='git status'
alias gco='git checkout'

# Yazi wrapper — cd to last directory on exit
yy() {
  local tmp
  tmp="$(mktemp -t yazi-cwd.XXXXX)"
  yazi "$@" --cwd-file="$tmp"
  local cwd
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
