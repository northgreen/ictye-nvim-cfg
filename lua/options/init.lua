local option = {}

option.ui = require	'options.ui'

option.env = require 'global.env_assessment'

_G.options = option

_G.options.env_var = {
	vscode = vim.g.vscode,
	firenvim = vim.g.started_by_firenvim
}

