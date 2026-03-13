# Personal Neovim Configuration
This repository contains my personal Neovim configuration.
Copyright (c) 2025/7/27 Ictye, All Rights Reserved

If you want to use this configuration, I recommend you fork it or lock to a specific version.

## Table of Contents
- [Features](#features)
- [Known Issues](#known-issues)
- [Dependencies](#dependencies)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Windows Installation](#windows-installation)
  - [Linux/macOS Installation](#linuxmacos-installation)
  - [Language-specific Setup](#language-specific-setup)
- [Keymaps](#keymaps)
  - [Quick Reference](#quick-reference)
- [Lite Mode](#lite-mode)
- [Configuration Structure](#configuration-structure)
- [Troubleshooting](#troubleshooting)

## Features

### 🚀 Core Features
- **Modern Neovim Architecture**: Built for Neovim 0.9+ with Lua-based configuration
- **Modular Design**: Clean, organized configuration structure for easy maintenance
- **Dual Mode Support**: Full-featured and Lite modes for different use cases
- **Cross-Platform Compatibility**: Optimized for Linux, macOS, and Windows

### 🤖 AI-Enhanced Development
- **Multiple AI Providers**: Support for OpenAI, GitHub Models, SiliconFlow, and more via `avante.nvim`
- **MCP Integration**: Model Context Protocol support for advanced AI interactions
- **FitteCode Integration**: Additional AI coding assistant
- **Image Processing**: AI-powered image analysis and processing capabilities

### 🔧 Development Tools
- **Comprehensive LSP Support**: 20+ language servers with intelligent completion and diagnostics
- **Advanced Debugging**: Full-featured debugging with `nvim-dap` and language-specific adapters
- **Testing Framework**: Integrated `neotest` for seamless test execution
- **Task Management**: `overseer.nvim` for running and managing development tasks

### 🎨 Modern UI/UX
- **Catppuccin Theme**: Beautiful frappe-flavored color scheme
- **Enhanced Status Line**: Information-rich `lualine.nvim` with git, diagnostics, and navigation
- **Smart Buffer Management**: `bufferline.nvim` for intuitive buffer navigation
- **File Management**: Dual file explorer support (`nvim-tree.nvim` and `neo-tree.nvim`)
- **Dashboard**: Custom startup screen with ASCII art

### ⚡ Performance & Productivity
- **Tree-Sitter Integration**: Fast, accurate syntax highlighting for 50+ languages
- **Smart Code Folding**: `nvim-ufo` for intelligent code folding
- **Multi-Cursor Support**: Advanced multi-cursor editing capabilities
- **Quick Navigation**: `flash.nvim` for lightning-fast jumps and navigation
- **Large File Handling**: Automatic optimization for files with 5000+ lines

### 🔍 Search & Navigation
- **Telescope Integration**: Powerful fuzzy finding with FZF acceleration
- **Global Search & Replace**: `grug-far.nvim` for advanced search and replace operations
- **Git Integration**: Comprehensive Git support with `gitsigns.nvim` and `lazygit.nvim`
- **Version Control**: Support for both Git and Jujutsu (jj)
- **File Manager**: `yazi` for terminal-based file management
- **Quick Navigation**: `flash.nvim` for lightning-fast jumps
- **Session Management**: `resession.nvim` for saving/restoring workspace sessions

### 🛠️ Task & Terminal Management
- **Task Runner**: `overseer.nvim` for running and managing development tasks
- **Terminal**: `floaterm` for floating terminal windows
- **Task Automation**: QuickMenu for common development workflows

## Known Issues
- **Extended Startup Time**: This configuration prioritizes feature completeness over startup speed, resulting in longer initialization compared to minimal setups.
- **Configuration Complexity**: The comprehensive nature of this configuration may require a learning curve for users transitioning from basic editors.

> **Platform-Specific Note**: Windows users may experience significantly slower startup times due to platform-specific performance limitations. While a lite mode is available to mitigate this issue, optimal performance is currently achieved on Unix-like systems (Linux/macOS).

## Dependencies

### Required Dependencies
- **Neovim**: 0.9+ (recommended 0.10+)
- **Git**: Required for plugin management and version control
- **Node.js**: Required for many LSP servers and tools
- **Python**: Required for some language servers and utilities

### Strongly Recommended
- **LazyGit**: Modern Git GUI (highly recommended for Git workflows)
- **Ripgrep** (rg): Fast text search for Telescope and global search
- **Tree-sitter CLI**: For parser installation and management

### Build Tools (Required for some features)
- **Windows**: Clang or MSVC Build Tools
- **Linux**: gcc/clang and make
- **macOS**: Xcode Command Line Tools (`xcode-select --install`)

### Optional but Enhanced Experience
- **Neovide**: Modern Neovim GUI with additional optimizations
- **Nerd Font**: For proper icon rendering (e.g., FiraCode Nerd Font)
- **Julius**: For Jujutsu (jj) version control users
- **Clipboard Tools**: For system clipboard integration
  - **Linux**: xclip or xsel
  - **macOS**: pbcopy/pbpaste (built-in)
  - **Windows**: win32yank or WSL clipboard integration

### Language Toolchains (Install as needed)
- **Rust**: rustup
- **Haskell**: GHCup + HLS
- **Python**: pip/conda
- **C/C++**: MSVC/LLVM
- **.NET**: .NET SDK
- **Node.js**: npm/yarn/pnpm
- **Go**: go toolchain
- **Java**: JDK + Maven/Gradle
- **PHP**: Composer + PHP runtime

## Installation

### Prerequisites
- Neovim 0.9+ (recommended 0.10+)
- Git (required), LazyGit (optional but recommended)
- Ripgrep (rg) for search
- Tree-sitter compilers: on Windows install Clang or MSVC Build Tools; on Linux/macOS install gcc/clang and make
- Node.js (required)
- Language toolchains as needed: rustup for Rust, MSVC/LLVM for C/C++, GHCup + HLS for Haskell, etc.

### Windows Installation
1) Backup existing config (if any): move %LOCALAPPDATA%\nvim to a backup folder.
2) Clone this repository into your Neovim config directory:
   - Fork this repository
   - git clone <your-repo-url> "%LOCALAPPDATA%/nvim"
   - If you don’t have SSH keys set up, edit lua/options/gitpull_cfg.lua and set use_ssh=false before first run to use HTTPS for plugin clones.
3) First run
   - Start Neovim: nvim
   - lazy.nvim will bootstrap automatically and install plugins.
   - If Tree-sitter parsers fail to compile, ensure you have a working C/C++ compiler toolchain (MSVC or LLVM/Clang) in PATH.
4) Optional: Lite mode for faster startup
   - nvim --cmd "let g:lite_mode=v:true"
5) Install external tools via Mason when needed
   - :Mason to open the UI and install language servers, formatters and DAP adapters.
   - On Windows, this config auto-adds Mason’s bin to PATH for this Neovim session.
6) Fonts and icons
   - Install a Nerd Font (e.g. FiraCode Nerd Font) and configure your terminal to use it, for proper icons in UI plugins.

### Linux/macOS Installation
1) Clone into your config directory:
   - git clone <your-repo-url> ~/.config/nvim
2) Ensure build tools are installed:
   - gcc/clang and make for Tree-sitter; ripgrep for search.
3) First run
   - nvim
   - If parsers or native deps fail to compile, install required toolchains and retry :TSUpdate.
4) Optional: Lite mode
   - nvim --cmd "let g:lite_mode=v:true"

### Language Support

This configuration provides comprehensive support for 20+ programming languages with intelligent LSP integration, debugging, testing, and language-specific tools.

#### 🦀 Rust
- **LSP**: rustaceanvim with rust-analyzer
- **Features**: Cargo integration, fly-checking, code actions
- **Testing**: neotest with cargo test integration
- **Debugging**: codelldb via nvim-dap
- **Installation**: Install rustup and rust-analyzer

#### 🐍 Python
- **LSP**: pyright with ruff for linting and formatting
- **Features**: Type checking, auto-import, docstring generation
- **Testing**: pytest integration via neotest
- **Debugging**: debugpy adapter
- **Installation**: Install python and required packages via pip

#### 🟢 Haskell
- **LSP**: haskell-language-server (HLS)
- **Features**: GHC integration, hlint, brittany formatting
- **Tools**: haskell-tools.nvim for enhanced Haskell experience
- **Installation**: Install GHCup and HLS
- **Quick setup**: `curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh`

#### 🔧 C/C++
- **LSP**: clangd
- **Features**: Compile commands, cross-referencing
- **Debugging**: codelldb or GDB via nvim-dap
- **Installation**: Install clangd and build tools
- **Setup**: Generate `compile_commands.json` for your project

#### 🔷 C#
- **LSP**: roslyn, omnisharp, or csharp_ls (configurable)
- **Features**: .NET solution integration
- **Testing**: dotnet test support
- **Installation**: Install .NET SDK and Mason-managed servers
- **Note**: Enable in `lua/core/lsp.lua` if needed

#### 🌐 TypeScript/JavaScript
- **LSP**: ts_tool (TypeScript) and biome for formatting
- **Features**: Node.js integration, JSX/TSX support
- **Testing**: Jest/vitest integration
- **Installation**: Install Node.js and TypeScript

#### 🐚 Shell Scripting
- **LSP**: bashls for Bash
- **Features**: Shell script validation and completion
- **Installation**: Install bash-language-server via npm

#### 📝 Configuration Files
- **JSON**: jsonls with schema validation
- **YAML**: yamlls
- **TOML**: taplo
- **Markdown**: marksman for navigation and links
- **Docker**: dockerls
- **Git**: gitui for git operations

#### 🖥️ System Programming
- **Assembly**: asm_lsp for x86/x64 assembly
- **CMake**: cmake language server
- **GLSL**: glslls for OpenGL shaders
- **Lua**: lua_ls with Neovim-specific API support

#### 🎮 Game Development
- **GDScript**: gdscript LSP for Godot Engine
- **Installation**: Install Godot and enable GDScript LSP

#### 📚 Functional & Other Languages
- **Common Lisp**: cl-lsp with SBCL integration
- **F#**: fsautocomplete for .NET F#
- **PowerShell**: powershell_es for Windows automation
- **AutoHotkey**: autohotkey_lsp for Windows scripting

#### 🔧 LSP Management

All language servers are managed through Mason for easy installation and updates:

```vim
:Mason                    # Open Mason UI
:MasonInstall <server>    # Install specific LSP server
:MasonUpdate             # Update all installed servers
```

#### 🎯 Language-Specific Features

- **Auto-format on save**: Configurable per language
- **Code actions**: Refactoring, import organization, error fixing
- **Intelligent completion**: Context-aware suggestions
- **Diagnostics**: Real-time error checking and warnings
- **Documentation**: Hover and signature help
- **Navigation**: Go to definition, references, type definitions
- **Debugging**: Integrated debugging with breakpoints and variable inspection

## Keymaps

Use `\?` to see all buffer-local keymaps.

### Quick Reference

| Shortcut | Description |
|----------|-------------|
| `<C-x>f` | Pick a file (mini.files) |
| `<C-x><C-f>` | Open file |
| `<C-x>a` | Show LSP actions menu |
| `<C-x>t` | Show test menu |
| `<C-x>q` | Open QuickMenu |
| `<F3>` | Toggle Outline |
| `<F4>` | Toggle Neotree |
| `<F5>` | Open QuickMenu |
| `<F6>` | Toggle DAP UI |
| `<F9>` | DAP Continue |
| `<F10>` | DAP Step Over |
| `<F11>` | DAP Step Into |
| `<F12>` | DAP Step Out |
| `<C-b>` | Toggle breakpoint |
| `<C-]>` | Go to definition |
| `<C-w>W` + h/j/k/l | Window navigation (Hydra) |
| `<leader>dp` | DAP menu (Hydra) |
| `<leader>lg` | Open LazyGit |
| `<leader>u` | Toggle UndoTree |
| `<leader>q` | Close current buffer |
| `<leader>t` + j/k | Buffer prev/next |
| `s` | Flash jump |
| `zR` / `zM` | Open/Close all folds |
| `K` | Peek fold or hover |
| `<C-f>` | Telescope find_files |
| `<C-p>` | Telescope |
| `<S-h>` / `<S-l>` | Prev/Next buffer |
| `[b` / `]b` | Cycle buffer |
| `jj` | Exit insert mode |

## Lite Mode

The lite mode provides a minimal Neovim experience with faster startup times:

### How to Use
```bash
nvim --cmd "let g:lite_mode=v:true"
```

### What's Disabled in Lite Mode
- Most UI plugins (lualine, which-key, etc.)
- AI integration features
- Advanced debugging tools
- Test integration
- Some language-specific enhancements

### What Remains Available
- Basic LSP functionality
- Tree-sitter syntax highlighting
- Core navigation and editing features
- File operations

## Special Features

### 🤖 AI Integration
This configuration includes advanced AI capabilities for enhanced development:

#### Multiple AI Providers
- **OpenAI**: GPT models for code generation and assistance
- **GitHub Models**: Access to GitHub's AI models
- **SiliconFlow**: Alternative AI provider
- **Local Models**: Support for locally hosted AI models

#### AI Features
- **Code Generation**: Generate code from natural language descriptions
- **Code Explanation**: Understand complex code snippets
- **Refactoring Suggestions**: AI-powered code improvements
- **Documentation Generation**: Auto-generate comments and documentation
- **Bug Detection**: Identify potential issues and suggest fixes

#### MCP (Model Context Protocol)
- **Context-Aware Assistance**: AI understands your project structure
- **File Integration**: AI can read and analyze your codebase
- **Smart Suggestions**: Contextually relevant recommendations

#### OpenCode
- **Inline AI Chat**: Query AI directly from editor with `<C-a>`
- **Selection Actions**: Process selected code with `<C-x>`
- **Operator Mode**: Use `go` / `goo` to feed text to OpenCode
- **Panel Toggle**: Toggle OpenCode panel with `<C-.>`

### 🎨 Input Method Integration
Special support for Chinese and other non-Latin input methods:

- **Fcitx5 Support**: Automatic input method switching when entering/leaving insert mode
- **Rime Integration**: Support for Rime input method with completion
- **Status Display**: Visual feedback for input method state in UI

### 🖼️ Image Processing
Advanced image handling capabilities:

#### Image Preview
- **Inline Display**: Preview images directly in Neovim
- **Multiple Formats**: Support for PNG, JPG, GIF, SVG
- **Smart Sizing**: Automatic image scaling for optimal viewing

#### AI Image Analysis
- **Content Description**: AI-powered image analysis and description
- **OCR Support**: Extract text from images
- **Code Generation**: Generate code from screenshots/diagrams

### 📊 Performance Monitoring
Built-in performance analysis and optimization:

#### Startup Profiling
- **Timing Analysis**: Detailed startup time breakdown
- **Bottleneck Detection**: Identify slow-loading components
- **Optimization Suggestions**: Automated performance recommendations

#### Runtime Monitoring
- **Memory Usage**: Track memory consumption
- **GC Optimization**: Smart garbage collection management
- **Large File Handling**: Automatic optimization for large files

### 🔧 Advanced Utilities
Specialized tools for enhanced productivity:

#### Carbon.now Integration
- **Code Snippet Sharing**: Generate beautiful code images
- **Social Media Ready**: Perfect for sharing on Twitter, etc.
- **Customizable Themes**: Multiple syntax highlighting themes

#### Obsidian Integration
- **Note Management**: Seamless Obsidian vault integration
- **Link Navigation**: Smart wiki-style linking
- **Knowledge Graph**: Visual representation of note connections

#### Browser Integration
- **Firenvim Support**: Use Neovim directly in browser
- **Remote Development**: SSH-based remote editing
- **Web Development**: Live browser synchronization

#### ASCII Art Dashboard
- **Custom Startup**: Personalized ASCII art welcome screen
- **Dynamic Content**: Context-aware startup information
- **Brand Integration**: Custom branding and logos

## Configuration Structure

```
~/.config/nvim/
├── init.lua                           # Main configuration entry point
├── AGENTS.md                          # Assistant operation log
├── cspell.json                        # Spelling dictionary
├── lazy-lock.json                     # Plugin version lock file
├── lua/
│   ├── env_init.lua                   # Environment initialization and lazy.nvim setup
│   ├── full_init.lua                  # Full mode initialization
│   ├── lite_init.lua                  # Lite mode initialization
│   ├── core/                          # Core configuration modules
│   │   ├── init.lua                   # Core module loader
│   │   ├── vimpreconfig.lua           # Basic Vim settings (encoding, indentation)
│   │   ├── vimconfig.lua              # Theme and appearance settings
│   │   ├── lsp.lua                    # LSP server activation
│   │   ├── autocommand_set.lua        # Custom autocommands
│   │   ├── highlights.lua             # Custom highlight groups
│   │   └── neovide.lua                # Neovide-specific optimizations
│   ├── plugin/                        # Plugin specifications and configurations
│   │   ├── init.lua                   # Plugin manager initialization
│   │   └── require/                   # Plugin configuration files
│   │       ├── ui.lua                 # UI plugins (theme, statusline, etc.)
│   │       ├── tool.lua               # Development tools (telescope, git, etc.)
│   │       ├── editor.lua             # Editor enhancements (surround, pairs, etc.)
│   │       ├── language/              # Language-specific plugins
│   │       │   ├── lspconfig.lua      # LSP configuration
│   │       │   ├── rust.lua           # Rust-specific setup
│   │       │   ├── haskell.lua        # Haskell-specific setup
│   │       │   ├── ai.lua              # AI integration plugins
│   │       │   ├── debug.lua           # Debug adapter setup
│   │       │   ├── test.lua            # Testing framework setup
│   │       │   └── version_control.lua # Git and version control
│   │       ├── other.lua              # Miscellaneous plugins
│   │       └── rock.lua               # Lua rocks configuration
│   ├── lsp/                           # LSP server configurations
│   │   ├── setup/                     # Individual LSP server setups
│   │   └── config/                    # Shared LSP configuration
│   ├── ftplugin/                      # Filetype-specific plugins
│   ├── util/                          # Utility functions and helpers
│   │   ├── functions.lua              # Common utility functions
│   │   ├── module_load_utils.lua      # Safe module loading utilities
│   │   ├── keymap.lua                 # Key mapping utilities
│   │   ├── bf_actions.lua             # Buffer action functions
│   │   └── quickmenu.lua              # Quick menu implementation
│   ├── global/                        # Global configuration and constants
│   │   ├── language/                  # Language-related globals
│   │   │   ├── capabilities.lua       # LSP capabilities configuration
│   │   │   └── attach.lua             # LSP attachment logic
│   │   └── ui_util/                   # UI utilities and ASCII art
│   └── test/                          # Test configurations
└── lsp/                               # Additional LSP configuration files
└── ftplugin/                          # Additional filetype plugins
```

### Configuration Philosophy

This configuration follows several key principles:

- **Modularity**: Each aspect of the configuration is organized into logical modules
- **Maintainability**: Clear separation of concerns makes it easy to modify and extend
- **Performance**: Lazy loading and conditional optimization ensure fast startup
- **Flexibility**: Support for both full-featured and lightweight modes
- **Extensibility**: Easy to add new languages, plugins, or features

## Troubleshooting

### Common Issues

#### Slow Startup on Windows
- Try using lite mode: `nvim --cmd "let g:lite_mode=v:true"`
- Ensure antivirus software isn't scanning Neovim files excessively
- Consider using WSL2 instead of native Windows
#### LSP Server Not Starting
- Install language servers via Mason: `:Mason`
- Check LSP status with `:LspInfo`
- Ensure language servers are in your PATH

#### Plugin Installation Issues
- Delete the `pack` directory and restart Neovim
- Check your internet connection
- Verify git is properly configured

### Useful Commands

- `:Lazy` - Plugin manager UI
- `:Mason` - Install LSP servers, formatters, DAP adapters
- `:LspInfo` - Check LSP server status
- `:TSUpdate` - Update Tree-sitter parsers
- `:checkhealth` - Diagnose common issues
- `:QuickMenu` - Access common development tasks
- `<C-x>oo` / `<C-x>or` - Overseer task commands

### Getting Help

- Check the configuration files in `lua/` directory for specific settings
- Use `:checkhealth` to diagnose common issues
- Join the Neovim community for additional support
- Review plugin documentation for specific issues

