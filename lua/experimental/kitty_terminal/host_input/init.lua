-- 需要松键事件时才启用隐藏 Kitty 输入窗口；普通终端仍使用原生 on_input。
local M = {}
local bit = require('bit')
local Input = require('experimental.kitty_terminal.input')
local helper = vim.fs.joinpath(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)), 'bridge.py')
local focused = true

local function command(state, args, callback)
    local argv = { 'kitten', '@', '--to', state.address, 'kitten', '--match', 'id:' .. state.window, helper }
    vim.list_extend(argv, args)
    vim.system(argv, { text = true, timeout = 1500 }, function(result)
        vim.schedule(function() callback(result) end)
    end)
end

local function answer(term)
    local state = term.host_input
    if not state or not state.ready then return end
    term.keyboard_error = nil
    term.keyboard_flags = bit.band(term.keyboard_requested or 0, 27)
    state.peer:write(term.keyboard_flags .. '\n')
    for _ = 1, state.queries or 0 do term:send('\27[?' .. term.keyboard_flags .. 'u') end
    state.queries = 0
end

function M.capture(term)
    local state = term.host_input
    if not state or not state.ready or state.closed or state.busy then return end
    local wanted = bit.band(term.keyboard_requested or 0, 2) ~= 0 and term.capture and focused
        and vim.api.nvim_get_current_buf() == term.buf
    wanted = not not wanted
    if wanted == state.captured then return end
    if not wanted then
        local released = Input.release(term)
        if bit.band(term.keyboard_requested or 0, 2) ~= 0 then term:send(released) end
    end
    state.capture_wanted = wanted
    state.busy = true
    command(state, { 'capture', state.overlay, wanted and '1' or '0' }, function(result)
        state.busy = false
        if state.closed then return end
        if result.code ~= 0 then
            term.keyboard_error = 'Kitty keyboard capture: ' .. (result.stderr or tostring(result.code))
            M.close(term)
            return
        end
        state.captured = wanted
        M.capture(term)
    end)
end

function M.close(term)
    local state = term.host_input
    if not state or state.closed then return end
    local released = Input.release(term)
    if not term.closed and not term.exited and released ~= '' then term:send(released) end
    state.captured, state.capture_wanted, state.ready = false, false, false
    state.closed = true
    term.keyboard_flags = bit.band(term.keyboard_requested or 0, 25)
    for _, handle in pairs({ peer = state.peer, server = state.server }) do
        if handle and not handle:is_closing() then handle:close() end
    end
    if state.path then vim.uv.fs_unlink(state.path) end
    if state.directory then vim.uv.fs_rmdir(state.directory) end
    if state.overlay then command(state, { 'stop', state.overlay }, function() end) end
    for _ = 1, state.queries or 0 do term:send('\27[?' .. term.keyboard_flags .. 'u') end
    state.queries = 0
end

local function fail(term, message)
    term.keyboard_error = message
    M.close(term)
end

local function start(term)
    local address, window = vim.env.KITTY_LISTEN_ON, vim.env.KITTY_WINDOW_ID
    if not address or address == '' or not window or not window:match('^%d+$')
        or (vim.env.TMUX and vim.env.TMUX ~= '')
        or vim.fn.executable('kitten') ~= 1 or vim.fn.executable('python3') ~= 1 then
        term.keyboard_error = '真实松键事件需要本地 Kitty 远控、python3 且不经过 tmux'
        return
    end
    local state = { address = address, window = window, captured = false, queries = 0 }
    term.host_input = state
    state.directory = vim.fn.tempname()
    assert(vim.fn.mkdir(state.directory, '', 448) == 1, 'cannot create Kitty input socket directory')
    state.path = state.directory .. '/input.sock'
    state.server = assert(vim.uv.new_pipe(false))
    assert(state.server:bind(state.path))
    vim.uv.fs_chmod(state.path, 384)
    assert(state.server:listen(1, function(err)
        if err or state.closed then return end
        local peer = assert(vim.uv.new_pipe(false))
        state.server:accept(peer)
        -- 只接受当前 helper 的单个连接，socket 所在目录仅当前用户可访问。
        state.server:close()
        state.server = nil
        state.peer = peer
        peer:read_start(function(read_error, bytes)
            vim.schedule(function()
                if state.closed then return end
                if read_error or not bytes then
                    fail(term, 'Kitty input bridge disconnected: ' .. tostring(read_error or 'EOF'))
                    return
                end
                if not state.connected then
                    if bytes:sub(1, 1) ~= '\0' then fail(term, 'invalid Kitty input handshake'); return end
                    state.connected = true
                    bytes = bytes:sub(2)
                    state.ready = state.overlay ~= nil
                    if state.ready then answer(term); M.capture(term) end
                end
                if bytes ~= '' and state.capture_wanted and term.capture and focused then
                    local output, leave = Input.raw(term, bytes)
                    term:send(output)
                    if leave then vim.cmd('stopinsert') end
                end
            end)
        end)
    end))
    command(state, { 'start', helper, state.path }, function(result)
        local overlay = (result.stdout or ''):match('^%s*(%d+)%s*$')
        if overlay then state.overlay = overlay end
        if state.closed then
            if overlay then command(state, { 'stop', overlay }, function() end) end
            return
        end
        if result.code ~= 0 or not overlay then
            fail(term, 'Kitty input bridge: ' .. (result.stderr or result.stdout or tostring(result.code)))
            return
        end
        state.ready = state.connected
        if state.ready then answer(term); M.capture(term) end
    end)
    vim.defer_fn(function()
        if not state.closed and not state.ready then fail(term, 'Kitty input bridge readiness timed out') end
    end, 2500)
end

function M.request(term, flags)
    term.keyboard_requested = flags
    term.keyboard_flags = bit.band(flags, 25)
    if bit.band(flags, 2) ~= 0 and (not term.host_input or term.host_input.closed) then
        local ok, err = pcall(start, term)
        if not ok then fail(term, 'Kitty input bridge: ' .. tostring(err)) end
    end
    if term.host_input and term.host_input.ready and not term.host_input.closed then
        term.keyboard_flags = bit.band(flags, 27)
        term.host_input.peer:write(term.keyboard_flags .. '\n')
        M.capture(term)
    end
end

function M.query(term)
    local state = term.host_input
    if state and not state.closed and not state.ready then state.queries = state.queries + 1; return end
    term:send('\27[?' .. (term.keyboard_flags or 0) .. 'u')
end

function M.focus(term, value)
    focused = value
    if not value then term:send(Input.release(term)) end
    if term.screen.modes.focus then term:send(value and '\27[I' or '\27[O') end
    M.capture(term)
end

return M
