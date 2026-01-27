# Personal Config For Neovim
This repo is my prisional config for neovim.
CopyRight (c) 2025/7/27 Ictye, All Right Reserved

If you want use this repo, I recommand you fork it or lock the version

## Factures
- **Language Server Protocol (LSP)**: Supports Haskell, Python, and other languages via your preferred LSP server (e.g., `haskell-language-server`).  
- **Syntax Highlighting**: Powered by `tree-sitter` for accurate and fast code parsing.  
- **AI Integration**: Includes `avante.nvim` for AI-assisted coding (e.g., Copilot-like features).  
- **Plugin Ecosystem**: Compatible with popular plugins like `coc.nvim` (requires `node.js`).  
- **Better UI Experience**: Includes `lualine.nvim` and more plugin for a better UI experience.  
- **Test Integration**: Use Neotest for testing support 
- **Debug Integration**: Use `nvim-dap` and `dap-ui` for debugging support.
- **Lite Mode**: A lite mode for faster start up time but with basic factures,use `nvim --cmd "let g:lite_mode=v:true"` to start it.

## Disadvantages
- **Slow Startup Time**: It is a bit slow between other configuration,But way you want both ultimate experience and speed?
- **Complex Configuration**: Maybe this configuration is more complex than other editors...But it is not a big deal.

> By the way,because some fucking problem under windows,the start up time will be **VERY SLOW**,I don't know why.
> I make a `lite mode` for faster start up time,but although I disable any plugin,but it is not perfect on windows,I don't know how windows make it.

## Dependencies
- `neovim`
- `tree-sitter`
- `git`
- `lazygit`(the gui manager for git,it is really eazy for use)
- `rp`(ripgrep)
- your favorite LSP


## Deployment

Prerequisites
- Neovim 0.9+ (recommended 0.10+)
- Git (required), LazyGit (optional but recommended)
- Ripgrep (rg) for search
- Tree-sitter compilers: on Windows install Clang or MSVC Build Tools; on Linux/macOS install gcc/clang and make
- Node.js (required)
- Language toolchains as needed: rustup for Rust, MSVC/LLVM for C/C++, GHCup + HLS for Haskell, etc.

Windows installation steps
1) Backup existing config (if any): move %LOCALAPPDATA%\nvim to a backup folder.
2) Clone this repo into Neovim config directory:
   - Fock this repo
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

Linux/macOS installation steps
1) Clone into your config directory:
   - git clone <your-repo-url> ~/.config/nvim
2) Ensure build tools are installed:
   - gcc/clang and make for Tree-sitter; ripgrep for search.
3) First run
   - nvim
   - If parsers or native deps fail to compile, install required toolchains and retry :TSUpdate.
4) Optional: Lite mode
   - nvim --cmd "let g:lite_mode=v:true"

Language-specific notes
- Haskell: Install GHCup and Haskell Language Server (HLS). haskell-tools.nvim will integrate automatically.
- C/C++: codelldb for DAP. You can install via Mason; :Mason shows adapters.
- Rust: Install rustup and rust-analyzer; neotest integrates with rustaceanvim for testing.
- C#: csharp.nvim is available but commented out in plugin list; enable it if needed and ensure omnisharp is installed (Mason can handle it).

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




