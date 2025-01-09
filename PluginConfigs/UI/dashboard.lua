return {
    cfg = function()
        require('dashboard').setup {
            theme = "hyper",
            config = {
				header = require("plugin_config").dashboard_header,
				disable_move = true,
				shortcut = {
					{ desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
			},
			hide = {
				tabline = true,
				statusline = true,
				winbar = true,
			},
		}
	}
    end
}
