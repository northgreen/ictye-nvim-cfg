# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal Neovim configuration (~/.config/nvim) with modular architecture supporting:
- **Dual mode system**: Full mode (default) vs Lite mode for faster startup
- **AI integration**: Multiple providers (OpenAI, GitHub Models, SiliconFlow) via avante.nvim
- **LSP/DAP**: 20+ language servers with debugging and testing support
- **Cross-platform**: Optimized for Linux, macOS, Windows

## Language

Use Chinese for communication, English for code comments.

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
All plugins in `lua/plugin/require/require.lua`, organized by category:
- `ui/` - themes, statusline, file explorer
- `tool/` - telescope, git, terminal, AI tools
- `editor/` - surround, pairs, multi-cursor
- `language/` - LSP, DAP, completion, treesitter

### Keymaps (all in `lua/core/keymap/init.lua`)
- `<C-x>f` / `<C-x><C-f>` - File picking (mini.files)
- `<C-x>a` - LSP actions menu
- `<C-x>t` - Test menu
- `<F5>` - QuickMenu
- `<F6>` - DAP UI toggle
- `<C-w>W` + hjkl - Window navigation (Hydra)
- `<leader>dp` - DapMenu (Hydra)
- `s` - Flash jump
- `zR/zM` - UFO fold controls

### Adding New Features

#### Add a new plugin
1. Add plugin specification in `lua/plugin/init.lua`
2. Create config file in appropriate `lua/plugin/require/` subdirectory
3. Add require to `lua/plugin/require/require.lua`

#### Add new LSP server
1. Install via Mason: `:MasonInstall <server>`
2. Enable in `lua/core/lsp.lua` via `vim.lsp.enable('<server>')`
3. Add custom settings if needed

#### Add new keymap
1. Edit `lua/core/keymap/init.lua` or create new file in `lua/core/keymap/`
2. Use `vim.keymap.set()` or Hydra for complex mappings

## Limitations

- Windows: slower startup; use lite mode (`g:lite_mode`) if needed
- External tools required: Neovim 0.9+, Git, Node.js, language toolchains
- See README.md Dependencies section for full list