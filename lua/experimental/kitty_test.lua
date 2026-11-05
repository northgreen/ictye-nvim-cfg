-- Experimental Kitty bridge for :terminal (Neovim 0.12+).
-- Load with :lua require('experimental.kitty_test').setup(); inspect :KittyPassthroughStatus.
-- OSC/DCS/APC travel through TermRequest; CSI keyboard negotiation remains owned
-- by Nvim. This is not a replacement for a terminal emulator or a security boundary.
local M = {}
local ESC, ST = '\27', '\27\\'
local ns = vim.api.nvim_create_namespace('kitty_term_passthrough')
local group = vim.api.nvim_create_augroup('kitty_term_passthrough', { clear = true })
local states, routes = {}, {}
local next_id = 1700000000
local osc_codes = { ['21'] = true, ['22'] = true, ['66'] = true, ['72'] = true,
    ['99'] = true, ['5113'] = true, ['5522'] = true, ['30001'] = true, ['30101'] = true }
local stats = { sent = 0, replies = 0, hidden = 0, ambiguous = 0, errors = 0 }

local function allocate()
    next_id = next_id + 1
    return next_id
end

local function state(buf)
    if not states[buf] then states[buf] = { images = {}, placements = {} } end
    return states[buf]
end

local function wrap_tmux(seq)
    if vim.env.TMUX and vim.env.TMUX ~= '' then
        return ESC .. 'Ptmux;' .. seq:gsub(ESC, ESC .. ESC) .. ST
    end
    return seq
end

local function send(seq)
    vim.api.nvim_ui_send(wrap_tmux(seq))
    stats.sent = stats.sent + 1
end

local function graphics(seq)
    if seq:sub(1, 3) ~= ESC .. '_G' then return end
    local body = seq:sub(4):gsub(ESC .. '\\$', '')
    local controls, payload = body:match('^([^;]*);(.*)$')
    controls = controls or body
    local fields = {}
    for key, value in controls:gmatch('([%a])=([^,]+)') do fields[key] = value end
    return fields, controls, payload
end

-- Replace only selected fields: preserve action, transport, payload and unknown keys.
local function packet(controls, payload, replacements)
    local seen, parts = {}, {}
    for part in controls:gmatch('[^,]+') do
        local key = part:match('^(%a)=')
        local value = replacements[key]
        parts[#parts + 1] = value and key .. '=' .. value or part
        if key then seen[key] = true end
    end
    for _, key in ipairs({ 'i', 'p', 'C' }) do
        if replacements[key] and not seen[key] then parts[#parts + 1] = key .. '=' .. replacements[key] end
    end
    return ESC .. '_G' .. table.concat(parts, ',') .. (payload ~= nil and ';' .. payload or '') .. ST
end

local function cell_to_byte(buf, row, cell)
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ''
    local width, offset = 0, 0
    for char in line:gmatch('[%z\1-\127\194-\244][\128-\191]*') do
        local size = vim.fn.strdisplaywidth(char, width)
        if width + size > cell then return offset, cell - width end
        width, offset = width + size, offset + #char
    end
    return offset, math.max(cell - width, 0)
end

local function source_position(buf, cursor)
    if not vim.api.nvim_buf_is_valid(buf) or cursor[1] < 1 then return end
    local wins = vim.fn.win_findbuf(buf)
    local current = vim.api.nvim_get_current_win()
    -- A buffer can appear twice: prefer its focused view, otherwise the first
    -- visible view in this tab. Never use an unrelated current window.
    table.sort(wins, function(a, b) return a == current and b ~= current end)
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage() then
            local byte, extra = cell_to_byte(buf, cursor[1], cursor[2])
            local pos = vim.fn.screenpos(win, cursor[1], byte + 1)
            pos.col = pos.col + extra
            local info = vim.fn.getwininfo(win)[1]
            local top, left = info.winrow, info.wincol + info.textoff
            if pos.row >= top and pos.row < top + info.height
                and pos.col >= left and pos.col < info.wincol + info.width then
                return { row = pos.row, col = pos.col, bottom = top + info.height - 1,
                    right = info.wincol + info.width - 1, win = win }
            end
        end
    end
end

local function positioned(seq, pos)
    -- DECSC/DECRC preserve Nvim's cursor; do not change the graphics action.
    return ESC .. '7' .. string.format(ESC .. '[%d;%dH', pos.row, pos.col) .. seq .. ESC .. '8'
end

local function route_key(seq)
    if seq:sub(1, 3) == ESC .. '_G' then return 'graphics' end
    if seq:sub(1, 12) == ESC .. 'P@kitty-cmd' then return 'remote' end
    return seq:match('^' .. ESC .. '%](%d+);')
end

local function remember_route(key, buf)
    if not key then return end
    routes[key] = routes[key] or {}
    routes[key][buf] = vim.uv.hrtime() + 30e9
end

local function report(message)
    stats.errors = stats.errors + 1
    vim.notify('Kitty passthrough: ' .. message, vim.log.levels.WARN)
end

local function delete_placement(image, placement)
    send(ESC .. '_Ga=d,d=i,i=' .. image .. ',p=' .. placement .. ',q=2' .. ST)
end

local function hide(placement)
    if placement.visible then delete_placement(placement.image, placement.id) end
    placement.visible = false
end

local function fits(placement, pos)
    return pos and not (placement.cols and pos.col + placement.cols - 1 > pos.right)
        and not (placement.rows and pos.row + placement.rows - 1 > pos.bottom)
end

local function draw(buf, placement, initial_wire)
    if not placement.ready then return end
    local mark = vim.api.nvim_buf_get_extmark_by_id(buf, ns, placement.mark, {})
    if #mark == 0 then hide(placement); return end
    local line = vim.api.nvim_buf_get_lines(buf, mark[1], mark[1] + 1, false)[1] or ''
    local col = vim.fn.strdisplaywidth(line:sub(1, mark[2])) + (placement.extra or 0)
    local pos = source_position(buf, { mark[1] + 1, col })
    -- Cell-sized placements can be clipped by refusing to draw across a pane
    -- border. Never fall back to the outer cursor when the source is invisible.
    if not fits(placement, pos) then
        hide(placement)
        stats.hidden = stats.hidden + 1
        return
    end
    if placement.visible and placement.row == pos.row and placement.col == pos.col then return end
    hide(placement)
    send(positioned(initial_wire or placement.replay, pos))
    placement.row, placement.col, placement.visible = pos.row, pos.col, true
end

local function register_placement(buf, fields, image, cursor)
    local s = state(buf)
    local key = tostring(image) .. ':' .. (fields.p or '0')
    local old = s.placements[key]
    if old then hide(old); vim.api.nvim_buf_del_extmark(buf, ns, old.mark) end
    local id = old and old.id or allocate()
    local parts = { 'a=p', 'i=' .. image, 'p=' .. id, 'C=1', 'q=2' }
    -- Only placement controls belong in a replay, never upload/chunk controls.
    for _, k in ipairs({ 'x', 'y', 'w', 'h', 'X', 'Y', 'c', 'r', 'z', 'U' }) do
        if fields[k] then parts[#parts + 1] = k .. '=' .. fields[k] end
    end
    local byte, extra = cell_to_byte(buf, cursor[1], cursor[2])
    local mark = vim.api.nvim_buf_set_extmark(buf, ns, math.max(cursor[1] - 1, 0), byte,
        { strict = false, right_gravity = false })
    local placement = { id = id, image = image, mark = mark, extra = extra, cols = tonumber(fields.c),
        rows = tonumber(fields.r), replay = ESC .. '_G' .. table.concat(parts, ',') .. ST }
    s.placements[key] = placement
    return placement
end

local function forward_graphics(ev, seq)
    local fields, controls, payload = graphics(seq)
    local s, action = state(ev.buf), fields.a or 't'
    if action == 'd' then
        local selector = fields.d or 'a'
        if selector ~= 'a' and selector ~= 'A' and selector ~= 'i' and selector ~= 'I' then
            report('delete selector d=' .. selector .. ' is not implemented; nothing deleted')
            return
        end
        if (selector == 'i' or selector == 'I') and not fields.i then
            report('delete by image ID requires i='); return
        end
        -- Deletions are scoped to this terminal; never delete another pane's images.
        for key, p in pairs(s.placements) do
            if (not fields.i or s.images[fields.i] == p.image)
                and (not fields.p or key:match(':(%d+)$') == fields.p) then
                hide(p)
                vim.api.nvim_buf_del_extmark(ev.buf, ns, p.mark)
                s.placements[key] = nil
            end
        end
        if selector == 'A' or selector == 'I' then
            for child, image in pairs(s.images) do
                if not fields.i or child == fields.i then
                    local in_use = false
                    for _, p in pairs(s.placements) do
                        if p.image == image then in_use = true; break end
                    end
                    -- Uppercase deletion may free data only after the final
                    -- placement is gone; another p= can share this image.
                    if not in_use then
                        send(ESC .. '_Ga=d,d=I,i=' .. image .. ',q=2' .. ST)
                        s.images[child] = nil
                    end
                end
            end
        end
        -- TODO: implement source-rectangle/z-index delete selectors.
        return
    end
    if fields.I then
        report('image-number addressing (I=) is not virtualized; use i= in this experiment')
        return
    end
    local child_id = fields.i or (s.upload and s.upload.child_id) or '0'
    s.images[child_id] = s.images[child_id] or allocate()
    local image = s.images[child_id]
    local continuation = s.upload ~= nil
    local upload = s.upload or { fields = fields, cursor = ev.data.cursor, child_id = child_id }
    if not upload.placement and (action == 'p' or action == 'T') then
        upload.placement = register_placement(ev.buf, fields, image, ev.data.cursor)
    end
    if fields.m == '1' then s.upload = upload else s.upload = nil end
    local placement = upload.placement
    if placement then placement.ready = fields.m ~= '1' end
    -- Only the first chunk may carry upload/placement metadata. A later i=/p=
    -- turns continuation packets into a different transfer on some terminals.
    local replacement = continuation and {} or { i = tostring(image) }
    if placement and not continuation then replacement.p, replacement.C = tostring(placement.id), '1' end
    local wire = packet(controls, payload, replacement)
    -- Always separate uploading from placing. A pane can disappear between
    -- chunks; completing an a=T upload there would draw at Nvim's outer cursor.
    if action == 'T' then wire = wire:gsub('a=T', 'a=t', 1) end
    if action ~= 'p' then send(wire) end
    if placement and placement.ready then
        -- Kitty places at the final chunk's cursor, not the initial chunk's.
        local cursor = ev.data.cursor
        local byte, extra = cell_to_byte(ev.buf, cursor[1], cursor[2])
        vim.api.nvim_buf_set_extmark(ev.buf, ns, math.max(cursor[1] - 1, 0), byte,
            { id = placement.mark, strict = false, right_gravity = false })
        placement.extra = extra
        draw(ev.buf, placement, action == 'p' and wire or nil)
    end
    remember_route('graphics', ev.buf)
end

local function request(ev)
    if not ev.data or type(ev.data.sequence) ~= 'string' then return end
    local seq = ev.data.sequence
    if seq:sub(1, 3) == ESC .. '_G' then forward_graphics(ev, seq); return end
    local key = route_key(seq)
    -- Kitty's private string protocols, not shell titles/OSC7/OSC133 or Nvim's
    -- palette probes. OSC52 is consumed internally and never reaches this hook.
    if key ~= 'remote' and not osc_codes[key] then return end
    local wire = seq .. (ev.data.terminator or ST)
    if key == '66' then
        local pos = source_position(ev.buf, ev.data.cursor)
        if not pos then stats.hidden = stats.hidden + 1; return end
        wire = positioned(wire, pos)
        -- TODO: reserve the text's occupied cells inside libvterm; without that
        -- OSC66 is an overlay and cannot survive arbitrary Nvim redraws.
    end
    send(wire)
    remember_route(key, ev.buf)
end

local function response(ev)
    local seq = ev.data and ev.data.sequence
    if type(seq) ~= 'string' then return end
    local key = route_key(seq)
    if not key then return end
    local owner, child_id
    if key == 'graphics' then
        local host_id = seq:match('[,G]i=(%d+)')
        for buf, s in pairs(states) do
            for child, host in pairs(s.images) do
                if tostring(host) == host_id then owner, child_id = buf, child end
            end
        end
        if child_id then
            seq = seq:gsub('([,G])i=%d+', '%1i=' .. child_id, 1)
            local host_p = seq:match('[,G]p=(%d+)')
            for placement_key, p in pairs(states[owner].placements) do
                if tostring(p.id) == host_p then
                    seq = seq:gsub('([,G])p=%d+', '%1p=' .. placement_key:match(':(%d+)$'), 1)
                end
            end
        end
    else
        local now = vim.uv.hrtime()
        for buf, deadline in pairs(routes[key] or {}) do
            if deadline > now and vim.api.nvim_buf_is_valid(buf) then
                if owner then stats.ambiguous = stats.ambiguous + 1; return end
                owner = buf
            end
        end
    end
    if not owner or not vim.api.nvim_buf_is_valid(owner) then return end
    if seq:sub(-2) ~= ST and seq:sub(-1) ~= '\7' then seq = seq .. ST end
    local channel = vim.bo[owner].channel
    if channel > 0 then vim.api.nvim_chan_send(channel, seq); stats.replies = stats.replies + 1 end
end

local function refresh()
    for buf, s in pairs(states) do
        if vim.api.nvim_buf_is_valid(buf) then
            for _, placement in pairs(s.placements) do draw(buf, placement) end
        end
    end
end

local function cleanup(buf)
    for _, owners in pairs(routes) do owners[buf] = nil end
    local s = states[buf]
    if not s then return end
    for _, p in pairs(s.placements) do hide(p) end
    for _, image in pairs(s.images) do send(ESC .. '_Ga=d,d=I,i=' .. image .. ',q=2' .. ST) end
    states[buf] = nil
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end
end

function M.setup()
    vim.api.nvim_clear_autocmds({ group = group })
    vim.api.nvim_create_autocmd('TermRequest', { group = group, callback = function(ev)
        local ok, err = pcall(request, ev)
        if not ok then report(tostring(err)) end
    end, desc = 'Experimental Kitty string-protocol bridge' })
    vim.api.nvim_create_autocmd('TermResponse', { group = group, callback = response })
    vim.api.nvim_create_autocmd({ 'WinScrolled', 'WinResized', 'VimResized', 'BufWinEnter', 'TabEnter' },
        { group = group, callback = function() vim.schedule(refresh) end })
    vim.api.nvim_create_autocmd({ 'BufWinLeave', 'WinClosed' }, { group = group,
        callback = function() vim.schedule(refresh) end })
    vim.api.nvim_create_autocmd({ 'TermClose', 'BufWipeout' }, { group = group,
        callback = function(ev) cleanup(ev.buf) end })
    vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = M.stop })
    vim.api.nvim_create_user_command('KittyPassthroughStatus', function()
        vim.print({ stats = stats, csi = 'owned by Nvim; not transparently forwarded',
            osc52 = 'handled by Nvim clipboard provider', limitations = {
                'I= addressing, virtual placements and selective delete geometry are TODO',
                'auto-sized images are not clipped to pane bounds; explicit c/r hide when overflowing',
                'OSC66 is an overlay; global palette/pointer/notification effects are terminal-wide',
            } })
    end, { force = true })
    vim.api.nvim_create_user_command('KittyPassthroughStop', M.stop, { force = true })
    return M
end

function M.stop()
    vim.api.nvim_clear_autocmds({ group = group })
    for buf in pairs(states) do cleanup(buf) end
    routes = {}
end

-- Exposed for byte-level and real terminal-event regression tests.
M._test = { wrap_tmux = wrap_tmux, graphics = graphics, packet = packet,
    source_position = source_position, positioned = positioned, request = request,
    response = response, refresh = refresh, states = states, stats = stats,
    cleanup = cleanup, cell_to_byte = cell_to_byte, routes = function() return routes end }
return M.setup()
