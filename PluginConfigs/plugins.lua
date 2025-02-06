return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            require('catppuccin').setup({ flavour = "frappe" })
        end
    },
    {
		'neoclide/coc.nvim',
		branch = 'release'
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function() require("nvim-tree").setup({}) end
    },
    'nvim-tree/nvim-web-devicons',
    "Yggdroot/indentLine",
    'SHougo/context_filetype.vim',
	{
		'lwis6991/gitsigns.nvim',
		config = function() require('gitsigns').setup() end
	},
    'mfussenegger/nvim-dap',
    'sbdchd/neoformat',
    'jiangmiao/auto-pairs',
    "tpope/vim-surround",
    "theHamsta/nvim-dap-virtual-text",
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        lazy = false    -- This plugin is already lazy
    },{
		"folke/which-key.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},{
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit", "LazyGitConfig", "LazyGitCurrentFile",
            "LazyGitFilter", "LazyGitFilterCurrentFile"
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = { { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" } }
    },
    "voldikss/vim-floaterm",
    'rafcamlet/nvim-luapad',
    {
        "iamcco/markdown-preview.nvim",
        cmd = {
            "MarkdownPreviewToggle", "MarkdownPreview",
            "MarkdownPreviewStop"
        },
        ft = { "markdown" },
        build = function() vim.fn "mkdp#util#install" end
    },

    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } }
            }
        }
    },
    {
        "Bilal2453/luvit-meta",
        lazy = true
    },
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
                name = "lazydev",
                group_index = 0
            })
        end
    },
    {
        'nvimdev/dashboard-nvim',
        event = 'VimEnter',
        config = require('PluginConfigs.UI.dashboard').cfg,
        dependencies = {
			{ 'nvim-tree/nvim-web-devicons' }
		}
    },
    'terryma/vim-multiple-cursors',
    {
        'pwntester/octo.nvim',
        requires = {
            'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim',
            'nvim-tree/nvim-web-devicons'
        }
    },
    "neovim/nvim-lspconfig",
    "dyng/ctrlsf.vim",
    {
        'ray-x/navigator.lua',
        requires = {
            { 'ray-x/guihua.lua',     run = 'cd lua/fzy && make' },
            { 'neovim/nvim-lspconfig' }
        },
        config = function()
            -- require'navigator'.setup()
        end
    },
    {
        'stevearc/dressing.nvim',
        opts = {}
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }
    },
	{
		"onsails/lspkind.nvim",
	},
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/vim-vsnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
	'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-vsnip',
	'hrsh7th/vim-vsnip-integ',
	'jbyuki/one-small-step-for-vimkind',
    'hrsh7th/cmp-cmdline',
    {
        'luozhiya/fittencode.nvim',
		config = function() require('fittencode').setup({
			completion_mode="source"
		}) end
    },{
        'nvim-lualine/lualine.nvim',
        config = require('PluginConfigs.UI.lualine_cfg').cfg
    },{
        'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons',
        config=function ()
			require('PluginConfigs.UI.bufferline')
        end
    },{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function ()
			require('PluginConfigs.Language.treesitter')
		end
	},
	"HiPhish/rainbow-delimiters.nvim"
}
