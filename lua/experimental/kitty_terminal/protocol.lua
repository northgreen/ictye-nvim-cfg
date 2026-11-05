-- Queries terminate here, in Lua, with dimensions of the child viewport.
-- Never let child keyboard/alternate-screen modes alter the outer Nvim TUI.
-- csi 返回 true 表示已消费，false 允许 parser 更新影子屏幕并镜像到内部 terminal。
-- 查询应答走 term:send（子 PTY），不走 term:display 或 term:host_send。
local M = {}
local ESC, ST = '\27', '\27\\'
local bit = require('bit')
local ansi = { '#000000', '#cd0000', '#00cd00', '#cdcd00', '#0000ee', '#cd00cd', '#00cdcd', '#e5e5e5',
    '#7f7f7f', '#ff0000', '#00ff00', '#ffff00', '#5c5cff', '#ff00ff', '#00ffff', '#ffffff' }
function M.color(n)
    if n < 16 then return ansi[n + 1] end
    if n >= 232 then local v = 8 + 10 * (n - 232); return string.format('#%02x%02x%02x', v, v, v) end
    local values = { 0, 95, 135, 175, 215, 255 }
    n = n - 16
    return string.format('#%02x%02x%02x', values[math.floor(n / 36) + 1], values[math.floor(n / 6) % 6 + 1], values[n % 6 + 1])
end
local function rgb(hex)
    local r, g, b = hex:match('#(%x%x)(%x%x)(%x%x)')
    return string.format('rgb:%04x/%04x/%04x', tonumber(r, 16) * 257, tonumber(g, 16) * 257, tonumber(b, 16) * 257)
end
local function hex(s) return (s:gsub('.', function(c) return string.format('%02x', c:byte()) end)) end
local function unhex(s) return (s:gsub('%x%x', function(c) return string.char(tonumber(c, 16)) end)) end

function M.csi(term, body, final)
    local s = term.screen
    if final == 'n' and (body == '6' or body == '?6') then
        local row = s.modes.origin and (s.row - s.top + 1) or s.row
        term:send(string.format(ESC .. '[%s%d;%dR', body:sub(1, 1) == '?' and '?' or '', row, s.col)); return true
    end
    if final == 'n' and body == '5' then term:send(ESC .. '[0n'); return true end
    if final == 'c' then
        term:send(body:sub(1, 1) == '>' and ESC .. '[>1;1;0c' or ESC .. '[?62;22c'); return true
    end
    if final == 'q' and body == '>' then term:send(ESC .. 'P>|kitty-lua(0.1)' .. ST); return true end
    if final == 't' then
        local n = tonumber(body)
        local response = ({ [14] = { 4, s.rows * term.cell_height, s.cols * term.cell_width },
            [16] = { 6, term.cell_height, term.cell_width }, [18] = { 8, s.rows, s.cols },
            [19] = { 9, s.rows, s.cols } })[n]
        if response then term:send(ESC .. '[' .. table.concat(response, ';') .. 't'); return true end
    end
    if final == 'u' and body:match('^[?>=<]') then
        -- 25 = 消歧(1) + 全键报告(8) + 关联文本(16)；不宣称 Nvim 未提供的释放事件。
        local op, rest = body:sub(1, 1), body:sub(2)
        local flags, mode = rest:match('^(%d*);?(%d*)$')
        flags, mode = tonumber(flags) or 1, tonumber(mode) or 1
        term.keyboard_stack = term.keyboard_stack or {}
        if op == '?' then term:send(ESC .. '[?' .. (term.keyboard_flags or 0) .. 'u')
        elseif op == '>' then
            term.keyboard_stack[#term.keyboard_stack + 1] = term.keyboard_flags or 0
            term.keyboard_flags = bit.band(flags, 25)
        elseif op == '<' then
            for _ = 1, math.min(flags, #term.keyboard_stack) do term.keyboard_flags = table.remove(term.keyboard_stack) end
        elseif mode == 1 then term.keyboard_flags = bit.band(flags, 25)
        elseif mode == 2 then term.keyboard_flags = bit.band(bit.bor(term.keyboard_flags or 0, flags), 25)
        elseif mode == 3 then term.keyboard_flags = bit.band(term.keyboard_flags or 0, bit.bnot(flags)) end
        return true
    end
    if final == 'p' and body:match('^%?%d+%$$') then
        local mode = tonumber(body:match('%d+'))
        local known = { [1] = 'app_cursor', [6] = 'origin', [7] = 'wrap', [25] = 'cursor_visible',
            [1000] = 'mouse', [1002] = 'mouse', [1003] = 'mouse', [1006] = 'mouse_sgr', [1016] = 'mouse_pixel', [2004] = 'bracketed_paste' }
        local name = known[mode]
        term:send(ESC .. '[?' .. mode .. ';' .. (name and (s.modes[name] and '1' or '2') or '0') .. '$y')
        return true
    end
    return false
end

function M.string(term, kind, body, terminator)
    if kind == 'dcs' and body == '=kitty-lua-ready' then term:ready(); return end
    if kind == 'apc' and body:sub(1, 1) == 'G' then term.graphics:request(body:sub(2)); return end
    if kind == 'dcs' and body:sub(1, 2) == '+q' then
        local capabilities = { TN = 'xterm-kitty', Co = '256', RGB = '8',
            Ms = ESC .. ']52;%p1%s;%p2%s\7' }
        for name in body:sub(3):gmatch('[^;]+') do
            local value = capabilities[unhex(name)]
            term:send(ESC .. 'P' .. (value and '1' or '0') .. '+r' .. name .. (value and '=' .. hex(value) or '') .. ST)
        end
        return
    end
    if kind == 'dcs' and body:sub(1, 2) == '$q' then
        local query = body:sub(3)
        local value = query == 'm' and '0m' or (query == 'r' and ('1;' .. term.screen.rows .. 'r'))
        term:send(ESC .. 'P' .. (value and '1' or '0') .. '$r' .. (value or query) .. ST); return
    end
    if kind ~= 'osc' then term:host_protocol(kind, body, terminator); return end
    local code, data = body:match('^(%d+);(.*)$')
    if code == '0' or code == '2' then term.title = data; return end
    -- 目录/提示符/超链接元数据不应修改外层 Nvim 所在 shell 的状态。
    if code == '7' or code == '133' or code == '8' then return end
    if code == '4' then
        local index, value = data:match('^(%d+);(.*)$')
        index = tonumber(index)
        if index and index < 256 and value == '?' then
            term:send(ESC .. ']4;' .. index .. ';' .. rgb(term.palette[index] or M.color(index)) .. ST)
        elseif index and value and value:match('^#%x%x%x%x%x%x$') then
            term.palette[index] = value
            if term.display then term:display(ESC .. ']4;' .. index .. ';' .. value .. ST) end
        end
        return
    end
    if code == '10' or code == '11' or code == '12' then
        local color = code == '11' and term.background or term.foreground
        if data == '?' then term:send(ESC .. ']' .. code .. ';' .. rgb(color) .. ST) end
        return
    end
    if code == '52' then
        -- 远程 shell 输出也能发 OSC52：读宿主剪贴板必须显式授权，拒绝时仍回复空值。
        local selection, text = data:match('^([^;]*);(.*)$')
        if text == '?' then
            local value = ''
            if term.options and term.options.allow_clipboard_read then
                local ok, clipboard = pcall(vim.fn.getreg, '+')
                if ok and type(clipboard) == 'string' then value = clipboard
                elseif ok and type(clipboard) == 'table' then value = table.concat(clipboard, '\n') end
            else
                term.stats.clipboard_reads_denied = (term.stats.clipboard_reads_denied or 0) + 1
            end
            term:send(ESC .. ']52;' .. selection .. ';' .. vim.base64.encode(value) .. ST)
        elseif text then
            local ok, decoded = pcall(vim.base64.decode, text)
            if ok then pcall(vim.fn.setreg, '+', decoded) end
        end
        return
    end
    if code == '66' then
        local metadata, text = data:match('^([^;]*);(.*)$')
        if text then
            term:host_protocol(kind, body, terminator, true)
            local scale = tonumber(metadata:match('s=(%d+)')) or 1
            local width = tonumber(metadata:match('w=(%d+)')) or vim.fn.strdisplaywidth(text) * scale
            -- Reserve the cells in our own grid, so later redraws never collapse
            -- the cursor displacement as happens in a libvterm passthrough.
            term.screen:write(string.rep(' ', math.min(width, term.screen.cols)))
        end
        return
    end
    term:host_protocol(kind, body, terminator)
end
return M
