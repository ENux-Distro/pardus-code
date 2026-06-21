#!/usr/bin/env bash
#
# Pardus Code installer.
#
#   ./install.sh              # user install into ~/.local (no sudo)
#   ./install.sh --with-deps  # also apt-install tmux/nano/fzf if missing
#   ./install.sh --prefix /usr/local --with-deps   # system-wide (needs sudo)
#
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PREFIX="$HOME/.local"
WITH_DEPS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --with-deps) WITH_DEPS=1 ;;
    --prefix)    PREFIX="${2:?--prefix needs a path}"; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^#\s\?//'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/pardus-code"

say() { printf '\033[1;36m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# --- optional system dependencies ------------------------------------------
if [ "$WITH_DEPS" -eq 1 ]; then
  need=()
  for c in tmux nano fzf; do command -v "$c" >/dev/null 2>&1 || need+=("$c"); done
  if [ "${#need[@]}" -gt 0 ]; then
    say "Installing dependencies: ${need[*]}"
    if command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y "${need[@]}"
    else
      warn "apt not found — install these manually: ${need[*]}"
    fi
  fi
fi

# --- copy files -------------------------------------------------------------
say "Installing binaries to $BIN_DIR"
install -d "$BIN_DIR" "$SHARE_DIR"
install -m 0755 "$SRC_DIR/bin/pardus-code"      "$BIN_DIR/pardus-code"
install -m 0755 "$SRC_DIR/bin/pardus-code-pick" "$BIN_DIR/pardus-code-pick"
install -m 0755 "$SRC_DIR/bin/pardus-code-term" "$BIN_DIR/pardus-code-term"

say "Installing shared assets to $SHARE_DIR"
install -m 0644 "$SRC_DIR/share/pardus.tmux.conf" "$SHARE_DIR/pardus.tmux.conf"
install -m 0644 "$SRC_DIR/share/pardus.nanorc"    "$SHARE_DIR/pardus.nanorc"
install -m 0644 "$SRC_DIR/share/lang.sh"          "$SHARE_DIR/lang.sh"
install -m 0644 "$SRC_DIR/share/opencode.jsonc"   "$SHARE_DIR/opencode.jsonc"
install -m 0644 "$SRC_DIR/share/pardus.tui.json"  "$SHARE_DIR/pardus.tui.json"
install -m 0644 "$SRC_DIR/share/WELCOME.md"       "$SHARE_DIR/WELCOME.md"
install -m 0644 "$SRC_DIR/share/WELCOME.tr.md"    "$SHARE_DIR/WELCOME.tr.md"

# The Pardus opencode theme ships in our shared assets; the launcher copies it
# into each user's <config>/opencode/themes on first run (so this works the same
# for a per-user install and the system-wide .deb).
install -d "$SHARE_DIR/themes"
install -m 0644 "$SRC_DIR/share/themes/pardus.json" "$SHARE_DIR/themes/pardus.json"

# The PARDUS-branded opencode binary, if it was built/vendored. When present it
# is used in place of any system opencode (your global opencode stays untouched).
if [ -x "$SRC_DIR/vendor/opencode" ]; then
  say "Installing bundled PARDUS opencode binary to $SHARE_DIR/libexec"
  install -d "$SHARE_DIR/libexec"
  install -m 0755 "$SRC_DIR/vendor/opencode" "$SHARE_DIR/libexec/opencode"
else
  warn "No vendored opencode binary (vendor/opencode) — falling back to system opencode."
  warn "To bundle the branded one: build opencode (--single) and copy it to vendor/opencode."
fi

# --- sanity checks ----------------------------------------------------------
if [ ! -x "$SHARE_DIR/libexec/opencode" ] && ! command -v opencode >/dev/null 2>&1; then
  warn "No opencode found (bundled or on PATH) — get it at https://opencode.ai,"
  warn "or place a built binary at vendor/opencode and re-run this installer."
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) warn "$BIN_DIR is not on your PATH. Add to ~/.bashrc:"
     warn "  export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

say "Done. Start with:  pardus-code [directory]"
