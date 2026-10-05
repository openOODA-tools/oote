# oote: House Laws & Agent Engineering Standards (v1)

This document is the **single canonical source of truth** for all code, architecture, and system integration standards across `oote`. Every human contributor and AI agent must strictly follow these rules without exception.

---

## 1. What oote Is

A sovereign, unified theming and color styling engine for the openOODA ecosystem. It establishes a common semantic token taxonomy across all terminal tools (`oosh`, `oodiff`, `oogrep`, `oofind`, `oojq`, `ootail`, and `tui`), provides ANSI SGR sequence generation with graceful terminal capability degradation, and manages system-wide theme persistence in `~/.openooda/theme.oot`.

It serves a dual posture:
- **Ecosystem Library**: An importable `.oo` anchor library for sovereign tools.
- **CLI Driver**: A standalone terminal binary for listing, previewing, and setting themes.

---

## 2. The Four Domains

Work lands in exactly one domain at a time. Each domain owns a specific responsibility:

| Domain | Responsibility | Does NOT Do |
|---|---|---|
| `spec/` | Color representations, style models, semantic token definitions | Generate terminal escapes or touch disk |
| `presets/` | Curated built-in themes (minimax, 1982, nord, dracula, etc.) | Parse CLI flags or evaluate terminal capabilities |
| `render/` | ANSI escape construction, capability degradation, preview formatting | Define theme palettes or manage configuration |
| `store/` | Config file reading, env resolution, atomic theme setting | Format terminal strings or define colors |

---

## 3. The Page Rule (Code Layout & Sizing)

A **page** is one committed `.oo` or `.oot` file. Automated verification gates enforce these rules under `make verify`:

- **16–256 Lines**: Every committed source file must be between **16 and 256 lines**, counted as exact line breaks.
- **Shim Exemption (Floor Only)**: A file is a shim when every non-comment line is an import (`import "..."`). Shims skip the 16-line floor. The **256-line ceiling still applies without exception**.
- **Directory Density ($\le 8$ files)**: At most **8 `.oo` / `.oot` files per directory**, tests included.
- **Function Caps**: At most **8 functions per page**, and at most **40 lines per function**.
- **Banned File Names**: Never name a page `util.oo`, `utils.oo`, `helper.oo`, `helpers.oo`, `common.oo`, `misc.oo`, `shared.oo`, `base.oo`, or `core.oo`. Name the verb or wholly owned noun.
- **Imports**: All imports must be relative string literals (e.g. `import "spec/color_model.oo";`). Never use `::` namespaces.
- **File Law**: Zero non-native config files (`.json`, `.yaml`, `.toml`, `.py`, `.js` are strictly banned).

---

## 4. The 4-Element Academy Header (Mandatory on Every Page)

Every committed `.oo` file must begin with the standard 4-element Academy docstring within the first 7 lines:

```oo
// # Component Name - Subtitle
//
// Logline: Single-sentence imperative summary of functional responsibility.
//
// Setup: Preconditions, wired capability tokens, imported contracts.
//
// Beats:
//   1. First sequential phase of execution.
//   2. Next phase.
//   3. Final phase / exit state.
```

---

## 5. Capability Discipline & Security Model

`oote` operates strictly on the Object-Capability (OCap) security model:

- **Zero Ambient Authority**: Rendering and palette evaluation are pure functions requiring zero capabilities.
- **Explicit Storage Capabilities**: Reading configuration requires `&FsReadCap` and `&EnvCap`. Modifying theme state requires `&FsWriteCap`.
- **Subprocess Safety**: Never spawn subshells or invoke child processes.

---

## 6. Verification Gate

Before any commit or release, run:

```bash
make verify
```

Runs `line-cap`, `file-law`, `academy`, `density`, and `check` (`oodac check`). All must pass cleanly.
