# AGENTS.md

Purpose
- This document tracks assistant-driven operations and context for this Neovim configuration repository.
- Update policy: append-only log; do not delete or rewrite history; each entry includes date and a concise description.

Conventions
- Do not include secrets or tokens.
- Use clear, concise summaries.
- File naming is standardized; this file is AGENTS.md.

## Language

Use Chinese for communication, English for code comments.

## Project Overview

Personal Neovim configuration (~/.config/nvim) with modular architecture supporting:
- **Dual mode system**: Full mode (default) vs Lite mode for faster startup
- **AI integration**: Multiple providers (OpenAI, GitHub Models, SiliconFlow) via avante.nvim
- **LSP/DAP**: 20+ language servers with debugging and testing support
- **Cross-platform**: Optimized for Linux, macOS, Windows

## Development Commands

### Start Neovim
```bash
nvim                    # Full mode (all plugins)
nvim --cmd "let g:lite_mode=v:true"  # Lite mode (minimal)
```

### Validate Configuration
```bash
nvim --headless -c "lua vim.health ~= nil and vim.health.check() or vim.cmd('checkhealth')" -c "q" 2>&1
```

### Inside Neovim
| Command | Description |
|---------|-------------|
| `:Lazy` | Plugin manager UI |
| `:Mason` | Install LSP servers, formatters, DAP |
| `:LspInfo` | Check LSP server status |
| `:TSUpdate` | Update Tree-sitter parsers |
| `:checkhealth` | Diagnose issues |
| `:ConfigEdit <type>` | Edit config files (nvim) |
| `:OverseerRun` | Run a task |
| `:OverseerToggle` | Toggle task panel |

## Architecture

### Entry Points
- `init.lua` - Main entry, bootstraps lazy.nvim and selects mode
- `lua/full_init.lua` - Full mode initialization
- `lua/lite_init.lua` - Lite mode initialization

### Core Layers
| Layer | Purpose |
|-------|---------|
| `lua/core/` | Settings, LSP, keymaps, autocommands |
| `lua/options/` | Neovim options configuration |
| `lua/plugin/` | Plugin specs (lazy.nvim) |
| `lua/global/` | LSP capabilities, UI utilities |
| `lua/util/` | Shared utilities (keymap, functions) |
| `lsp/*.lua` | Per-language LSP server configs |

### Plugin Loading
Plugins are specified in `lua/plugin/require/require.lua`, organized by category:
- `ui/` - themes, statusline, bufferline, edgy
- `tool/` - telescope, git, overseer, AI tools (avante, opencode, claude)
- `editor/` - surround, pairs, trouble, which-key
- `language/` - LSP, DAP, completion, treesitter, blink.cmp

## Keymaps

All keymaps are defined in `lua/core/keymap/init.lua`:

| Key | Action |
|-----|--------|
| `<C-x>f` / `<C-x><C-f>` | File picking (mini.files) |
| `<C-x>a` | LSP actions menu |
| `<C-x>t` | Test menu |
| `<C-x>q` | QuickMenu |
| `<C-x>u` / `<leader>u` | Toggle undotree |
| `<F3>` | Toggle Outline |
| `<F4>` | Toggle Neotree |
| `<F5>` | QuickMenu |
| `<F6>` | DAP UI toggle |
| `<F9>` | DAP Continue |
| `<F10>` | DAP Step Over |
| `<F11>` | DAP Step Into |
| `<F12>` | DAP Step Out |
| `<C-b>` | Toggle breakpoint |
| `<C-w>W` + hjkl | Window sizing (Hydra) |
| `<C-w>c` + hjkl | Window navigation (Hydra) |
| `<leader>dp` | DapMenu (Hydra) |
| `<leader>q` | Close current buffer |
| `<leader>t` + j/k | Buffer prev/next |
| `<leader>lg` | Open LazyGit |
| `<leader>fs` | Rip substitute |
| `<leader>xx` | Trouble diagnostics |
| `<leader>?` | Which-key popup |
| `s` | Flash jump |
| `zR`/`zM` | UFO fold controls |
| `jj` | Exit insert mode |
| `<C-a>` / `<C-x>` | OpenCode AI chat (ask/select) |
| `go`/`goo` | OpenCode operator |
| `<leader>oC` | Toggle OpenCode panel |

## Adding New Features

### Add a new plugin
1. Add plugin specification in `lua/plugin/init.lua`
2. Create config file in appropriate `lua/plugin/require/` subdirectory
3. Add require to `lua/plugin/require/require.lua`

### Add new LSP server
1. Install via Mason: `:MasonInstall <server>`
2. Enable in `lua/core/lsp.lua` via `vim.lsp.enable('<server>')`
3. Add custom settings if needed

### Add new keymap
1. Edit `lua/core/keymap/init.lua` or create new file in `lua/core/keymap/`
2. Use `vim.keymap.set()` or Hydra for complex mappings

### AI Integration
- **Avante** - Multi-provider AI coding assistant (OpenAI, GitHub Models, SiliconFlow)
- **OpenCode** - Inline AI chat and code actions
  - `<C-a>` - Ask AI (with selection auto-prefix)
  - `<C-x>` - Execute AI action on selection
  - `go` / `goo` - Operator to feed code to OpenCode
  - `<leader>oC` - Toggle OpenCode panel
- **Fitten Code** - AI code completion
- **MCP** - Model Context Protocol for file integration

## Limitations

- Windows: slower startup; use lite mode (`g:lite_mode`) if needed
- External tools required: Neovim 0.9+, Git, Node.js, language toolchains
- See README.md Dependencies section for full list

## Mode Toggle

Switch between full and lite modes at runtime:
```lua
-- Toggle full mode (reload config)
:lua vim.g.lite_mode = not vim.g.lite_mode; source $MYVIMRC
```

Operation Log
- 2025-08-24: Explained init.lua configuration in detail.
- 2025-08-24: Produced a full repository explanation.
- 2025-08-24: Translated the full repository explanation to Chinese.
- 2025-08-24: Renamed ANGENTS.md to AGENTS.md and standardized content.
- 2025-08-24: Added deployment instructions to README.md.
- 2025-08-24: Improved README keymaps section with keymap capture and inspection table (docs-only).
+ 2026-02-09: Comprehensive README.md enhancement based on full repository analysis:
  - Fixed spelling errors and grammar issues throughout the document
  - Restructured document with proper table of contents and section organization
  - Expanded Features section with categorized, detailed descriptions of all capabilities
  - Added comprehensive Language Support section covering 20+ programming languages
  - Updated Dependencies with categorized required, recommended, and optional tools
  - Added Special Features section highlighting AI integration, IM support, image processing, performance monitoring
  - Enhanced Configuration Structure with detailed file hierarchy and philosophy
  - Improved Installation instructions with platform-specific guidance
  - Added troubleshooting section for common issues

## Deployment
(To be completed)
+ 2026-06-07: Merged CLAUDE.md content into AGENTS.md; AGENTS.md now primary, CLAUDE.md minimal reference.

