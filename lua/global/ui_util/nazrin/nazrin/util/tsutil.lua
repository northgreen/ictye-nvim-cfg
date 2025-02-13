local M = {}

--- get content form buf of node
--- @param node TSNode
--- @param buf integer|string
--- @return string
function M.get_name(node, buf)
    local vim_ts = vim.treesitter
    return vim_ts.get_node_text(node, buf)
end

--- get content form buf of node,but return nil if node is nil
--- @param node TSNode
--- @param buf integer|string
--- @return string|nil
function M.p_get_name(node, buf)
    assert(node and buf, "node and buf should not be nil")
    local ret = M.get_name(node, buf)
    if ret then
        return ret
    else
        return nil
    end
end

return M
