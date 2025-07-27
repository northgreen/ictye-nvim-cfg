# Prisional Config For Neovim
This repo is my prisional config for neovim.
CopyRight (c) 2025/7/27 Ictye, All Right Reserved

## Factures
- **Language Server Protocol (LSP)**: Supports Haskell, Python, and other languages via your preferred LSP server (e.g., `haskell-language-server`).  
- **Syntax Highlighting**: Powered by `tree-sitter` for accurate and fast code parsing.  
- **AI Integration**: Includes `avante.nvim` for AI-assisted coding (e.g., Copilot-like features).  
- **Plugin Ecosystem**: Compatible with popular plugins like `coc.nvim` (requires `node.js`).  
- **Better UI Experience**: Includes `lualine.nvim` and more plugin for a better UI experience.  
- **Test Integration**: Use Neotest for testing support 
- **Debug Integration**: Use `nvim-dap` and `dap-ui` for debugging support.  

## Disadvantages
- **Slow Startup Time**: It is a bit slow between other configuration,But way you want both ultimate experience and speed?
- **Complex Configuration**: Maybe this configuration is more complex than other editors...But it is not a big deal.

## Dependencies
- `neovim`
- `tree-sitter`
- your favorite LSP
- maybe,you need` node.js` for `coc.nvim`

## Installation
1. Fock and clone this repo to your neovim config directory and install some software necessary
2. Run `nvim`
3. Done

## keymaps
See `lua\core\keymaps.lua`

