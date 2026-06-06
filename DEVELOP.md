# Development Guide

This document provides a comprehensive guide for developing with this Neovim configuration, including commands, architecture, dependencies, and extension patterns.

## Table of Contents

- [Development Commands](#development-commands)
- [Architecture](#architecture)
- [Dependencies](#dependencies)
- [Configuration Philosophy](#configuration-philosophy)
- [Adding New Features](#adding-new-features)
- [Keymaps](#keymaps)
- [See Also](#see-also)

---

## Development Commands

Essential commands for starting, validating, and interacting with this Neovim configuration.

### Start Neovim

Launch the configuration in either full or lite mode:

```bash
nvim                              # Full mode (all plugins loaded)
nvim --cmd "let g:lite_mode=v:true"  # Lite mode (minimal, faster startup)
```

### Validate Configuration

Run Neovim's built-in health check from the command line to diagnose issues without opening the editor:

```bash
nvim --headless -c "lua vim.health ~= nil and vim.health.check() or vim.cmd('checkhealth')" -c "q" 2>&1
```

### Inside Neovim

Common commands available once Neovim is running:

| Command | Description |
|---------|-------------|
| `:Lazy` | Plugin manager UI — manage, update, and sync plugins |
| `:Mason` | Install LSP servers, formatters, linters, and DAP adapters |
| `:LspInfo` | Check status of attached LSP servers and their capabilities |
| `:TSUpdate` | Update all Tree-sitter parsers to latest versions |
| `:checkhealth` | Run comprehensive self-diagnostic for Neovim and plugins |
| `:ConfigEdit <type>` | Quick-edit config files (e.g., `:ConfigEdit nvim` opens init.lua) |
| `:OverseerRun` | Run a predefined development task via overseer.nvim |
| `:OverseerToggle` | Toggle the Overseer task management panel |
| `:QuickMenu` | Access common development workflows (search, git, debug, etc.) |

---

## Architecture

The configuration follows a modular, layered architecture designed for maintainability and performance.

### Entry Points

The initialization flow branches based on the `g:lite_mode` global variable:

| File | Purpose |
|------|---------|
| `init.lua` | Main entry point — bootstraps lazy.nvim, loads environment init, selects full or lite mode |
| `lua/full_init.lua` | Full mode initialization — loads all plugins, LSP, DAP, AI tools, and UI enhancements |
| `lua/lite_init.lua` | Lite mode initialization — loads only core plugins for fast startup |

### Core Layers

Each layer has a single responsibility, reducing coupling between configuration concerns:

| Layer | Purpose |
|-------|---------|
| `lua/core/` | Core settings — LSP activation, keymaps, autocommands, highlights, theme configuration |
| `lua/options/` | Neovim options — editor behavior, appearance, and runtime settings |
| `lua/plugin/` | Plugin specifications (lazy.nvim) and plugin loading orchestration |
| `lua/global/` | Global utilities — shared LSP capabilities, UI helper functions, and constants |
| `lua/util/` | Utility functions — keymap helpers, module loading utilities, buffer operations, quickmenu |
| `lsp/` | Per-language LSP server configurations (external to lua/ for clarity) |

### Plugin Loading

Plugins are organized by category in `lua/plugin/require/require.lua`. Each category groups related plugins together:

| Category | Contents |
|----------|----------|
| `ui/` | Themes (catppuccin), statusline (lualine), bufferline, edgy layout, file trees |
| `tool/` | Telescope (fuzzy finder), Git integration, overseer (tasks), AI tools (avante, opencode, claude) |
| `editor/` | Surround, autopairs, trouble (diagnostics), which-key, flash (navigation) |
| `language/` | LSP configuration, DAP (debugging), completion (blink.cmp), Tree-sitter, language-specific setups |

This categorization makes it easy to locate and manage plugins by their functional domain.

---

## Dependencies

This configuration relies on external tools and language toolchains. Install only what you need for your workflow.

### Required

These are essential for the configuration to function properly:

| Dependency | Purpose |
|------------|---------|
| **Neovim 0.9+** (recommended 0.10+) | The editor itself |
| **Git** | Plugin management via lazy.nvim, version control |
| **Node.js** | Required by many LSP servers (typescript-language-server, eslint, etc.) and Tree-sitter |
| **Python** | Required by some language servers and tools |

### Recommended

Strongly recommended for a complete experience:

| Dependency | Purpose |
|------------|---------|
| **LazyGit** | Modern terminal Git interface (`<leader>lg`) |
| **Ripgrep** (rg) | Fast regex search, used by Telescope and global search features |
| **Tree-sitter CLI** | Parser installation and management for syntax highlighting |

### Build Tools

Required for compiling Tree-sitter parsers and native plugin dependencies:

| Platform | Tools |
|----------|-------|
| **Windows** | Clang or MSVC Build Tools |
| **Linux** | gcc/clang and make |
| **macOS** | Xcode Command Line Tools (`xcode-select --install`) |

### Optional

Enhance the experience but not required:

| Dependency | Purpose |
|------------|---------|
| **Neovide** | GPU-accelerated Neovim GUI with additional optimizations |
| **Nerd Font** | Proper icon display in UI plugins (e.g., FiraCode Nerd Font) |
| **Jujutsu** (jj) | Modern VCS for jj users (supported alongside Git) |
| **Clipboard tools** | System clipboard integration — `xclip`/`xsel` (Linux), `pbcopy` (macOS), `win32yank` (Windows) |

### Language Toolchains

Install only the toolchains for languages you work with:

| Language | Toolchain |
|----------|-----------|
| **Rust** | rustup |
| **C/C++** | MSVC / LLVM (clangd) |
| **Haskell** | GHCup + HLS (haskell-language-server) |
| **Python** | pip / conda |
| **C# / .NET** | .NET SDK |
| **TypeScript/JavaScript** | npm / yarn / pnpm |
| **Go** | go toolchain |
| **Java** | JDK + Maven / Gradle |
| **PHP** | Composer + PHP runtime |
| **Lua** | lua-language-server (included via Mason) |

All LSP servers are managed through Mason — run `:Mason` inside Neovim to install and update them.

---

## Configuration Philosophy

This configuration is guided by several key principles that shape every design decision:

- **Modularity**: Every aspect of the configuration is organized into logical, self-contained modules. Related settings live together; unrelated settings are separated. This makes it easy to find, understand, and modify any part of the configuration.

- **Maintainability**: Clear separation of concerns ensures that changes in one area (e.g., adding a plugin) don't unexpectedly affect another (e.g., keymap bindings). Each module has a single purpose and a predictable interface.

- **Performance**: Lazy loading and conditional initialization keep startup times reasonable despite the configuration's breadth. Lite mode provides an escape hatch for scenarios where speed matters more than features.

- **Flexibility**: The dual-mode system (full vs. lite) supports different workflows and platforms. Cross-platform compatibility is baked in — Windows, macOS, and Linux are all first-class targets.

- **Extensibility**: Adding a new language, plugin, or feature follows established patterns. The plugin loading system categorizes by domain (ui, tool, editor, language), making contributions predictable and consistent.

---

## Adding New Features

This section walks through common extension tasks with practical guidance.

### Add a New Plugin

1. **Define the plugin spec** in `lua/plugin/init.lua`. Use lazy.nvim's specification format to declare the repository, dependencies, lazy-loading conditions, and any build steps.

2. **Create a config file** in the appropriate subdirectory under `lua/plugin/require/`:
   - UI plugins go in `ui/`
   - Tools and integrations go in `tool/`
   - Editor enhancements go in `editor/`
   - Language-specific plugins go in `language/`

3. **Register the plugin** by adding a `require` call in `lua/plugin/require/require.lua` under the matching category section. This ensures the config file is loaded when the plugin is initialized.

> **Tip**: If the plugin has no custom config (defaults are sufficient), you can skip step 2 and just add the spec in `init.lua`.

### Add a New LSP Server

1. **Install the server** via Mason:
   ```vim
   :MasonInstall <server-name>
   ```

2. **Enable the server** in `lua/core/lsp.lua` by adding:
   ```lua
   vim.lsp.enable('<server-name>')
   ```

3. **Add custom settings** (optional): If the server needs specific configuration (initialization options, custom capabilities, root directory patterns), add a setup file in `lsp/setup/<server-name>.lua` and require it from `lua/core/lsp.lua`.

> **Tip**: Use `:LspInfo` to verify the server is attached to your buffer and `:checkhealth lspconfig` to troubleshoot issues.

### Add a New Keymap

1. **Choose the right file**:
   - For simple, standalone keymaps, add them directly in `lua/core/keymap/init.lua` within the appropriate section.
   - For keymaps related to a specific plugin or feature, create a new file in `lua/core/keymap/` (e.g., `lua/core/keymap/my_plugin.lua`) and require it from `init.lua`.

2. **Define the mapping** using `vim.keymap.set()`:
   ```lua
   vim.keymap.set('n', '<leader>xx', '<Cmd>MyCommand<CR>', { desc = 'Description', noremap = true, silent = true })
   ```

3. **For complex multi-key sequences**, consider using a Hydra:
   ```lua
   Hydra({
     name = 'MyTool',
     body = '<leader>mt',
     heads = {
       { 'a', '<Cmd>ActionA<CR>', { description = 'Action A' } },
       { 'b', '<Cmd>ActionB<CR>', { description = 'Action B' } },
     },
   })
   ```

> **Tip**: Always add a `desc` field — it enables which-key integration and makes `<leader>?` more useful.

---

## Keymaps

All keymaps are defined under `lua/core/keymap/`. Use `<leader>?` to see buffer-local keymaps at any time.

### Navigation & Files

| Key | Action |
|-----|--------|
| `<C-x>f` | Pick a file (Pick) |
| `<C-x><C-f>` | Open file (mini.files) |
| `<C-f>` | Telescope find_files |
| `<C-p>` | Telescope (general) |

### LSP & Code Actions

| Key | Action |
|-----|--------|
| `<C-x>a` | LSP actions menu |
| `<C-]>` | Go to definition |

### Testing & Debugging

| Key | Action |
|-----|--------|
| `<C-x>t` | Test menu (neotest) |
| `<F6>` | Toggle DAP UI |
| `<F9>` | DAP Continue |
| `<F10>` | DAP Step Over |
| `<F11>` | DAP Step Into |
| `<F12>` | DAP Step Out |
| `<C-b>` | Toggle breakpoint |

### Buffers

| Key | Action |
|-----|--------|
| `<leader>q` | Close current buffer |
| `<leader>t` + j/k | Buffer prev/next (Hydra) |
| `<S-h>` / `<S-l>` | Previous / Next buffer |
| `[b` / `]b` | Cycle buffers |
| `[B` / `]B` | Move buffer position |

### Windows & Tabs

| Key | Action |
|-----|--------|
| `<C-w>c` + hjkl | Window navigation (Hydra) |
| `<C-w>W` + hjkl | Window sizing (Hydra) |

### UI & Tools

| Key | Action |
|-----|--------|
| `<F3>` | Toggle Outline |
| `<F4>` | Toggle Neotree |
| `<F5>` | QuickMenu |
| `<C-x>q` | QuickMenu |
| `<C-x>u` / `<leader>u` | Toggle undotree |
| `<leader>lg` | Open LazyGit |
| `<leader>fs` | Rip substitute (find & replace) |
| `<leader>xx` | Trouble diagnostics |
| `<leader>?` | Which-key popup |
| `K` | Peek fold or hover (UFO / LSP) |

### Editing & Navigation

| Key | Action |
|-----|--------|
| `s` | Flash jump |
| `jj` | Exit insert mode |
| `zR` / `zM` | UFO fold controls (open/close all) |
| `zr` / `zm` | UFO fold controls (open/close except kinds) |

### AI Integration

| Key | Action |
|-----|--------|
| `<C-a>` | Ask OpenCode AI |
| `<leader>oC` | Toggle OpenCode panel |
| `go` | Operator — add range to OpenCode |
| `goo` | Operator — add line to OpenCode |
| `<S-C-u>` | Scroll OpenCode up |
| `<S-C-d>` | Scroll OpenCode down |

### DAP Menu (Hydra `<leader>dp`)

| Key | Action |
|-----|--------|
| `c` | Continue |
| `i` | Step Into |
| `o` | Step Out |
| `p` | Step Over |
| `n` | Next Breakpoint |
| `s` | Stop |
| `r` | Restart |
| `d` | Disconnect |
| `t` | Toggle Breakpoint |
| `u` | Toggle UI |
| `e` | Eval expression |

---

## See Also

- [README.md](./README.md) - Installation guide, known issues, and quick reference
- [FEATURES.md](./FEATURES.md) - Detailed feature list and language support matrix
