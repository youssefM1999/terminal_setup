#!/usr/bin/env bash
set -e

echo "==> Setting up Neovim config on Linux..."

# ── Detect package manager ───────────────────────────────────────────────────
if command -v apt &>/dev/null; then
  PKG="apt"
elif command -v dnf &>/dev/null; then
  PKG="dnf"
elif command -v pacman &>/dev/null; then
  PKG="pacman"
else
  echo "ERROR: Unsupported package manager. Install dependencies manually."
  exit 1
fi

# ── System dependencies ──────────────────────────────────────────────────────
echo "==> Installing system dependencies via $PKG..."

if [ "$PKG" = "apt" ]; then
  sudo apt update
  sudo apt install -y curl git ripgrep fd-find nodejs npm build-essential

  # fd-find installs as `fdfind` on Debian/Ubuntu — symlink to `fd`
  if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(which fdfind)" ~/.local/bin/fd
    echo "==> Symlinked fdfind -> ~/.local/bin/fd (add ~/.local/bin to PATH if needed)"
  fi

elif [ "$PKG" = "dnf" ]; then
  sudo dnf install -y curl git ripgrep fd-find nodejs npm gcc gcc-c++ make

elif [ "$PKG" = "pacman" ]; then
  sudo pacman -Sy --noconfirm curl git ripgrep fd nodejs npm base-devel
fi

# ── Neovim ───────────────────────────────────────────────────────────────────
if ! command -v nvim &>/dev/null; then
  echo "==> Installing Neovim from GitHub releases..."
  NVIM_VERSION="v0.11.0"
  curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
  sudo tar -C /usr/local -xzf nvim-linux-x86_64.tar.gz --strip-components=1
  rm nvim-linux-x86_64.tar.gz
  echo "==> Neovim installed."
else
  echo "==> Neovim already installed: $(nvim --version | head -1)"
fi

# ── tree-sitter CLI ──────────────────────────────────────────────────────────
echo "==> Installing tree-sitter CLI..."
npm i -g tree-sitter-cli

# ── SystemVerilog LSP ────────────────────────────────────────────────────────
echo "==> Installing svlangserver..."
npm i -g @imc-trading/svlangserver

# ── Symlink nvim config ──────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.config

if [ -e ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  echo "==> Backing up existing nvim config to ~/.config/nvim.bak"
  mv ~/.config/nvim ~/.config/nvim.bak
fi

if [ ! -L ~/.config/nvim ]; then
  ln -s "$SCRIPT_DIR/nvim" ~/.config/nvim
  echo "==> Symlinked $SCRIPT_DIR/nvim -> ~/.config/nvim"
else
  echo "==> Symlink already exists, skipping."
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "Done! Open nvim to finish setup — lazy.nvim will install all plugins"
echo "  and Mason will install LSP servers automatically on first launch."
echo ""
echo "  Optional: install language runtimes if needed:"
echo "    sudo apt install golang-go    # for gopls (Debian/Ubuntu)"
echo "    sudo apt install clangd       # for C/C++ LSP"
