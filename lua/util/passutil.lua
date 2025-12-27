local M = {}

---get password by path 
---@param path string the path for the password
---@return string|nil
function M.get_password(path)
    if vim.system then
        local res = vim.system({'pass','show',path}):wait()
        if res.code == 0 then
            key,num = res.stdout:gsub("%s+$", "")
            return key
        end
    end
    return nil
end

return M
