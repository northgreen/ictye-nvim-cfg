local M = {}

---@param num integer
---@return boolean is buf a file
function M.buf_is_file(num)
	if num == nil then num = 0 end
    local buf_type = vim.bo[num].buftype

    local whitelisted_buf_type = {"", "acwrite"}
    local is_in_whitelist = false
    for _, wtype in ipairs(whitelisted_buf_type) do
        if buf_type == wtype then
            is_in_whitelist = true
            break
        end
    end
    if not is_in_whitelist then return false end

    return true
end

return M
