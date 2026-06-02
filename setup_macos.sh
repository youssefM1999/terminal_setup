#!/usr/bin/env bash
set -e

echo "==> Setting up Neovim config on macOS..."

# ── Homebrew ────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── System dependencies ──────────────────────────────────────────────────────
echo "==> Installing system dependencies..."
brew install neovim ripgrep fd node

# ── tree-sitter CLI (for Treesitter parser compilation) ─────────────────────
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
echo "✓ Done! Open nvim to finish setup — lazy.nvim will install all plugins"
echo "  and Mason will install LSP servers automatically on first launch."
echo ""
echo "  Optional: install language runtimes if needed:"
echo "    brew install go       # for gopls"
echo "    brew install llvm     # for clangd (if not using Xcode CLT)"
