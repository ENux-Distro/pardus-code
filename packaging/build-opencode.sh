#!/usr/bin/env bash
#
# Build the PARDUS-branded opencode binary from the fork and place it at DEST.
#
#   packaging/build-opencode.sh [DEST]      (default: <repo>/vendor/opencode)
#
# Installs the bun toolchain if missing, clones the branded fork over HTTPS
# (so anyone can build — no SSH keys needed), runs `bun install`, compiles a
# single static binary, and copies it to DEST.
#
# Tunables (env):
#   OPENCODE_FORK      git URL of the branded fork
#                      (default https://github.com/ENux-Distro/opencode.git)
#   OPENCODE_FORK_REF  branch or tag to build (default dev)
#
set -euo pipefail

OPENCODE_FORK="${OPENCODE_FORK:-https://github.com/ENux-Distro/opencode.git}"
OPENCODE_FORK_REF="${OPENCODE_FORK_REF:-dev}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${1:-$HERE/vendor/opencode}"

say() { printf '\033[1;33m::\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; exit 1; }

# --- bun toolchain (installs to ~/.bun and adds it to PATH for this build) ---
if ! command -v bun >/dev/null 2>&1 && [ ! -x "$HOME/.bun/bin/bun" ]; then
  command -v curl >/dev/null 2>&1 || die "curl is required to install bun"
  say "Installing the bun toolchain…"
  curl -fsSL https://bun.sh/install | bash || die "bun install failed"
fi
export PATH="$HOME/.bun/bin:$PATH"
command -v bun >/dev/null 2>&1 || die "bun not found after install"

# --- node-gyp ----------------------------------------------------------
# Some of the fork's native addons (e.g. tree-sitter-powershell) run
# "node-gyp rebuild" as an npm install script. Unlike npm, bun does not
# bundle node-gyp, so `bun install` fails with "spawn node-gyp ENOENT"
# unless it's already on PATH.
if ! command -v node-gyp >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    say "Installing node-gyp (needed to build native addons)…"
    sudo apt-get update -qq && sudo apt-get install -y node-gyp
  else
    die "node-gyp is required to build native addons (e.g. tree-sitter-powershell). Install it and re-run (e.g. 'npm install -g node-gyp')."
  fi
fi

# --- clone the fork --------------------------------------------------------
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
say "Cloning opencode fork ($OPENCODE_FORK @ $OPENCODE_FORK_REF)…"
git clone --depth 1 --branch "$OPENCODE_FORK_REF" "$OPENCODE_FORK" "$work/opencode" 2>/dev/null \
  || git clone --depth 1 "$OPENCODE_FORK" "$work/opencode" \
  || die "Could not clone $OPENCODE_FORK"

# --- build -----------------------------------------------------------------
cd "$work/opencode"
say "Installing build dependencies (bun install)…"
bun install || die "bun install failed"
say "Compiling opencode (this can take a little while)…"
bun ./packages/opencode/script/build.ts --single --skip-embed-web-ui \
  || die "opencode build failed"

built="$(find packages/opencode/dist -type f -name opencode -path '*/bin/*' | head -1)"
[ -n "$built" ] || die "build produced no opencode binary"

mkdir -p "$(dirname "$DEST")"
install -m 0755 "$built" "$DEST"
say "Built PARDUS opencode → $DEST"
