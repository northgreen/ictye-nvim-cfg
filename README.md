# Personal Neovim Configuration

```
 /$$$$$$             /$$                       
|_  $$_/            | $$                        
  | $$    /$$$$$$$ /$$$$$$   /$$   /$$  /$$$$$$ 
  | $$   /$$_____/|_  $$_/  | $$  | $$ /$$__  $$
  | $$  | $$        | $$    | $$  | $$| $$$$$$$$
  | $$  | $$        | $$ /$$| $$  | $$| $$_____/ 
 /$$$$$$|  $$$$$$$  |  $$$$/|  $$$$$$$|  $$$$$$$ 
|______/ \_______/   \___/   \____  $$ \_______/  
                             /$$  | $$           
                            |  $$$$$$/           
                             \______/            
```

This repository contains my personal Neovim configuration.
Copyright (c) 2026 Ictye, All Rights Reserved

If you want to use this configuration, I recommend you fork it or lock to a specific version.

## Table of Contents
- [Known Issues](#known-issues)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Windows Installation](#windows-installation)
  - [Linux/macOS Installation](#linuxmacos-installation)
- [Quick Keymaps](#quick-keymaps)
- [Lite Mode](#lite-mode)
- [Troubleshooting](#troubleshooting)
- [See Also](#see-also)

## Known Issues
- **Extended Startup Time**: This configuration prioritizes feature completeness over startup speed, resulting in longer initialization compared to minimal setups.
- **Configuration Complexity**: The comprehensive nature of this configuration may require a learning curve for users transitioning from basic editors.

> **Platform-Specific Note**: Windows users may experience significantly slower startup times due to platform-specific performance limitations. While a lite mode is available to mitigate this issue, optimal performance is currently achieved on Unix-like systems (Linux/macOS).

## Installation

### Prerequisites
- Neovim 0.9+ (recommended 0.10+)
- Git (required), LazyGit (optional but recommended)
- Ripgrep (rg) for search
- Tree-sitter compilers: on Windows install Clang or MSVC Build Tools; on Linux/macOS install gcc/clang and make
- Node.js (required)
- Language toolchains as needed: rustup for Rust, MSVC/LLVM for C/C++, GHCup + HLS for Haskell, etc.

### Windows Installation
1) Backup existing config (if any): move `%LOCALAPPDATA%\nvim` to a backup folder.
2) Clone this repository into your Neovim config directory:
   - Fork this repository
   - `git clone <your-repo-url> "%LOCALAPPDATA%/nvim"`
   - If you don't have SSH keys set up, edit `lua/options/gitpull_cfg.lua` and set `use_ssh=false` before first run to use HTTPS for plugin clones.
3) First run
   - Start Neovim: `nvim`
   - lazy.nvim will bootstrap automatically and install plugins.
   - If Tree-sitter parsers fail to compile, ensure you have a working C/C++ compiler toolchain (MSVC or LLVM/Clang) in PATH.
4) Optional: Lite mode for faster startup
   - `nvim --cmd "let g:lite_mode=v:true"`
5) Install external tools via Mason when needed
   - `:Mason` to open the UI and install language servers, formatters and DAP adapters.
   - On Windows, this config auto-adds Mason's bin to PATH for this Neovim session.
6) Fonts and icons
   - Install a Nerd Font (e.g. FiraCode Nerd Font) and configure your terminal to use it, for proper icons in UI plugins.

### Linux/macOS Installation
1) Clone into your config directory:
   - `git clone <your-repo-url> ~/.config/nvim`
2) Ensure build tools are installed:
   - gcc/clang and make for Tree-sitter; ripgrep for search.
3) First run
   - `nvim`
   - If parsers or native deps fail to compile, install required toolchains and retry `:TSUpdate`.
4) Optional: Lite mode
   - `nvim --cmd "let g:lite_mode=v:true"`

## Quick Keymaps

Use `\?` to see all buffer-local keymaps.

| Shortcut | Description |
|----------|-------------|
| `<C-x>f` | Pick a file (mini.files) |
| `<C-x><C-f>` | Open file |
| `<C-x>a` | Show LSP actions menu |
| `<C-x>t` | Show test menu |
| `<C-x>q` | Open QuickMenu |
| `<F9>` | DAP Continue |
| `<F10>` | DAP Step Over |
| `<F11>` | DAP Step Into |
| `<F12>` | DAP Step Out |
| `<leader>lg` | Open LazyGit |
| `s` | Flash jump |
| `jj` | Exit insert mode |
| `<leader>q` | Close current buffer |
| `<leader>t` + j/k | Buffer prev/next |
| `zR` / `zM` | Open/Close all folds |
| `<C-a>` | OpenCode AI chat |
| `<leader>oC` | Toggle OpenCode panel |

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

## See Also

- [FEATURES.md](./FEATURES.md) - Detailed feature list and language support
- [DEVELOP.md](./DEVELOP.md) - Development guide and configuration structure
