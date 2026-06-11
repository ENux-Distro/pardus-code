#!/usr/bin/env bash
#
# Pardus Code uninstaller.  Mirrors install.sh.
#
#   ./uninstall.sh                 # remove from ~/.local
#   ./uninstall.sh --prefix /usr/local
#
set -euo pipefail

PREFIX="$HOME/.local"
while [ $# -gt 0 ]; do
  case "$1" in
    --prefix) PREFIX="${2:?--prefix needs a path}"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^#\s\?//'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

rm -f  "$PREFIX/bin/pardus-code" "$PREFIX/bin/pardus-code-pick" "$PREFIX/bin/pardus-code-term"
rm -rf "$PREFIX/share/pardus-code"
rm -f  "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/themes/pardus.json"

printf '\033[1;36m::\033[0m Pardus Code removed from %s\n' "$PREFIX"
printf '   (system packages tmux/nano/fzf were left installed)\n'
