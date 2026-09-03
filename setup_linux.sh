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
# Test that nvim RUNS, not just that it is on PATH: a tarball for the wrong
# architecture installs cleanly and only fails with "Exec format error".
if ! nvim --version &>/dev/null; then
  echo "==> Installing Neovim from GitHub releases..."
  NVIM_VERSION="v0.11.0"

  case "$(uname -m)" in
    x86_64)        NVIM_ARCH="x86_64" ;;
    aarch64|arm64) NVIM_ARCH="arm64" ;;
    *)
      echo "ERROR: no Neovim release build for $(uname -m). Install it manually."
      exit 1
      ;;
  esac
  NVIM_TARBALL="nvim-linux-${NVIM_ARCH}.tar.gz"

  if command -v nvim &>/dev/null; then
    echo "==> Existing nvim at $(command -v nvim) does not run — removing it."
    sudo rm -rf /usr/local/bin/nvim /usr/local/share/nvim /usr/local/lib/nvim
  fi

  # -f so a bad URL fails here instead of saving GitHub's 404 page as a tarball
  curl -fLO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TARBALL}"
  sudo tar -C /usr/local -xzf "$NVIM_TARBALL" --strip-components=1
  rm "$NVIM_TARBALL"
  echo "==> Neovim installed: $(nvim --version | head -1)"
else
  echo "==> Neovim already installed: $(nvim --version | head -1)"
fi

# ── npm global prefix ────────────────────────────────────────────────────────
# Debian's npm defaults to prefix=/usr/local, so `npm i -g` fails with EACCES
# as a normal user. Point it at ~/.local — same place the fd symlink goes — so
# global installs need no root and leave no root-owned files behind.
NPM_PREFIX="$(npm config get prefix)"
if [ "$NPM_PREFIX" != "$HOME/.local" ] && [ ! -w "$NPM_PREFIX/lib" ]; then
  echo "==> npm prefix $NPM_PREFIX is not writable — switching to ~/.local"
  npm config set prefix "$HOME/.local"
fi
mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

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
echo "  npm global binaries install to ~/.local/bin — make sure it is on PATH."
echo ""
echo "  Optional: install language runtimes if needed:"
echo "    sudo apt install golang-go    # for gopls (Debian/Ubuntu)"
echo "    sudo apt install clangd       # for C/C++ LSP"
