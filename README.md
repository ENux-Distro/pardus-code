<h1 align="center">Pardus Code</h1>

<p align="center">
  <b>An AI coding agent and your editor, side by side, in one terminal.</b><br>
  <sub>opencode (left) + GNU nano (right), themed for Pardus — in Turkish or English.</sub>
</p>

---

Pardus Code glues together two tools that are already excellent on their own:

- **[opencode](https://opencode.ai)** — a terminal AI coding agent — on the **left**
- **GNU nano** — the editor everyone already knows — on the **right**

No IDE, no Electron, no browser. Just open a terminal, type `pardus-code`, and
start coding with an AI agent sitting right next to your editor. The interface
follows your system locale — **Turkish or English**.

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

### Debian / Pardus package — recommended

**Pre-compiled: nothing to build, and it runs fine on low-RAM machines.** Grab
the latest `pardus-code_*_amd64.deb` from the
[Releases page](https://github.com/ENux-Distro/pardus-code/releases) and:

```bash
sudo apt install ./pardus-code_1.0.0_amd64.deb
```

That's it — `tmux`, `nano` and `fzf` are pulled in as dependencies, and the
branded opencode ships inside the package. Run `pardus-code` and go.

### Build from source — advanced

This compiles the branded opencode on *your* machine, so it needs the `bun`
toolchain and a few GB of RAM (a 4 GB VM is not enough). Prefer the `.deb` above
unless you're hacking on Pardus Code itself.

```bash
curl -fsSL https://raw.githubusercontent.com/ENux-Distro/pardus-code/main/install | bash
```

Or manually:

```bash
git clone https://github.com/ENux-Distro/pardus-code
cd pardus-code
packaging/build-opencode.sh                          # builds -> vendor/opencode
./install.sh --with-deps                             # per-user (~/.local)
```

`build-opencode.sh` installs `bun`, clones the opencode fork over HTTPS, and
compiles the binary. Point it at a different fork/branch with `OPENCODE_FORK` /
`OPENCODE_FORK_REF`. Package maintainers rebuild the `.deb` with
`packaging/build-deb.sh` once `vendor/opencode` exists.

## Use

```bash
pardus-code            # open the current directory
pardus-code ~/myproj   # open a specific project
```

The left pane is the AI agent — talk to it in plain language. The right pane is
nano, editing the files in your project. When the agent changes a file, reopen
it in nano (`Ctrl-F`) to see the result.

## Language

The interface (status bar, prompts, welcome screen) is shown in **Turkish** when
your locale is Turkish (`LANG` / `LC_*` starting with `tr`), and in **English**
otherwise. No configuration needed.

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

A free OpenCode Zen model is pinned out of the box (`opencode/big-pickle`), and
it works with **no login and no API key** — opencode serves its free models
anonymously. Just start typing.

Want a different model? Edit `~/.local/share/pardus-code/opencode.jsonc`:

- **another free model** — run `opencode models` and set e.g.
  `"model": "opencode/deepseek-v4-flash-free"`
- **more/better models** — `opencode auth login` (free account) unlocks them
- **fully offline** — install [Ollama](https://ollama.com), pull a model, and
  point the config at it

## How it works

Pardus Code is a thin, honest wrapper — no custom multiplexer, no reinvented
wheels:

```
bin/pardus-code            launcher: lays out the tmux session, wires the configs
bin/pardus-code-pick       the Ctrl-F file finder/creator (fzf -> nano)
bin/pardus-code-term       the Ctrl-T bottom-terminal toggle
share/lang.sh              Turkish/English UI strings, chosen by locale
share/pardus.tmux.conf     layout, yellow/black Pardus theme, the shortcuts
share/pardus.nanorc        nano yellow/white theme + key rebinds (multibuffer)
share/pardus.tui.json      selects the opencode "pardus" theme
share/themes/pardus.json   the yellow/black opencode theme itself
share/opencode.jsonc       opencode settings, layered over your global config
share/WELCOME.md / .tr.md  the welcome screen (English / Turkish)
packaging/build-opencode.sh  builds the branded opencode from the fork
vendor/opencode            the built binary (gitignored; produced by the build)
```

**Branding.** The Pardus look comes in two layers:

- **Theme (yellow/black):** a custom opencode theme installed to
  `~/.config/opencode/themes/pardus.json`, plus matching nano and tmux colors.
  This needs no rebuild and works with any opencode.
- **Wordmark (PARDUS) + renamed UI:** these are compiled into opencode, so the
  branded binary is **built from the fork** (`packaging/build-opencode.sh`) and
  used in place of any system opencode. Your global opencode login and settings
  are never touched — config is layered via `OPENCODE_CONFIG` /
  `OPENCODE_TUI_CONFIG`.

## Installation and Uninstallation

### Installing via the .deb package

```bash
wget https://github.com/ENux-Distro/pardus-code/releases/download/Pardus-Code/pardus-code_amd64.deb       # downloads the Pardus Code .deb package
sudo apt install ./pardus-code_amd64.deb      # Installs the .deb package via apt using sudo. 


```bash
packaging/build-opencode.sh        # re-clones the fork and rebuilds vendor/opencode
./install.sh                       # re-install
```

### Rebuilding the branded binary

```bash
packaging/build-opencode.sh        # re-clones the fork and rebuilds vendor/opencode
./install.sh                       # re-install
```

### Uninstall

```bash
./uninstall.sh                       # or --prefix /usr/local
```


## License

GPL-2.0. nano, tmux, fzf and opencode keep their own licenses.
