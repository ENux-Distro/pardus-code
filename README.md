<h1 align="center">Pardus Code</h1>

<p align="center">
  <b>An AI coding agent and your editor, side by side, in one terminal.</b><br>
  <sub>opencode (left) + GNU nano (right), themed for Pardus.</sub>
</p>

---

Pardus Code glues together two tools that are already excellent on their own:

- **[opencode](https://opencode.ai)** — a terminal AI coding agent — on the **left**
- **GNU nano** — the editor everyone already knows — on the **right**

No IDE, no Electron, no browser. Just open a terminal, type `pardus-code`, and
start coding with an AI agent sitting right next to your editor.

```
┌──────────────────────────────┬───────────────────────┐
│                              │                       │
│   opencode  (AI agent)       │   nano  (editor)      │
│   - ask, refactor, explain   │   - edit your files   │
│   - edits files for you      │   - Ctrl-S to save    │
│                              │                       │
├──────────────────────────────┴───────────────────────┤
│   terminal  (optional, toggle with Ctrl-T)            │
├───────────────────────────────────────────────────────┤
│  PARDUS CODE   ^R resize  ^O swap  ^F find  ^T term   │
└───────────────────────────────────────────────────────┘
```

## Install

Requirements: `tmux` (≥ 3.2), `nano` (≥ 5), `fzf`. The PARDUS-branded opencode
is bundled — no separate opencode install needed.

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/ENux-Distro/pardus-code/main/install | bash
```

Installs deps, downloads Pardus Code and the branded opencode binary, and sets
it up under `~/.local`. For a system-wide install:

```bash
curl -fsSL https://raw.githubusercontent.com/ENux-Distro/pardus-code/main/install | PARDUS_CODE_PREFIX=/usr/local bash
```

### Debian / Pardus package

```bash
sudo apt install ./pardus-code_1.0.0_amd64.deb
```

### From source

```bash
git clone https://github.com/ENux-Distro/pardus-code
cd pardus-code
# drop the branded binary in place (built from your opencode fork):
#   bun ./packages/opencode/script/build.ts --single --skip-embed-web-ui
#   cp packages/opencode/dist/opencode-*/bin/opencode  vendor/opencode
./install.sh --with-deps                 # per-user (~/.local)
sudo ./install.sh --prefix /usr/local --with-deps   # system-wide
```

Building the `.deb` yourself: `packaging/build-deb.sh 1.0.0` (needs `vendor/opencode`).

## Use

```bash
pardus-code            # open the current directory
pardus-code ~/myproj   # open a specific project
```

The left pane is the AI agent — talk to it in plain language. The right pane is
nano, editing the files in your project. When the agent changes a file, reopen
it in nano (`Ctrl-F`) to see the result.

## Shortcuts

| Keys                     | What it does                                                   |
|--------------------------|---------------------------------------------------------------|
| `Ctrl-R` then arrow keys | **Resize** the panes. Press Esc/Enter to finish.              |
| `Ctrl-O`                 | **Swap** the two panes (put nano on the left).                |
| `Ctrl-F`                 | **Find or create** a file. Fuzzy-pick an existing file, *or* type a new name (e.g. `src/shell.c`) and press Enter to create it — it opens in nano instantly, parent folders and all. |
| `Ctrl-T`                 | **Toggle a terminal** across the bottom for compiling, running, and debugging. Press again to hide it. |

Inside nano: `Ctrl-S` save · `Ctrl-X` close · `Ctrl-G` go to line ·
`Ctrl-W` search · `Alt-<` / `Alt->` switch between open files.

> The chords `Ctrl-R`, `Ctrl-O`, `Ctrl-F` and `Ctrl-T` are reserved globally by
> Pardus Code, so they take priority over nano's and opencode's defaults for
> those keys (nano's *save* is moved to `Ctrl-S` to compensate; `Ctrl-T` shadows
> opencode's "cycle model variants").

## Free AI, no sign-up

Pardus Code is built around free models. Pick one in
`~/.local/share/pardus-code/opencode.jsonc`:

- **Easiest** — opencode's hosted free tier (free account, no API key):
  run `opencode auth login`, choose **opencode**, then set
  `"model": "opencode/grok-code-fast-1"`.
- **Fully local, zero account, zero key** — install [Ollama](https://ollama.com),
  `ollama pull qwen2.5-coder:7b`, uncomment the `ollama` provider block, and set
  `"model": "ollama/qwen2.5-coder:7b"`.

If you leave `model` unset, Pardus Code uses whatever you've already configured
in opencode.

## How it works

Pardus Code is a thin, honest wrapper — no custom multiplexer, no reinvented
wheels:

```
bin/pardus-code        launcher: lays out the tmux session, wires the configs
bin/pardus-code-pick   the Ctrl-F file finder/creator (fzf -> nano)
bin/pardus-code-term   the Ctrl-T bottom-terminal toggle
share/pardus.tmux.conf layout, yellow/black Pardus theme, the three shortcuts
share/pardus.nanorc    nano yellow/white theme + key rebinds (multibuffer)
share/pardus.tui.json  selects the opencode "pardus" theme
share/themes/pardus.json   the yellow/black opencode theme itself
share/opencode.jsonc   opencode settings, layered over your global config
vendor/opencode        (optional) the PARDUS-branded opencode binary
```

**Branding.** The Pardus look comes in two layers:

- **Theme (yellow/black):** a custom opencode theme installed to
  `~/.config/opencode/themes/pardus.json`, plus matching nano and tmux colors.
  This needs no rebuild and works with any opencode.
- **Wordmark (PARDUS):** the big `opencode` logo is compiled in, so the
  PARDUS-branded binary is built from source and bundled at
  `share/libexec/opencode`. The launcher prefers it; if it's absent, Pardus Code
  falls back to your system `opencode`. Either way **your global opencode login
  and settings are never touched** — config is layered via `OPENCODE_CONFIG` /
  `OPENCODE_TUI_CONFIG`.

### Rebuilding the branded binary

```bash
cd opencode-source       # your opencode fork (logo.ts -> PARDUS)
bun install
bun ./packages/opencode/script/build.ts --single --skip-embed-web-ui
cp packages/opencode/dist/opencode-*/bin/opencode  pardus-code/vendor/opencode
```

Then re-run `./install.sh`.

## Uninstall

```bash
./uninstall.sh                       # or --prefix /usr/local
```

## License

GPL-2.0. nano, tmux, fzf and opencode keep their own licenses.
