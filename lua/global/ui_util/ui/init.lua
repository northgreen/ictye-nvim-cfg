local M = {}

function M.setup(lite)
    --- Select UI
    if lite then
        return
    end
    require "global.ui_util.ui.selection"
end

return M
