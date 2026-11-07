-- 读取当前外层 Kitty 窗口的实时颜色，不修改宿主或 Neovim 的全局主题。
local M = {}

function M.read()
    local address, window = vim.env.KITTY_LISTEN_ON, vim.env.KITTY_WINDOW_ID
    if not address or address == '' or not window or not window:match('^%d+$')
        or vim.fn.executable('kitten') ~= 1 then return nil end
    local result = vim.system({ 'kitten', '@', '--to', address, 'get-colors', '--match', 'id:' .. window },
        { text = true }):wait(500)
    if result.code ~= 0 then return nil, 'Kitty colors: ' .. (result.stderr or tostring(result.code)) end
    local colors = { palette = {} }
    for name, color in (result.stdout or ''):gmatch('([%w_]+)%s+(#%x%x%x%x%x%x)') do
        local index = tonumber(name:match('^color(%d+)$'))
        if index and index < 256 then colors.palette[index] = color
        elseif name == 'foreground' or name == 'background' or name == 'cursor' then colors[name] = color end
    end
    if not colors.foreground or not colors.background then return nil, 'Kitty colors: missing foreground/background' end
    return colors
end

function M.apply(win, colors)
    -- 按颜色复用局部高亮命名空间，不覆盖其他窗口的 Normal/NormalFloat。
    local ns = vim.api.nvim_create_namespace('kitty_lua_colors_' .. colors.foreground .. colors.background)
    for _, name in ipairs({ 'Normal', 'NormalFloat', 'EndOfBuffer', 'FloatBorder' }) do
        vim.api.nvim_set_hl(ns, name, { fg = colors.foreground, bg = colors.background })
    end
    vim.api.nvim_win_set_hl_ns(win, ns)
    vim.wo[win].winblend = 0
end

return M
