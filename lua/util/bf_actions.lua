local M = {}

--- set the q key for quit currect buffer
function M.q_exit()
    vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = true})
    vim.keymap.set("n", "<Esc>", "<Cmd>quit<CR>", { buffer = true })
end

--- return true if filetype has been actioned before
--- it will be set to true after called
--- @return boolean is actioned
function M.filetype_actioned()
    if _G.configed[vim.bo.filetype] then
        return true
    end
    _G.configed[vim.bo.filetype] = true
    return false
end

return M
