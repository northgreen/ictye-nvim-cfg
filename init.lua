--------------------初始化--------------------------------
local function script_path()
   local str = debug.getinfo(1, "S").source:sub(2)
   return str:match("(.*[/ \\])")--删除后面的文件，只保留路径
 end
local path = script_path().."?.lua"
package.path = package.path..";"..path ..";..\\?.lua;"
-----------------自動配置程序依赖------------------------------
--lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
----------------- 其他配置 ------------------------------
----插件
require("lazy").setup({
{
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000
},
{
	"neoclide/coc.nvim",
	branch = "release"
},
{
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        require("nvim-tree").setup {}
    end
},
{
    'nvim-lualine/lualine.nvim',
    config = function()
        require('lualine').setup()
    end
},
"vim-airline/vim-airline",
'vim-airline/vim-airline-themes',
"nvim-tree/nvim-web-devicons",
"Yggdroot/indentLine",
"SHougo/context_filetype.vim",
"tyru/caw.vim",
"lewis6991/gitsigns.nvim",
"mfussenegger/nvim-dap",
"sbdchd/neoformat",
"jiangmiao/auto-pairs",
{
	"luochen1990/rainbow",
	priority = 100,
},
"tpope/vim-surround",
"theHamsta/nvim-dap-virtual-text",
{
  'mrcjkb/rustaceanvim',
  version = '^4', -- Recommended
  lazy = false, -- This plugin is already lazy
},
{
    "kdheepak/lazygit.nvim",
	cmd = {
	"LazyGit",
	"LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
   },
   -- optional for floating window border decoration
   dependencies = {
       "nvim-lua/plenary.nvim",
   },
   -- setting the keybinding for LazyGit with 'keys' is recommended in
   -- order to load the plugin when the command is run for the first time
   keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
   }
},
"nvim-telescope/telescope.nvim",
{
	"folke/neodev.nvim",
	opts = {}
},
"voldikss/vim-floaterm",
'rafcamlet/nvim-luapad',
{
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function() vim.fn"mkdp#util#install" end,
},
{
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
		theme = "hyper",
		config = {
			header = require("plugin_config").dashboard_header
		},
		shortcut = {
			{
				desc = "init.lua",
				group = "@property",
				action = "edit "..script_path().."init.lua",
				key="e"
			}
		},
    }
  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
},
"preservim/tagbar",
'terryma/vim-multiple-cursors',
{
  'pwntester/octo.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  "neovim/nvim-lspconfig"
},
"dyng/ctrlsf.vim",
{
    'ray-x/navigator.lua',
    requires = {
        { 'ray-x/guihua.lua', run = 'cd lua/fzy && make' },
        { 'neovim/nvim-lspconfig' },
    },
	config = function ()
		-- require'navigator'.setup()
	end
},
{
  'stevearc/dressing.nvim',
  opts = {},
},
{
	'akinsho/bufferline.nvim',
	version = "*",
	dependencies = 'nvim-tree/nvim-web-devicons'
},
"hrsh7th/nvim-cmp",
"onsails/lspkind.nvim",
{
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio"
	}
}
})



vim.opt.termguicolors = true
require("bufferline").setup{}

require("keymap")
require("plugins")
require("vimconfig")
require("mytools")

vim.cmd([[
  " 设置状态栏

	let g:rainbow_active = 1
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#left_alt_sep = '|'
	let g:airline#extensions#tabline#buffer_nr_show = 1
	let g:airline#extensions#tabline#formatter = 'default'
	let g:airline_theme = 'catppuccin'  " 主题
	let g:airline#extensions#keymap#enabled = 1
	let g:airline#extensions#tabline#buffer_idx_mode = 1
	let g:airline#extensions#tabline#buffer_idx_format = {
         \ '0': '0 ',
         \ '1': '1 ',
         \ '2': '2 ',
         \ '3': '3 ',
         \ '4': '4 ',
         \ '5': '5 ',
         \ '6': '6 ',
         \ '7': '7 ',
         \ '8': '8 ',
         \ '9': '9 ',
         \}
	if !exists('g:airline_symbols')
		let g:airline_symbols = {}
	endif
	let g:airline_symbols.linenr = "CL" " current line
	let g:airline_symbols.whitespace = '|'
	let g:airline_symbols.maxlinenr = 'Ml' "maxline
	let g:airline_symbols.branch = 'BR'
	let g:airline_symbols.readonly = "RO"
	let g:airline_symbols.dirty = "DT"
	let g:airline_symbols.crypt = "CR"
]])


