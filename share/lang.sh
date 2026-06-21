#!/usr/bin/env bash
# Pardus Code — locale-aware UI strings.
#
# Sourced by the launcher and the Ctrl-F picker. Detects Turkish from the
# system locale (LC_ALL > LC_MESSAGES > LANG); everything else is English.
# Sets PC_LANG to "tr" or "en" and exports the PC_* / PC_TMUX_* message strings.

case "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" in
  tr | tr[_.]* | tr-* | TR | TR[_.]*) PC_LANG="tr" ;;
  *) PC_LANG="en" ;;
esac

if [ "$PC_LANG" = "tr" ]; then
  # --- launcher ---
  PC_MISSING_DEPS="Pardus Code: eksik bağımlılıklar:"
  PC_INSTALL_HINT="Bunları paketteki yükleyiciyle kurun ya da:"
  PC_AGENT_HINT="(opencode, install.sh ile birlikte gelir ya da https://opencode.ai adresinden edinin)"
  PC_MISSING_ASSET_1="Pardus Code: '%s' dosyası eksik."
  PC_MISSING_ASSET_2="install.sh betiğini yeniden çalıştırın."
  PC_NOT_A_DIR="Pardus Code: '%s' bir dizin değil."
  # --- picker (Ctrl-F) ---
  PC_PICK_PROMPT="aç / oluştur > "
  PC_PICK_HEADER="Pardus Code — süzmek için yazın ya da yeni ad yazıp Enter ile oluşturun"
  PC_PICK_NOT_STANDALONE_1="pardus-code-pick, Pardus Code içinde Ctrl-F ile çalıştırılır — tek başına"
  PC_PICK_NOT_STANDALONE_2="bir komut değildir. Pardus Code'u 'pardus-code' ile başlatın ve dosya"
  PC_PICK_NOT_STANDALONE_3="bulmak ya da oluşturmak için Ctrl-F'ye basın."
  PC_PICK_CREATED="Pardus Code: %s oluşturuldu"
  # --- tmux status bar hints / messages ---
  PC_TMUX_RESIZE="boyutlandır"
  PC_TMUX_SWAP="değiştir"
  PC_TMUX_FIND="bul"
  PC_TMUX_TERM="terminal"
  PC_TMUX_SWAPPED="Pardus Code: paneller değiştirildi"
  PC_TMUX_RESIZEMODE="Pardus Code: BOYUTLANDIR — oklarla boyutlandır, çıkış için Esc/Enter"
  PC_TMUX_RESIZEDONE="Pardus Code: boyutlandırma bitti"
else
  # --- launcher ---
  PC_MISSING_DEPS="Pardus Code: missing dependencies:"
  PC_INSTALL_HINT="Install them with the bundled installer, or:"
  PC_AGENT_HINT="(opencode is bundled by install.sh, or get it at https://opencode.ai)"
  PC_MISSING_ASSET_1="Pardus Code: missing asset '%s'."
  PC_MISSING_ASSET_2="Re-run install.sh."
  PC_NOT_A_DIR="Pardus Code: '%s' is not a directory."
  # --- picker (Ctrl-F) ---
  PC_PICK_PROMPT="open / create > "
  PC_PICK_HEADER="Pardus Code — type to filter, or type a new name + Enter to create"
  PC_PICK_NOT_STANDALONE_1="pardus-code-pick is launched by Ctrl-F inside Pardus Code — it isn't a"
  PC_PICK_NOT_STANDALONE_2="standalone command. Start Pardus Code with 'pardus-code' and press"
  PC_PICK_NOT_STANDALONE_3="Ctrl-F to find or create files."
  PC_PICK_CREATED="Pardus Code: created %s"
  # --- tmux status bar hints / messages ---
  PC_TMUX_RESIZE="resize"
  PC_TMUX_SWAP="swap"
  PC_TMUX_FIND="find"
  PC_TMUX_TERM="term"
  PC_TMUX_SWAPPED="Pardus Code: panes swapped"
  PC_TMUX_RESIZEMODE="Pardus Code: RESIZE — arrows resize, Esc/Enter to exit"
  PC_TMUX_RESIZEDONE="Pardus Code: resize done"
fi
