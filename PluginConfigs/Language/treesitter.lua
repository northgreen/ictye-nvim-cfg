local configs = require("nvim-treesitter.configs")

require 'nvim-treesitter.install'.prefer_git = false
require 'nvim-treesitter.install'.compilers = {"clang" , "gcc"}

configs.setup({
    ensure_installed = {
        "c", "lua", "vim", "vimdoc","markdown","json"
    },
    sync_install = false,
    highlight = {enable = true},
    indent = {enable = true},
	modules = {},
	auto_install = true,
	ignore_install = {}
})

