return function ()
	local ts_utils = require 'nvim-treesitter.ts_utils'
    local nazrin = require 'global.ui_util.nazrin.nazrin'

	local lang = nazrin.get_file_type()
    local t_node = ts_utils.get_node_at_cursor()
    local out =' '.. vim.fn.expand('%:t')

    if t_node then
        local node = t_node
        local l = nazrin.get_cursor_location(
                      lang, node,
                      vim.api.nvim_get_current_buf())
        out = '' .. nazrin.format_location(l, '') .. '' .. out
    end
    return out
end
