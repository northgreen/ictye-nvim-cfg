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

### E2E Tests (real user config)
```bash
./tests/e2e/setup.sh   # first run: clone denops.vim to tests/e2e/vendor/
export PATH=$HOME/.deno/bin:$PATH
cd tests/e2e && deno test -A --config deno.jsonc scenarios/
```
框架基于 denops.vim v8 自带 testutil（cli.ts rpc 转发 + Neovim host），启动**真实用户配置**的 nvim 做断言。共 8 个测试（~30s）：4 个功能场景（startup/keymap/lsp/lite）+ 3 个性能场景（perf_startup：full/lite 启动计时；perf_lsp：Lua attach/documentSymbol/hover/编辑；perf_ts：TS 同样四项）+ lsp_test。性能场景用 nvim 内 hrtime 纳秒级计时，测量值即回归信号。坑：lua_ls root_markers 含 .git，仓库内 fixture 需 `.luarc.json` 钉住 workspace 根，否则 documentSymbol 挂起。详见 `tests/e2e/README.md`。

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
| `tests/e2e/` | E2E 测试框架（denops testutil + 真实用户配置） |

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
- See DEVELOP.md Dependencies section for full list

## Mode Toggle

Switch between full and lite modes at runtime:
```lua
-- Toggle full mode (reload config)
:lua vim.g.lite_mode = not vim.g.lite_mode; source $MYVIMRC
```

