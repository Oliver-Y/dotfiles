#!/usr/bin/env bash
set -euo pipefail

# macOS ships bash 3.2 — if we installed bash 4+ via Homebrew, re-exec with it
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  NEW_BASH="/opt/homebrew/bin/bash"
  if [[ -x "$NEW_BASH" ]]; then
    exec "$NEW_BASH" "$0" "$@"
  fi
fi

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# --- Detect OS and package manager ---
install_pkg() {
  if command -v brew &>/dev/null; then
    brew install "$@"
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y "$@"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$@"
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$@"
  else
    echo "No supported package manager found. Install manually: $*"
    return 1
  fi
}

install_cask() {
  if command -v brew &>/dev/null; then
    brew install --cask "$@"
  else
    echo "Homebrew not available — install manually: $*"
  fi
}

echo "==> Detecting platform..."
OS="$(uname -s)"
echo "    Platform: $OS"

# --- Install Homebrew on macOS if missing ---
if [[ "$OS" == "Darwin" ]] && ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

# --- Core packages ---
echo "==> Installing core packages..."
# fd and yazi handled per-platform below
PACKAGES=(bash zsh tmux fzf zoxide git curl jq ripgrep)
for pkg in "${PACKAGES[@]}"; do
  if ! command -v "$pkg" &>/dev/null; then
    echo "    Installing $pkg..."
    install_pkg "$pkg" || echo "    WARNING: $pkg install failed, continuing"
  else
    echo "    $pkg already installed"
  fi
done

# fd: on apt it's fd-find (binary fdfind); on brew/dnf/pacman it's fd
if ! command -v fd &>/dev/null; then
  if command -v apt-get &>/dev/null; then
    echo "    Installing fd-find (apt)..."
    sudo apt-get install -y fd-find || true
    mkdir -p "$HOME/.local/bin"
    if [[ -x /usr/bin/fdfind && ! -e "$HOME/.local/bin/fd" ]]; then
      ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
      echo "    Symlinked fdfind -> ~/.local/bin/fd"
    fi
  else
    install_pkg fd || true
  fi
else
  echo "    fd already installed"
fi

# yazi: brew has it; apt/dnf/pacman generally don't — install via cargo
if ! command -v yazi &>/dev/null; then
  if command -v brew &>/dev/null; then
    install_pkg yazi || true
  else
    echo "==> Installing yazi via cargo..."
    if ! command -v cargo &>/dev/null; then
      echo "    Installing rustup (will install cargo)..."
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
      # shellcheck disable=SC1091
      source "$HOME/.cargo/env"
    fi
    cargo install --force yazi-build || echo "    WARNING: yazi cargo install failed"
    # Symlink into ~/.local/bin since that's already on PATH per .zshrc
    mkdir -p "$HOME/.local/bin"
    for bin in yazi ya; do
      if [[ -x "$HOME/.cargo/bin/$bin" && ! -e "$HOME/.local/bin/$bin" ]]; then
        ln -sf "$HOME/.cargo/bin/$bin" "$HOME/.local/bin/$bin"
      fi
    done
  fi
else
  echo "    yazi already installed"
fi

# Yazi dependencies (macOS only)
if [[ "$OS" == "Darwin" ]]; then
  echo "==> Installing yazi dependencies..."
  YAZI_DEPS=(ffmpegthumbnailer sevenzip poppler imagemagick font-symbols-only-nerd-font)
  for dep in "${YAZI_DEPS[@]}"; do
    if [[ "$dep" == font-* ]]; then
      if ! ls ~/Library/Fonts/SymbolsNerdFont* &>/dev/null 2>&1; then
        echo "    Installing $dep..."
        install_cask "$dep"
      else
        echo "    $dep already installed"
      fi
    else
      if ! command -v "$dep" &>/dev/null && ! brew list "$dep" &>/dev/null 2>&1; then
        echo "    Installing $dep..."
        install_pkg "$dep"
      else
        echo "    $dep already installed"
      fi
    fi
  done
fi

# Re-exec under modern bash if we just installed it (needed for declare -A below)
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  NEW_BASH="/opt/homebrew/bin/bash"
  if [[ -x "$NEW_BASH" ]]; then
    echo "    Re-running script with bash ${NEW_BASH}..."
    exec "$NEW_BASH" "$0" "$@"
  else
    echo "WARNING: bash 4+ required for associative arrays but not found."
    echo "         Some zsh plugins may not be installed automatically."
  fi
fi

# --- Ghostty ---
echo "==> Installing Ghostty..."
if ! command -v ghostty &>/dev/null && [[ ! -d "/Applications/Ghostty.app" ]]; then
  if [[ "$OS" == "Darwin" ]]; then
    install_cask ghostty
  elif command -v apt-get &>/dev/null; then
    # Use community-maintained .deb builds (mkasberg/ghostty-ubuntu)
    UBUNTU_VER="$(. /etc/os-release && echo "${VERSION_ID:-24.04}")"
    ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
    # Resolve latest tag via redirect (no GitHub API → no rate-limit)
    LATEST_URL="$(curl -sIL -o /dev/null -w '%{url_effective}' https://github.com/mkasberg/ghostty-ubuntu/releases/latest)"
    TAG="${LATEST_URL##*/}"
    # Tag uses dashes (e.g. "1.3.1-0-ppa2") but filename uses dot before "ppa2" — derive both
    VER_FILE="${TAG//-ppa/.ppa}"
    DEB_NAME="ghostty_${VER_FILE}_${ARCH}_${UBUNTU_VER}.deb"
    DEB_URL="https://github.com/mkasberg/ghostty-ubuntu/releases/download/${TAG}/${DEB_NAME}"
    TMPDEB="$(mktemp --suffix=.deb)"
    echo "    Downloading $DEB_URL..."
    if curl -fsSL -o "$TMPDEB" "$DEB_URL"; then
      sudo apt-get install -y "$TMPDEB" || sudo dpkg -i "$TMPDEB" || echo "    WARNING: ghostty .deb install failed"
    else
      echo "    Could not download Ghostty .deb at $DEB_URL"
    fi
    rm -f "$TMPDEB"
  else
    echo "    On Linux, install Ghostty from: https://ghostty.org/download"
    echo "    (available as .deb, Flatpak, or build from source)"
  fi
else
  echo "    Ghostty already installed"
fi

# --- Font ---
echo "==> Installing MesloLGS NF font..."
if ! fc-list 2>/dev/null | grep -qi "MesloLGS" && \
   ! ls ~/Library/Fonts/MesloLGS* &>/dev/null 2>&1; then
  if command -v brew &>/dev/null; then
    install_cask font-meslo-for-powerlevel10k
  else
    echo "    Downloading MesloLGS NF fonts..."
    FONT_DIR="${HOME}/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
    for variant in "MesloLGS NF Regular" "MesloLGS NF Bold" "MesloLGS NF Italic" "MesloLGS NF Bold Italic"; do
      curl -fsSL -o "${FONT_DIR}/${variant}.ttf" "${BASE_URL}/${variant// /%20}.ttf"
    done
    fc-cache -f "$FONT_DIR" 2>/dev/null || true
  fi
else
  echo "    MesloLGS NF already installed"
fi

# --- Oh My Zsh (skip when zsh isn't installed — bash-only setups still work) ---
if command -v zsh &>/dev/null; then
  echo "==> Installing Oh My Zsh..."
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "    Oh My Zsh already installed"
  fi
else
  echo "==> Skipping Oh My Zsh (zsh not installed)"
fi

# --- Powerlevel10k + zsh plugins (zsh-only) ---
if command -v zsh &>/dev/null && [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing Powerlevel10k..."
  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ ! -d "$P10K_DIR" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  else
    echo "    Powerlevel10k already installed"
  fi

  echo "==> Installing zsh plugins..."
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  declare -A ZSH_PLUGINS=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
    [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search"
    [fzf-zsh-plugin]="https://github.com/unixorn/fzf-zsh-plugin"
  )
  for plugin in "${!ZSH_PLUGINS[@]}"; do
    dest="$ZSH_CUSTOM/plugins/$plugin"
    if [[ ! -d "$dest" ]]; then
      echo "    Cloning $plugin..."
      git clone --depth=1 "${ZSH_PLUGINS[$plugin]}" "$dest"
    else
      echo "    $plugin already installed"
    fi
  done
fi

# --- TPM (Tmux Plugin Manager) ---
echo "==> Installing TPM..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "    TPM already installed"
fi

# --- Symlink config files ---
echo "==> Symlinking config files..."

link_file() {
  local src="$1" dst="$2"
  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="${dst}.backup.$(date +%s)"
    echo "    Backing up existing $dst -> $backup"
    mv "$dst" "$backup"
  fi
  ln -sf "$src" "$dst"
  echo "    Linked $src -> $dst"
}

if command -v zsh &>/dev/null; then
  link_file "$DOTFILES/zsh/.zshrc"    "$HOME/.zshrc"
  link_file "$DOTFILES/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
fi
link_file "$DOTFILES/bash/.bash_aliases" "$HOME/.bash_aliases"
link_file "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/ghostty"
link_file "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

mkdir -p "$HOME/.claude"
link_file "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
link_file "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_file "$DOTFILES/claude/statusline.sh" "$HOME/.claude/statusline.sh"
link_file "$DOTFILES/claude/subagent-strategy.md" "$HOME/.claude/subagent-strategy.md"

# Claude skills, agents, commands, rules, scripts — link each file individually
# so ~/.claude can still contain non-dotfiles content alongside them
for dir in skills agents commands rules scripts; do
  mkdir -p "$HOME/.claude/$dir"
  if [[ -d "$DOTFILES/claude/$dir" ]]; then
    find "$DOTFILES/claude/$dir" -type f | while read -r src; do
      rel="${src#$DOTFILES/claude/$dir/}"
      dst="$HOME/.claude/$dir/$rel"
      mkdir -p "$(dirname "$dst")"
      link_file "$src" "$dst"
    done
  fi
done

mkdir -p "$HOME/.config/yazi"
link_file "$DOTFILES/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"

# --- Install tmux plugins ---
echo "==> Installing tmux plugins via TPM..."
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || true

# --- Done ---
echo ""
echo "==> Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open Ghostty"
echo "  2. Run: tmux new -s main"
echo "  3. If the zsh prompt looks wrong, run: p10k configure"
echo ""
