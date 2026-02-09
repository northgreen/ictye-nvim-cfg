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
- **Note**: Enable in `lua/plugin/require/language/lspconfig.lua` if needed

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

### Navigation & Files
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<F3>` | Outline | Normal | Toggle code outline |
| `<F4>` | Neotree toggle | Normal | Toggle file explorer |
| `<C-f>` | Telescope find_files | Normal | Search files with Telescope |
| `<C-p>` | Telescope | Normal | Open Telescope main menu |

### Debugging
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<F9>` | DapContinue | Normal | Continue debugging |
| `<F10>` | DapStepOver | Normal | Step over function |
| `<F11>` | DapStepInto | Normal | Step into function |
| `<F12>` | DapStepOut | Normal | Step out of function |
| `<C-b>` | Toggle breakpoint | Normal | Toggle debug breakpoint |

### LSP & Code Actions
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-n>` | LSP hover | Normal | Show hover documentation |
| `<C-]>` | IcDefine | Normal | Go to definition |
| `gO` | Document symbols | Normal | Show document symbols |
| `grt` | Type definitions | Normal | Show type definitions |
| `grr` | References | Normal | Show references |
| `grf` | Format buffer | Normal | Format current buffer |
| `<leader>th` | Toggle inlay hints | Normal | Toggle LSP inlay hints |

### Utility Menus
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<F5>` | QuickMenu | Normal | Open quick menu |
| `<F6>` | IcDAPUIToggle | Normal | Toggle DAP UI |
| `<F2>` | Lazy | Normal | Open Lazy plugin manager |

### Buffer Navigation
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<leader>1-9` | Go to buffer | Normal | Jump to specific buffer |
| `<leader>-` | Previous buffer | Normal | Cycle to previous buffer |
| `<leader>=` | Next buffer | Normal | Cycle to next buffer |
| `<leader>q` | Close buffer | Normal | Close current buffer |
| `<leader>O` | Oil | Normal | Open Oil file manager |

### Ctrl-x Prefix (Extended Functions)
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-x>q` | QuickMenu | Normal | Open quick menu |
| `<C-x>u` | Undotree toggle | Normal | Toggle undo tree |
| `<C-x>f` | Pick files | Normal | Pick files |
| `<C-x>ft` | FloatermNew | Normal | Open floating terminal |
| `<C-x><C-f>` | Mini.files | Normal | Open mini.files |
| `<C-x>a` | LSP actions | Normal | Show LSP actions |
| `<C-x>t` | IcTestMenu | Normal | Open test menu |
| `<C-x>bf` | Telescope buffers | Normal | Show buffer list |
| `<C-x><C-b>` | Telescope buffers | Normal,Terminal | Show buffer list |
| `<C-x>oo` | OverseerToggle | Normal | Toggle Overseer task manager |
| `<C-x>or` | OverseerRun | Normal | Run Overseer task |
| `<C-x>fs` | Neovide fullscreen | Normal | Toggle fullscreen (Neovide only) |

### MultiCursor Integration
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<up>` | Add cursor above | Normal,Visual | Add cursor above |
| `<down>` | Add cursor below | Normal,Visual | Add cursor below |
| `<leader><up>` | Skip cursor above | Normal,Visual | Skip cursor above |
| `<leader><down>` | Skip cursor below | Normal,Visual | Skip cursor below |
| `<leader>n` | Match add cursor down | Normal,Visual | Add cursor to next match |
| `<leader>s` | Match skip cursor down | Normal,Visual | Skip to next match |
| `<leader>N` | Match add cursor up | Normal,Visual | Add cursor to previous match |
| `<leader>S` | Match skip cursor up | Normal,Visual | Skip to previous match |
| `<c-q>` | Toggle cursor | Normal | Toggle multi-cursor mode |
| `<c-leftmouse>` | Handle mouse | Normal | Mouse cursor handling |
| `<c-leftdrag>` | Handle drag | Normal | Mouse drag handling |
| `<c-leftrelease>` | Handle release | Normal | Mouse release handling |

### Window & Tab Management (Hydra)
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-w>c` + `h/j/k/l` | Navigate windows | Normal | Hydra mode for window navigation |
| `<C-w>W` + `h/l/j/k` | Resize windows | Normal | Hydra mode for window resizing |
| `<leader>t` + `j/k` | Navigate tabs | Normal | Hydra mode for tab navigation |

### OpenCode Integration
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-a>` | Ask opencode | Normal,Visual | Ask opencode AI assistant |
| `<C-x>` | Select opencode | Normal,Visual | Execute opencode action |
| `<C-.>` | Toggle opencode | Normal,Terminal | Toggle opencode panel |
| `go` | Add range to opencode | Normal,Visual | Add range to opencode |
| `goo` | Add line to opencode | Normal | Add current line to opencode |
| `<S-C-u>` | Scroll opencode up | Normal | Scroll opencode up |
| `<S-C-d>` | Scroll opencode down | Normal | Scroll opencode down |

### File Operations & Text Manipulation
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<CR>` | Smart newline | Normal | Add line below (special handling for quickfix) |
| `<S-CR>` | Smart newline above | Normal | Add line above |
| `jj` | Exit insert mode | Insert | Exit insert mode |
| `+` | Increment | Normal | Increment number under cursor |
| `-` | Decrement | Normal | Decrement number under cursor |
| `gf` | Image hover | Normal | Hover over images with snacks |

### Folding (UFO)
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `zR` | Open all folds | Normal | Open all folds |
| `zM` | Close all folds | Normal | Close all folds |
| `zr` | Open folds except kinds | Normal | Open folds except certain kinds |
| `zm` | Close folds with | Normal | Close folds with condition |

### Input Method (Rime)
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-^>` | Toggle Rime | Insert | Toggle Rime input method |
| `<C-@>` | Enable Rime | Insert | Enable Rime input method |
| `<C-_>` | Disable Rime | Insert | Disable Rime input method |
| `<C-\>` | Rime callback | Insert | Rime callback |

### Other Utilities
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<A-x>` | Command line | Normal | Open command line |
| `<leader>c` | Exit | Various | Exit from various UIs (common exit key) |

### Custom Commands
| Command | Description |
|---------|-------------|
| `IcFormat` | Format current buffer with LSP |
| `IcRename` | Rename symbol under cursor |
| `IcUseage` | Show incoming calls |
| `IcDefine` | Go to definition |
| `IcDAP` | Launch DAP server |
| `IcDAPUIOpen` | Open DAP UI |
| `IcDAPUIClose` | Close DAP UI |
| `IcDAPUIToggle` | Toggle DAP UI |
| `IcTestMenu` | Open test menu |
| `QuickMenu` | Open quick menu |
| `ConfigEdit nvim` | Edit Neovim config file |

### Additional Keymap Utilities
| Purpose | How to use | Modes | Notes |
|---|---|---|---|
| Buffer-local keymaps (which-key) | Press `<leader>?` to open buffer-local which-key | Normal | Requires `folke/which-key.nvim`; shows available prefixes and mappings for current buffer |
| Telescope keymaps browser | `:Telescope keymaps` | Normal | Interactive keymap browser; requires `telescope.nvim` |
| Adjust key-chord timing | `:set timeoutlen=500` | N/A | Lower values make multi-key sequences register faster; tune to preference |
| Translate key notation | ``:echo keytrans("<C-x>t")`` | N/A | Converts raw sequences into readable notation; see `:help key-notation` |

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

### 🎨 Input Method Integration
Special support for Chinese and other non-Latin input methods:

#### Rime Input Method
- **Seamless Switching**: Automatic IM toggle between insert/normal modes
- **Custom Keybindings**: Dedicated keys for IM control
- **Performance Optimized**: Minimal impact on editing speed

#### fcitx5 Support
- **Linux Integration**: Native fcitx5 support for Linux users
- **Smart Detection**: Automatic IM state detection
- **Mode-Aware**: Different behavior in insert vs normal mode

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

### 🎮 Customization & Theming
Extensive customization options:

#### ASCII Art Dashboard
- **Custom Startup**: Personalized ASCII art welcome screen
- **Dynamic Content**: Context-aware startup information
- **Brand Integration**: Custom branding and logos

#### Theme System
- **Catppuccin Integration**: Beautiful color scheme
- **Custom Highlights**: Extensive syntax highlighting
- **UI Consistency**: Cohesive visual experience

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

#### Tree-sitter Compilation Failures
- Install a C/C++ compiler toolchain:
  - Windows: MSVC Build Tools or LLVM/Clang
  - Linux: `sudo apt install build-essential` (Ubuntu/Debian)
  - macOS: `xcode-select --install`
- Run `:TSUpdate` after installing the toolchain

#### LSP Server Not Starting
- Install language servers via Mason: `:Mason`
- Check LSP status with `:LspInfo`
- Ensure language servers are in your PATH

#### Plugin Installation Issues
- Delete the `pack` directory and restart Neovim
- Check your internet connection
- Verify git is properly configured

### Getting Help

- Check the configuration files in `lua/` directory for specific settings
- Use `:checkhealth` to diagnose common issues
- Join the Neovim community for additional support
- Review plugin documentation for specific issues

