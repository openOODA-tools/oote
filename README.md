# oote — openOODA Theming Engine

<div align="center">

```
   ____  ____  / /____ 
  / __ \/ __ \/ __/ _ \
 / /_/ / /_/ / /_/  __/
 \____/\____/\__/\___/ 
```

**Sovereign, unified theming and color styling engine for the openOODA ecosystem.**

[![ci](https://github.com/openOODA-tools/oote/actions/workflows/ci.yml/badge.svg)](https://github.com/openOODA-tools/oote/actions/workflows/ci.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

</div>

---

## 1. Quick Install

Zero runtime dependencies. The binary is pure native, statically linked with host libc.

### Web (Universal)
```bash
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash
```

### DNF / RPM (Fedora / RHEL / CentOS / Rocky)
```bash
# Automated via web installer
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash -s -- --dnf

# Or direct RPM install from GitHub Releases
sudo dnf install https://github.com/openOODA-tools/oote/releases/download/v0.1.1/oote-0.1.1-1.x86_64.rpm
```

### DEB / APT (Debian / Ubuntu / Mint / Pop!_OS)
```bash
# Automated via web installer
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash -s -- --deb

# Or manual download from GitHub Releases
curl -fsSL -O https://github.com/openOODA-tools/oote/releases/download/v0.1.1/oote_0.1.1-1_amd64.deb
sudo dpkg -i oote_0.1.1-1_amd64.deb
```

### PKGBUILD / Pacman (Arch Linux / Manjaro)
```bash
# Automated via web installer
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash -s -- --pkgbuild

# Or build manually using makepkg
git clone https://github.com/openOODA-tools/oote.git
cd oote/packaging/arch
makepkg -si
```

### Installer Options
```bash
# Preview actions without modifying the host
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash -s -- --dry-run

# Install to custom directory
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash -s -- --prefix ~/.local/bin
```

### Clean Uninstallation
`oote` includes a sovereign, capability-clean uninstaller that removes binary files, package manager installations (`deb`/`rpm`/`arch`), helper scripts, and optionally purges configuration files:

```bash
# 1. Via installed CLI helper (if already installed in PATH)
oote-uninstall
oote-uninstall --purge   # also removes ~/.openooda/theme.oot and cache

# 2. Via dedicated web uninstaller
curl -fsSL https://openooda-tools.github.io/oote/uninstall.sh | bash
curl -fsSL https://openooda-tools.github.io/oote/uninstall.sh | bash -s -- --purge

# 3. Via the universal installer script
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash -s -- --uninstall
curl -fsSL https://openooda-tools.github.io/oote/install.sh | bash -s -- --uninstall --purge

# 4. Preview uninstallation without touching disk
curl -fsSL https://openooda-tools.github.io/oote/uninstall.sh | bash -s -- --dry-run
```

### Build & Manage from Source
```bash
make verify
make build
make test
make install      # installs to PREFIX (default ~/.openooda/bin)
make uninstall    # cleanly uninstalls (use PURGE=1 to remove config)
```
The compiled binary will be placed at `dist/oote`.

---

## 2. Overview & Features

`oote` solves theme fragmentation across the openOODA toolchain. Instead of having each sovereign tool (`oosh`, `oodiff`, `oogrep`, `oofind`, `oojq`, `ootail`, and `tui`) roll its own ad-hoc ANSI escapes or hardcoded palettes, `oote` acts as the single source of truth:

1. **39-Token Semantic Taxonomy**: Consistent tokens across UI chrome, status indicators, syntax highlighting, diffs, search hits, shell prompts, and logs.
2. **25 Sovereign Presets**:
   - **12 Monthly Themes**: `frost` (Jan), `amethyst` (Feb), `thaw` (Mar), `bloom` (Apr), `meadow` (May), `solstice` (Jun), `mirage` (Jul), `amber` (Aug), `equinox` (Sep), `ember` (Oct), `hearth` (Nov), `solitude` (Dec).
   - **7 Seasonal Holiday Themes**: `spooky` (Halloween Oct 25–31), `yule` (Winter Dec 20–26), `nova` (New Year Dec 31–Jan 2), `harvest` (Thanksgiving late Nov), `lantern` (Lunar New Year), `sakura` (Spring equinox), `sol` (Summer solstice).
   - **6 Classic / Base Themes**: `minimax` (official openOODA theme), `1982` (phosphor green CRT), `nord`, `dracula`, `cyberpunk`, `plain`.
3. **Dual Light / Dark Modes**: Every single theme includes both Dark and Light mode color models.
4. **Autonomous Calendar & Circadian Engine**:
   - When set to `auto` (the default), `oote` activates holiday themes during festive dates, transitions smoothly to monthly themes, and follows the sun (Light mode 06:00–17:59, Dark mode 18:00–05:59).
5. **Expressive ASCII Mascots & Micro-Glyphs**:
   - Each theme features a signature ASCII pet and compact prompt micro-glyph.
   - Supports 5 emotional states: `idle` (resting), `happy` (exit 0), `sad` (exit != 0), `alert` (git dirty / conflict), `sleepy` (late night / idle).
6. **Switchable Border Geometries**: Support for `round` (╭─╮), `sharp` (┌─┐), `double` (╔═╗), and `ascii` (+-+).
7. **Global Synchronization**: Preferences are persisted to `~/.openooda/theme.oot` and instantly consumed by all 7 ecosystem tools.
8. **Graceful Capability Degradation**: Automatically emits 24-bit TrueColor, degrades to 256 or 16-color ANSI, and suppresses all ANSI escapes under `NO_COLOR`, `OODA_NO_COLOR`, or `TERM=dumb`.

---

## 3. CLI Usage

```
oote <command> [arguments]
```

### Commands

| Command | Description |
|---|---|
| `oote list` | List all 25 built-in themes and show the active one |
| `oote current [-m\|--mode]` | Print current active theme or lighting mode (`dark` / `light`) |
| `oote preview <theme> [--dark\|--light] [--border <style>]` | Render an interactive showcase card (palette, diffs, syntax, mascot) |
| `oote set <theme> [--dark\|--light]` | Set active theme globally (`auto`, `ember`, `nord`, etc.) |
| `oote mode <dark\|light\|auto\|toggle>` | Switch lighting mode globally |
| `oote border <round\|sharp\|double\|ascii>` | Switch box-drawing border frame globally |
| `oote mascot [theme] [emotion]` | Render signature ASCII companion (`idle`, `happy`, `sad`, `alert`, `sleepy`) |
| `oote glyph [theme] [emotion]` | Render compact shell prompt micro-glyph (e.g., `(^.^)`) |
| `oote get <token>` | Query the ANSI escape sequence and color for a semantic token |
| `oote --help` | Display usage documentation |
| `oote --version` | Display version information |

### Examples

```bash
# Preview current calendar theme with mascot
oote preview auto

# Preview October Ember theme in light mode with double borders
oote preview ember --light --border double

# Preview Halloween Spooky mascot in alert state
oote mascot spooky alert

# Show shell prompt glyph for happy state
oote glyph minimax happy

# Switch system-wide theme to auto
oote set auto

# Switch system-wide mode to light
oote mode light

# Toggle between light and dark mode
oote mode toggle

# Query ANSI color sequence for diff additions
oote get diff_added
```

---

## 4. Ecosystem Integration

All openOODA tools read `~/.openooda/theme.oot` or respect `OODA_THEME`, `OODA_MODE`, and `OODA_BORDER`:

- **oosh**: Sets `theme='oote'` alias, styles interactive dock and prompt accents, and displays emotional prompt glyphs reacting to command exit status.
- **oodiff**: Dynamically hydrates diff colors (`diff_added`, `diff_removed`, `diff_header`).
- **oogrep**: Dynamically hydrates match highlights (`match_hit`, `match_path`, `match_line_num`).
- **oojq**: Theme-aware JSON syntax highlighting (`syntax_keyword`, `syntax_string`, `syntax_number`).
- **oofind**: Styles directory traversal outputs (`shell_nav` for directories, `shell_builtin` for binaries, `syntax_type` for symlinks).
- **ootail**: Formats streaming logs using semantic log level tokens (`log_trace`, `log_info`, `log_warn`, `log_error`).
- **openOODA/tui**: Renders menus, borders, and dialogs using active theme tokens and border shapes.

---

## 5. Sovereign House Laws

`oote` strictly enforces openOODA House Laws:
- **Four-Domain Separation**: `spec/`, `presets/`, `mascot/`, `render/`, `store/`.
- **The Page Rule**: Every `.oo` page is between 16 and 256 lines (shims exempt from floor).
- **Directory Density**: At most 8 pages per directory.
- **Function Caps**: At most 8 functions per page; at most 40 lines per function.
- **Academy Header**: 4-element docstring header present within the first 7 lines.
- **Strict File Law**: Only native `.oo` and `.oot` files in code trees (no `.json`, `.yaml`, `.toml`, or `.py`).
- **Object-Capability Discipline**: Pure renderers require zero ambient authority; file access gated by explicit capability tokens (`&FsReadCap`, `&FsWriteCap`, `&EnvCap`).

---

## 6. License

Apache-2.0