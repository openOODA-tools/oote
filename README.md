# oote — openOODA Theming Engine

<div align="center">

```
   ____  ____  / /____ 
  / __ \/ __ \/ __/ _ \
 / /_/ / /_/ / /_/  __/
 \____/\____/\__/\___/ 
```

**Sovereign, unified theming and color engine for the openOODA ecosystem.**

</div>

---

## Overview

`oote` (openOODA Theming Engine) solves theme fragmentation across the openOODA toolchain. Instead of having each sovereign tool (`oosh`, `oodiff`, `oogrep`, `oofind`, `oojq`, `ootail`, and `tui`) hardcode bespoke ANSI codes, duplicate escape builders, or roll their own palettes, `oote` provides:

1. **A Single Semantic Taxonomy**: 39 unified tokens covering UI chrome, status/diagnostics, syntax highlighting, diffs, search hits, shell prompts, and log levels.
2. **Terminal Capability Degradation**: Automatically emits 24-bit TrueColor (`38;2;R;G;Bm`), degrades gracefully to 16-color ANSI (`30..37m`) on legacy terminals, and suppresses all escape codes under `NO_COLOR`, `OODA_NO_COLOR`, or `TERM=dumb`.
3. **Curated Built-in Presets**: Zero-dependency themes available out of the box:
   - `minimax`: Obsidian neutral with warm amber accents (official openOODA theme).
   - `1982`: Retro phosphor green and amber CRT monochrome.
   - `nord`: Arctic blue-gray calm and clean palette.
   - `dracula`: Gothic high-contrast dark palette with vibrant accents.
   - `cyberpunk`: High-energy neon cyan, ultraviolet, and toxic green.
   - `plain`: Clean unstyled monochrome pass-through without ANSI codes.
4. **Global Ecosystem Persistence**: Reads and sets the user's active theme in `~/.openooda/theme.oot`.

---

## Installation & Build

Build natively using the openOODA toolchain:

```bash
make verify
make build
make test
```

The resulting binary lands at `dist/oote`.

---

## CLI Usage

```
oote <command> [arguments]
```

### Commands

| Command | Description |
|---|---|
| `oote list` | List all available built-in themes and highlight the active one |
| `oote current` | Print the name of the currently active ecosystem theme |
| `oote preview [theme]` | Render a visual showcase (swatches, diffs, syntax, prompt) |
| `oote set <theme>` | Persist the active theme choice into `~/.openooda/theme.oot` |
| `oote get <token>` | Query the color and ANSI sequence for a semantic token |
| `oote --help` | Display usage documentation |
| `oote --version` | Display version information |

### Examples

```bash
# Preview the official Minimax theme
oote preview minimax

# Preview the Cyberpunk theme
oote preview cyberpunk

# Switch system-wide theme to Nord
oote set nord

# Check current active theme
oote current

# Query color for a semantic token
oote get status_success
```

---

## Integration Guide

Consumer tools (`oosh`, `oodiff`, `oogrep`, etc.) integrate with `oote` via its top-level anchor:

```oo
import "spec/color_model.oo";
import "presets/preset_registry.oo";
import "render/painter.oo";
import "store/theme_config.oo";

pub fn render_custom_output(fs_r: &FsReadCap, env: &EnvCap, text: String) -> String {
    let theme_name: String = resolve_active_theme(fs_r, env);
    let color_on: Bool = is_color_enabled(env, false);
    let tc_on: Bool = is_truecolor_enabled(env);
    let accent_color: Color = theme_get_color(theme_name, "ui_accent");

    return paint_bold(text, accent_color, color_on, tc_on);
}
```

---

## Architecture & House Laws

`oote` strictly adheres to openOODA sovereign House Laws:
- **Four-Domain Separation**: `spec/`, `presets/`, `render/`, `store/`.
- **The Page Rule**: 16–256 lines per page (shims exempt from floor).
- **Directory Density**: At most 8 pages per directory.
- **Function Caps**: At most 8 functions per page; at most 40 lines per function.
- **Academy Header**: 4-element docstring header present within the first 7 lines.
- **Strict File Law**: Only native `.oo` and `.oot` files (zero `.json`, `.yaml`, `.toml`, or `.py`).
- **Object-Capability Discipline**: Pure renderers require zero ambient authority; file access gated by explicit capability tokens (`&FsReadCap`, `&FsWriteCap`, `&EnvCap`).

---

## License

Apache-2.0