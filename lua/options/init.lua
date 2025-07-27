local option = {}

_G.options = option

option.ui = require	'options.ui'
option.git = require 'options.gitpull_cfg'
option.env = require 'global.env_assessment'
option.language = require 'options.language'


_G.options.env_var = {
	vscode = vim.g.vscode,
	firenvim = vim.g.started_by_firenvim
}

