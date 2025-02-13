local M = {}

function M.ploadmodule(name)
    local ok, mod = pcall(require, name)
    if not ok then
        vim.notify('Error: Failed to load module: ' .. name .. '\n' .. mod,
                   vim.log.levels.ERROR)
		return nil
    end
	return mod
end

return M
