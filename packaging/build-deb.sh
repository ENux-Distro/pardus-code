#!/usr/bin/env bash
#
# Build a Pardus Code .deb (amd64).
#
#   packaging/build-deb.sh [VERSION]
#
# Requires the PARDUS-branded opencode binary at vendor/opencode (build it with
#   bun ./packages/opencode/script/build.ts --single --skip-embed-web-ui
# and copy dist/opencode-linux-x64/bin/opencode -> vendor/opencode).
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-${PARDUS_CODE_VERSION:-1.0.0}}"
ARCH="amd64"
PKG="pardus-code"
MAINTAINER="Emir YILDIRIM <emir73503@gmail.com>"
HOMEPAGE="https://github.com/ENux-Distro/pardus-code"

BIN="$ROOT/vendor/opencode"
[ -x "$BIN" ] || { echo "error: missing vendor/opencode (the branded binary). See header." >&2; exit 1; }

BUILD="$ROOT/build/$PKG"
rm -rf "$BUILD"
mkdir -p "$BUILD/DEBIAN" \
         "$BUILD/usr/bin" \
         "$BUILD/usr/share/$PKG/themes" \
         "$BUILD/usr/share/$PKG/libexec" \
         "$BUILD/usr/share/doc/$PKG"

# --- executables -----------------------------------------------------------
install -m 0755 "$ROOT/bin/pardus-code"      "$BUILD/usr/bin/pardus-code"
install -m 0755 "$ROOT/bin/pardus-code-pick" "$BUILD/usr/bin/pardus-code-pick"
install -m 0755 "$ROOT/bin/pardus-code-term" "$BUILD/usr/bin/pardus-code-term"

# --- shared assets ---------------------------------------------------------
for f in pardus.tmux.conf pardus.nanorc pardus.tui.json opencode.jsonc WELCOME.md; do
  install -m 0644 "$ROOT/share/$f" "$BUILD/usr/share/$PKG/$f"
done
install -m 0644 "$ROOT/share/themes/pardus.json" "$BUILD/usr/share/$PKG/themes/pardus.json"

# --- the branded opencode binary ------------------------------------------
install -m 0755 "$BIN" "$BUILD/usr/share/$PKG/libexec/opencode"

# --- docs ------------------------------------------------------------------
install -m 0644 "$ROOT/README.md" "$BUILD/usr/share/doc/$PKG/README.md"
install -m 0644 "$ROOT/packaging/copyright" "$BUILD/usr/share/doc/$PKG/copyright"

# --- control ---------------------------------------------------------------
# Installed-Size is in KiB, rounded up.
SIZE_KB="$(du -sk "$BUILD/usr" | cut -f1)"
cat > "$BUILD/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Architecture: $ARCH
Maintainer: $MAINTAINER
Installed-Size: $SIZE_KB
Depends: tmux (>= 3.2), nano (>= 5.0), fzf
Section: utils
Priority: optional
Homepage: $HOMEPAGE
Description: AI coding agent and editor, side by side in your terminal
 Pardus Code puts the opencode AI agent next to GNU nano in a single tmux
 layout, themed for Pardus Linux. A built-in, PARDUS-branded opencode talks
 to free AI models; nano edits your files right beside it. Shortcuts resize
 the panes (Ctrl-R), swap them (Ctrl-O), find or create files (Ctrl-F), and
 toggle a terminal across the bottom (Ctrl-T).
EOF

# --- build -----------------------------------------------------------------
OUT="$ROOT/${PKG}_${VERSION}_${ARCH}.deb"
if dpkg-deb --help 2>&1 | grep -q -- '--root-owner-group'; then
  dpkg-deb --root-owner-group -Zxz --build "$BUILD" "$OUT"
elif command -v fakeroot >/dev/null 2>&1; then
  fakeroot dpkg-deb -Zxz --build "$BUILD" "$OUT"
else
  dpkg-deb -Zxz --build "$BUILD" "$OUT"
fi

echo
echo "Built: $OUT"
echo "Install with:  sudo apt install $OUT      (or: sudo dpkg -i $OUT)"
