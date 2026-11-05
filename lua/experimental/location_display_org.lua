local M = {}
--- @return string
function M.location_display()
	local ts_utils = require('nvim-treesitter.ts_utils')
    local parses = require('nvim-treesitter.parsers')
    local queries = require('nvim-treesitter.query')

    local vim_ts = vim.treesitter

    local node = ts_utils.get_node_at_cursor()
    local display = vim.fn.expand('%:t')
    local split_char = ''

    --- @param no TSNode
    --- @return string
    local function get_ast_id_name(no)
        return vim_ts.get_node_text(no, vim.api.nvim_get_current_buf())
    end

    --- @param no TSNode
    --- @return string
    local function dot_index_expression_presure(no)
        local output = get_ast_id_name(no)
        return output
    end

    if node then
        while true do
            if not node then
                break
            end
            if node:type() == 'identifier' then
                display = vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf()) .. split_char .. display
            else
                for _, child in ipairs(node:named_children()) do
                    if child:type() == 'identifier' then
                        display = vim.treesitter.get_node_text(child, vim.api.nvim_get_current_buf()) ..
                        split_char .. display
                    elseif child:type() == 'dot_index_expression' or child:type() == 'fuction_call' then
                        display = dot_index_expression_presure(child) .. split_char .. display
                    end
                end
            end
            if node:type() == 'identifier' then
				node = node:parent():parent()
			elseif node:parent() ~= 'dot_index_expression' then
				node = node:parent()
            end
        end
    end
    return '' .. display
end

return M
