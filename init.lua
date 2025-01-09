--------------------初始化--------------------------------
local function script_path()
    local str = debug.getinfo(1, "S").source:sub(2)
    return str:match("(.*[/ \\])") -- 删除后面的文件，只保留路径
end
local path = script_path() .. "?.lua"
package.path = package.path .. ";" .. path .. ";..\\?.lua;"
-----------------自動配置程序依赖------------------------------
-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "git@github.com:folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)
----------------- 其他配置 ------------------------------
----插件
local function InitPlugin()
    require('lazy').setup({
        {
			'catppuccin/nvim', 
			name = 'catppuccin', 
			priority = 1000,
			config = function() require('catppuccin').setup({flavour = "frappe"}) end
		},
        {'neoclide/coc.nvim', branch = 'release'}, 
		{
            "nvim-tree/nvim-tree.lua",
            version = "*",
            dependencies = {'nvim-tree/nvim-web-devicons'},
            config = function() require("nvim-tree").setup({}) end
        }, 
		{
            'nvim-lualine/lualine.nvim',
            config = require('PluginConfigs.UI.lualine_cfg').cfg
        }, 
		'vim-airline/vim-airline', 
		'vim-airline/vim-airline-themes',
        'nvim-tree/nvim-web-devicons', 
		"Yggdroot/indentLine",
        'SHougo/context_filetype.vim', 
		'tyru/caw.vim',
        'lewis6991/gitsigns.nvim', 
		'mfussenegger/nvim-dap', 
		'sbdchd/neoformat',
        'jiangmiao/auto-pairs', 
		{"luochen1990/rainbow", priority = 100},
        "tpope/vim-surround", 
		"theHamsta/nvim-dap-virtual-text", 
		{
            'mrcjkb/rustaceanvim',
            version = '^4', -- Recommended
            lazy = false -- This plugin is already lazy
        }, 
		{
            "kdheepak/lazygit.nvim",
            cmd = {
                "LazyGit", "LazyGitConfig", "LazyGitCurrentFile",
                "LazyGitFilter", "LazyGitFilterCurrentFile"
            },
            -- optional for floating window border decoration
            dependencies = {"nvim-lua/plenary.nvim"},
            -- setting the keybinding for LazyGit with 'keys' is recommended in
            -- order to load the plugin when the command is run for the first time
            keys = {{"<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit"}}
        }, 
		"voldikss/vim-floaterm", 
		'rafcamlet/nvim-luapad', 
		{
            "iamcco/markdown-preview.nvim",
            cmd = {
                "MarkdownPreviewToggle", "MarkdownPreview",
                "MarkdownPreviewStop"
            },
            ft = {"markdown"},
            build = function() vim.fn "mkdp#util#install" end
        }, 
		{
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        {path = "luvit-meta/library", words = {"vim%.uv"}}
                    }
                }
            }, {"Bilal2453/luvit-meta", lazy = true}, -- optional `vim.uv` typings
            { -- optional completion source for require statements and module annotations
                "hrsh7th/nvim-cmp",
                opts = function(_, opts)
                    opts.sources = opts.sources or {}
                    table.insert(opts.sources, {
                        name = "lazydev",
                        group_index = 0 -- set group index to 0 to skip loading LuaLS completions
                    })
                end
            }
            -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
        }, {
            'nvimdev/dashboard-nvim',
            event = 'VimEnter',
            config = require('PluginConfigs.UI.dashboard').cfg,
            dependencies = {{'nvim-tree/nvim-web-devicons'}}
        }, 
		'terryma/vim-multiple-cursors', 
		{
            'pwntester/octo.nvim',
            requires = {
                'nvim-lua/plenary.nvim', 
				'nvim-telescope/telescope.nvim',
                'nvim-tree/nvim-web-devicons'
            },
            "neovim/nvim-lspconfig"
        }, "dyng/ctrlsf.vim", {
            'ray-x/navigator.lua',
            requires = {
                {'ray-x/guihua.lua', run = 'cd lua/fzy && make'},
                {'neovim/nvim-lspconfig'}
            },
            config = function()
                -- require'navigator'.setup()
            end
        }, {'stevearc/dressing.nvim', opts = {}}, {
            'akinsho/bufferline.nvim',
            version = "*",
            dependencies = 'nvim-tree/nvim-web-devicons'
        }, "hrsh7th/nvim-cmp", "onsails/lspkind.nvim", {
            "rcarriga/nvim-dap-ui",
            dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"}
        }, 
		"onsails/lspkind.nvim", 
		"williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim", 
		"neovim/nvim-lspconfig",
        'neovim/nvim-lspconfig', 
		'hrsh7th/cmp-nvim-lsp', 
		'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path', 
		'hrsh7th/cmp-cmdline', 
		'hrsh7th/nvim-cmp', 
		{
            'luozhiya/fittencode.nvim',
            config = function() require('fittencode').setup() end
        }
    })
end
InitPlugin()

vim.opt.termguicolors = true
require("bufferline").setup {}
require("language")
require("keymap")
require("plugins")
require("vimconfig")
require("mytools")

vim.g.rainbow_active = 1

