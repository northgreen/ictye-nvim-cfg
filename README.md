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
| `<C-r_>` | Coc refactor | Normal | Refactor code with coc.nvim |
| `<C-n>` | LSP hover | Normal | Show hover documentation |
| `<C-]>` | IcDefine | Normal | Go to definition |

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

### Ctrl-x Prefix
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-x>q` | QuickMenu | Normal | Open quick menu |
| `<C-x>u` | Undotree toggle | Normal | Toggle undo tree |
| `<C-x>f` | Pick files | Normal | Pick files |
| `<C-x><C-f>` | Mini.files | Normal | Open mini.files |
| `<C-x>a` | LSP actions | Normal | Show LSP actions |
| `<C-x>t` | IcTestMenu | Normal | Open test menu |
| `<C-x>bf` | Telescope buffers | Normal | Show buffer list |
| `<C-x><C-b>` | Telescope buffers | Normal,Terminal | Show buffer list |

### Other
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `gf` | Image hover | Normal | Hover over images with snacks |
| `<A-x>` | Command line | Normal | Open command line |

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
| `+` | Increment | Normal | Increment number under cursor |
| `-` | Decrement | Normal | Decrement number under cursor |

### Additional Keymap Utilities
| Purpose | How to use | Modes | Notes |
|---|---|---|---|
| Buffer-local keymaps (which-key) | Press `<leader>?` to open buffer-local which-key | Normal | Requires `folke/which-key.nvim`; shows available prefixes and mappings for current buffer |
| Telescope keymaps browser | `:Telescope keymaps` | Normal | Interactive keymap browser; requires `telescope.nvim` |
| Adjust key-chord timing | `:set timeoutlen=500` | N/A | Lower values make multi-key sequences register faster; tune to preference |
| Translate key notation | ``:echo keytrans("<C-x>t")`` | N/A | Converts raw sequences into readable notation; see `:help key-notation` |


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

AI/Avante setup
- Check lua/plugin/require/tool/ai/avante.lua for provider settings.
- If building dependencies fails on Windows due to PowerShell policy, you may need:
  - Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
- Adjust endpoint/model/token according to your provider.

Troubleshooting
- lazy.nvim clone fails over SSH: set use_ssh=false in lua/options/gitpull_cfg.lua and retry.
- Tree-sitter compile errors: install a C/C++ compiler and ensure it’s in PATH.
- Missing tools: run :checkhealth and use :Mason to install missing language servers and debug adapters.
- Very slow startup on Windows: try Lite mode, and ensure antivirus exclusions for your Neovim config/data directories.




