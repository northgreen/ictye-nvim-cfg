# Features

> This document provides a comprehensive overview of all features, language support, and special capabilities included in this Neovim configuration.

## Table of Contents
- [Core Features](#core-features)
  - [AI-Enhanced Development](#ai-enhanced-development)
  - [Development Tools](#development-tools)
  - [Modern UI/UX](#modern-uiux)
  - [Performance & Productivity](#performance--productivity)
  - [Search & Navigation](#search--navigation)
  - [Task & Terminal Management](#task--terminal-management)
- [Language Support](#language-support)
  - [Rust](#rust)
  - [Python](#python)
  - [Haskell](#haskell)
  - [C/C++](#cc)
  - [C#](#c)
  - [TypeScript/JavaScript](#typescriptjavascript)
  - [Shell & Config Files](#shell--config-files)
  - [System Programming](#system-programming)
  - [Game Dev](#game-dev)
  - [Functional & Others](#functional--others)
  - [LSP Management](#lsp-management)
  - [Language-Specific Features](#language-specific-features)
- [Special Features](#special-features)
  - [AI Integration](#ai-integration)
  - [Input Method Integration](#input-method-integration)
  - [Image Processing](#image-processing)
  - [Performance Monitoring](#performance-monitoring)
  - [Advanced Utilities](#advanced-utilities)

---

## Core Features

This configuration is designed to provide a complete, production-ready development environment. Below are the key feature categories that make this possible.

### AI-Enhanced Development
- **Multiple AI Providers**: Avante supports OpenAI, GitHub Models, SiliconFlow, and custom endpoints
- **Inline AI Chat**: OpenCode integration with `<C-a>` for ask and `<C-x>` for code actions
- **AI Operator**: `go` / `goo` operators to feed code directly to OpenCode
- **MCP Hub**: Model Context Protocol support for file and tool integration (`mcphub.nvim`)
- **Fitten Code**: AI-powered code completion
- **Claude Code**: Direct Claude integration for advanced reasoning
- **Minuet AI**: Additional AI assistant for quick queries

### Development Tools
- **Git Integration**: Gitsigns for inline diff, LazyGit for TUI Git client, Jujutsu (jj) VCS support
- **Debugger (DAP)**: Full Debug Adapter Protocol support with UI, virtual text, and break points
- **Test Runner**: Integrated test execution via `nvim-test` and `<C-x>t` menu
- **Code Refactoring**: Automated refactoring tools for safe code transformations
- **Formatting**: Automatic code formatting with `neo_format`
- **Project Toolchain**: Project-level tool configuration (`project_toolchain`)
- **Code Generation**: Neogen for automatic docstring and comment generation
- **Rest Client**: Built-in REST API testing (`rest.nvim`)
- **WakaTime**: Automatic time tracking and productivity metrics

### Modern UI/UX
- **Status Line**: Lualine with customizable, information-rich status bar
- **Buffer Line**: Tab-style buffer navigation with indicators
- **File Explorers**: Neo-tree, Nvim-tree, Oil.nvim, and Yazi for different file browsing needs
- **Dashboard**: Beautiful startup screen with session quick access
- **Code Folding**: UFO folding with LSP-aware fold text
- **Indent Guides**: Indent-blankline for visual indent alignment
- **Rainbow Delimiters**: Color-coded bracket matching
- **Trouble**: Centralized diagnostics, references, and definitions panel
- **Which-Key**: Menu-driven keymap hints
- **Flash**: Rapid cursor movement with character search
- **Smear Cursor**: Smooth cursor animation for better visual tracking
- **Smooth Scrolling**: Vim-smoothie for fluid scrolling experience
- **Code Window**: Code minimap for quick navigation
- **Edgy**: Intelligent sidebar layout management
- **Noise Background**: Subtle noise texture for visual depth
- **Lens Line**: Virtual line enhancements
- **Vim Illuminate**: Automatic highlighting of word under cursor
- **Play-One**: Animation playback support

### Performance & Productivity
- **Dual Mode System**: Full mode (default) vs Lite mode (`g:lite_mode`) for faster startup
- **Tree-sitter**: Advanced syntax highlighting and code parsing for 50+ languages
- **LSP Integration**: 20+ language servers with auto-configuration via Mason
- **Session Management**: Resession for saving and restoring work sessions
- **TODO Management**: Highlight and navigate TODO, FIXME, HACK comments
- **Hardtime**: Enforces proper Vim keymap usage to build muscle memory
- **Multi Cursor**: Visual-multi and multicursor for batch editing
- **Surround**: Quick add/change/delete surrounding pairs and tags
- **Auto Pairs**: Automatic bracket and quote closing
- **Undo Tree**: Visual undo history navigation

### Search & Navigation
- **Telescope**: Powerful fuzzy finder with FZF backend for files, buffers, grep, and more
- **Flash**: Lightning-fast jump to any visible text
- **Ripgrep Substitute**: Quick find-and-replace across project
- **Grug-Far**: TUI-based regex search and replace
- **Outline**: Code structure sidebar with symbol navigation
- **Navic**: LSP-powered location navigation (current function, class, etc.)
- **Marks**: Bookmark and jump between important locations
- **Screenkey**: Display recent keystrokes for presentations

### Task & Terminal Management
- **Overseer**: Task runner with persistent tasks, dependencies, and output viewing
- **Floaterm**: Floating terminal windows for quick command execution
- **LuaPad**: Real-time Lua code execution sandbox
- **Snacks**: Collection of Neovim utilities and helpers

---

## Language Support

This configuration provides comprehensive support for over 20 programming languages, with dedicated LSP servers, debugging adapters, and language-specific tooling. Each language benefits from intelligent code completion, diagnostics, and refactoring capabilities.

### Rust
- **Plugin**: `rustaceanvim` (replaces obsolete rust-tools.nvim)
- **LSP**: `rust-analyzer` via rustaceanvim
- **Features**: Inlay hints, cargo integration, crate graph, runnables, hover actions
- **Debugging**: LLDB via nvim-dap

### Python
- **LSP**: `pyright` (type checking), `ruff` (linting & formatting)
- **Features**: Type inference, auto-import, diagnostic codes, quick fix
- **Debugging**: Debugpy via nvim-dap
- **Testing**: pytest integration

### Haskell
- **Plugin**: `haskell.nvim` with `haskell-tool`
- **LSP**: `haskell-language-server` (HLS)
- **Features**: Type signatures, go-to-definition, hoogle search, cabal/stack integration
- **Special**: GHCup toolchain support

### C/C++
- **LSP**: `clangd` with project-aware configuration
- **Features**: Cross-references, include management, code actions, semantic highlighting
- **Debugging**: GDB/LLDB via nvim-dap
- **Build**: CMake integration via `cmake-tools`

### C#
- **LSP**: `csharp-ls`, `omnisharp`, `roslyn`
- **Features**: IntelliSense, navigate-to, rename, extract method
- **DAP**: netcoredbg for .NET debugging
- **Plugin**: `eazy-dotnet` for .NET project management
- **Unity**: Unity engine integration

### TypeScript/JavaScript
- **LSP**: `vtsls`, `ts_ls`, `volar` (Vue), `vue_ls`
- **Plugin**: `ts_tool` for TypeScript tooling
- **Features**: Auto-import, inlay hints (parameter names, types), organize imports
- **Debugging**: Node.js debugger via nvim-dap
- **Emmet**: `emmet_ls` and `emmet-language-server` for HTML/CSS/JSX expansion

### Shell & Config Files
- **Shell Script**: `bashls` for Bash language server
- **JSON**: `jsonls` for JSON schema validation and completion
- **CSS/SCSS**: `cssls` with CSS IntelliSense
- **YAML**: `yamlls` for schema validation
- **Lua**: `lua_ls` for Lua language server (used by this config itself)
- **Vim Script**: `vimls` for VimL completion

### System Programming
- **Assembly**: `asm_lsp` for assembly language support
- **CMake**: CMake language server for build configuration
- **Zig**: `zls` for Zig language server
- **Go**: `gopls` for Go language server
- **PowerShell**: `powershell_es` for PowerShell scripting

### Game Dev
- **GDScript**: LSP for Godot 4 scripting
- **GLSL**: `glslls` for shader language
- **GDShader**: `gdshader_lsp` for Godot shader files
- **QML**: `qmlls` for Qt Quick/QML

### Functional & Others
- **F#**: `fsharp_language_server` with `fsautocomplete`
- **Common Lisp**: `cl-lsp` for Common Lisp
- **Sonic Pi**: Sonic Pi live coding music integration
- **XML**: `lemminx` for XML schema validation
- **Hyprland**: `hyprls` for Hyprland window manager config
- **CSpell**: `cspell_ls` for spell checking in code

### LSP Management
- **Mason**: Universal LSP server, linter, and formatter installer
- **Mason-LSPConfig**: Automatic LSP configuration for Mason-installed servers
- **Per-Server Config**: 30+ language-specific configurations in `lsp/*.lua`
- **Project LSP**: `lsp_project.lua` for project-specific LSP overrides
- **Auto-Detection**: Automatically enables LSP for detected languages

### Language-Specific Features
- **Blink.cmp**: Modern completion engine with snippet support
- **LSP Signature**: Function signature help on hover and parameter entry
- **Refactoring**: Safe code transformations (extract function, rename, etc.)
- **Neorg**: Note-taking and document structuring within Neovim
- **Render Markdown**: Rich Markdown rendering inside Neovim
- **Obsidian**: Integration with Obsidian vaults for knowledge management
- **Firenvim**: Edit browser text areas with Neovim

---

## Special Features

Beyond standard editor capabilities, this configuration includes several unique integrations and advanced utilities that enhance the development workflow, provide cross-platform productivity boosts, and enable modern tool integration patterns.

### AI Integration

#### Multiple AI Providers
This configuration supports multiple AI backends simultaneously, allowing you to choose the best provider for each task:
- **OpenAI**: GPT-4 and GPT-4o models via Avante
- **GitHub Models**: Free access to various LLMs through GitHub's model marketplace
- **SiliconFlow**: Cost-effective Chinese LLM provider
- **Custom Endpoints**: Configurable for self-hosted or private models

#### AI Features
- **Inline Chat**: Ask questions, request code changes, and get explanations without leaving your buffer (`<C-a>`)
- **Code Actions**: Select code and apply AI-suggested refactors, tests, or optimizations (`<C-x>`)
- **AI Operators**: Use `go` or `goo` to feed visual selections directly to OpenCode
- **Context Awareness**: AI can see your current buffer, selection, and project structure
- **Panel Toggle**: `<leader>oC` opens/closes the OpenCode panel for continuous AI sessions

#### MCP (Model Context Protocol)
- **mcphub.nvim**: Runs MCP Hub on port 37373 for tool integration
- **File Access**: AI agents can read, search, and analyze project files
- **Extensible**: Add custom MCP servers for any external tool or API

#### OpenCode
- **First-Class Integration**: Native keymaps and operators designed around OpenCode
- **Operator Mode**: Visual selections automatically prefixed for AI context
- **Panel Management**: Dedicated toggle for persistent AI workspace

### Input Method Integration

Seamless input method switching for bilingual typing workflows:
- **im-select**: Automatically switches to the correct IME mode when entering/exiting Insert mode
- **Fcitx5 Integration**: Full Fcitx5 control and status display
- **Fcitx5 UI**: Visual indicator showing current input method state
- **Rime Input Method**: Built-in Rime (中州韵) integration for Chinese typing
- **Auto Switching**: Remembers last used IME per buffer and mode

### Image Processing

Tools for working with images and visual content:
- **Carbon.now**: Generate beautiful code screenshots via Carbon.sh
- **NVim Highlight Colors**: Displays actual color swatches for hex color codes in files
- **Render Markdown**: Rich image rendering within Markdown buffers
- **Smear Cursor**: Visual cursor trail for presentations and recordings

### Performance Monitoring

Built-in performance and productivity tracking:
- **WakaTime**: Automatic time tracking across all languages and projects
- **Startup Profiling**: Lite mode vs Full mode performance comparison
- **LSP Diagnostics**: Real-time error, warning, and hint display
- **Problem Count**: Integrated diagnostics count in status line
- **Memory Awareness**: Token and performance monitoring for AI interactions

### Advanced Utilities

Productivity boosters and quality-of-life improvements:
- **Undotree**: Visualize and navigate the full undo history tree
- **Hydra**: Multi-key mapping sequences (window sizing, DAP controls)
- **Snacks**: Swiss-army knife of Neovim utilities (pickers, notifiers, etc.)
- **Mark**: Quick bookmarks for jumping between important locations
- **Resession**: Save and restore entire Neovim sessions with layout
- **Hardtime**: Enforce proper Vim navigation (prevents arrow key abuse)
- **Neovide Support**: GPU-accelerated Neovim GUI with custom font and effects
- **Kitty Navigator**: Seamless window splitting with Kitty terminal emulator
- **Vim-Tmux Navigator**: Cross-pane navigation between Vim and Tmux
- **Screenkey**: Display recent keystrokes (useful for tutorials and demos)
- **MinInvim**: Minimal Vim configuration patterns
- **Unity Editor**: Unity engine project integration
- **Project Toolchain**: Per-project tool and LSP configuration management
- **Rest Client**: HTTP request testing from within Neovim
- **Firenvim**: Turn your browser's text areas into Neovim buffers

## See Also

- [README.md](./README.md) - Installation guide and quick reference
- [DEVELOP.md](./DEVELOP.md) - Development guide and configuration structure

