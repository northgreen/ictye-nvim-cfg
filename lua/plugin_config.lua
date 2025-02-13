-- This file is used to load the configurations for the installed plugin in the nvim configuration directory.
require('plugin.require.language.language_config')

vim.g.firenvim_config = {
    globalSettings = {alt = "all", selector = ""},
    localSettings = {
        [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "",
            takeover = "never"
        },
		['https?://.+\\.github\\.com/.+'] = {
			selector = "textarea",
			priority = 1,
			takeover = "always"
		}
    }
}
