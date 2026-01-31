#!/usr/bin/env bash
set -euo pipefail

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
PACKAGES=(zsh tmux fzf zoxide git curl)
for pkg in "${PACKAGES[@]}"; do
  if ! command -v "$pkg" &>/dev/null; then
    echo "    Installing $pkg..."
    install_pkg "$pkg"
  else
    echo "    $pkg already installed"
  fi
done

# --- Ghostty ---
echo "==> Installing Ghostty..."
if ! command -v ghostty &>/dev/null && [[ ! -d "/Applications/Ghostty.app" ]]; then
  if [[ "$OS" == "Darwin" ]]; then
    install_cask ghostty
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

# --- Oh My Zsh ---
echo "==> Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "    Oh My Zsh already installed"
fi

# --- Powerlevel10k ---
echo "==> Installing Powerlevel10k..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "    Powerlevel10k already installed"
fi

# --- Zsh plugins ---
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

link_file "$DOTFILES/zsh/.zshrc"    "$HOME/.zshrc"
link_file "$DOTFILES/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/ghostty"
link_file "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

mkdir -p "$HOME/.claude"
link_file "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
link_file "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_file "$DOTFILES/claude/statusline.sh" "$HOME/.claude/statusline.sh"

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
