-- Tabline redraws arrive in bursts while LSP diagnostics load many buffers.
local wrapped = setmetatable({}, { __mode = 'k' })
return function(render)
    if wrapped[render] then return render end
    local cached, last_render, pending = nil, 0, false
    local function throttled()
        local now = vim.uv.hrtime() / 1e6
        if cached and now - last_render < 100 then
            if not pending then
                pending = true
                vim.defer_fn(function()
                    pending = false
                    vim.cmd.redrawtabline()
                end, 100)
            end
            return unpack(cached)
        end
        cached = { render() }
        last_render = vim.uv.hrtime() / 1e6
        return unpack(cached)
    end
    wrapped[throttled] = true
    return throttled
end
