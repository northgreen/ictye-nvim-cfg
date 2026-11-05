-- Real Kitty TUI test (not --headless/-l). From this repo, run:
-- nvim -u NONE -c 'autocmd VimEnter * ++once lua vim.defer_fn(function() dofile("tests/unit/kitty_passthrough_host.lua") end, 300)'
-- Result: $KITTY_TEST_RESULT or /tmp/kitty-passthrough-host.json.
-- The test owns and closes only this Nvim instance. No blocking vim.wait():
-- a TUI must return to its input loop to process the host's TermResponse bytes.
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local ESC, ST = '\27', '\27\\'
local output = vim.env.KITTY_TEST_RESULT or '/tmp/kitty-passthrough-host.json'
local child_result = vim.fn.tempname()
local original_send = vim.api.nvim_ui_send
local result = { ok = false, wire = {}, host_responses = {}, warnings = {} }
local job, bridge
local done = false
vim.api.nvim_ui_send = function(seq)
    result.wire[#result.wire + 1] = seq
    original_send(seq)
end
vim.notify = function(msg) result.warnings[#result.warnings + 1] = tostring(msg) end
bridge = require('experimental.kitty_test')
vim.api.nvim_create_autocmd('TermResponse', { callback = function(ev)
    result.host_responses[#result.host_responses + 1] = ev.data.sequence
end })

local function finish(err)
    if done then return end
    done = true
    result.ok, result.error = err == nil, err and tostring(err) or nil
    if job then pcall(vim.fn.jobstop, job) end
    bridge.stop()
    vim.fn.delete(child_result)
    vim.fn.writefile({ vim.json.encode(result) }, output)
    vim.cmd('qa!')
end

local function later(fn, delay)
    vim.defer_fn(function()
        if done then return end
        local ok, err = xpcall(fn, debug.traceback)
        if not ok then finish(err) end
    end, delay or 100)
end

local python = [[import os,tty,select,time,json,sys
 tty.setraw(0)
 def exchange(packet):
  os.write(1,packet)
  data=b''
  deadline=time.monotonic()+5
  while time.monotonic()<deadline:
   if select.select([0],[],[],0.1)[0]:
    data+=os.read(0,8192)
    if b'\x1b\\' in data: return data.decode('ascii','backslashreplace')
  return data.decode('ascii','backslashreplace')
 replies=[exchange(b'\x1b_Ga=q,i=31,f=24,s=1,v=1;AAAA\x1b\\')]
 os.write(1,b'first line\r\nsecond line\r\n')
 replies.append(exchange(b'\x1b_Ga=T,i=41,p=2,f=24,s=2,v=1,c=4,r=3,m=1;/wAA\x1b\\'+b'\x1b_Gm=0;/wAA\x1b\\'))
 open(sys.argv[1],'w').write(json.dumps(replies))
 deadline=time.monotonic()+10
 while time.monotonic()<deadline:
  if select.select([0],[],[],0.1)[0] and b'x' in os.read(0,1024): break
 ]]
python = python:gsub('\n ', '\n')

local source, buf, placement
local function verify_replies()
    local replies = vim.json.decode(table.concat(vim.fn.readfile(child_result), '\n'))
    result.replies = replies
    assert(replies[1] == ESC .. '_Gi=31;OK' .. ST, vim.inspect(replies))
    assert(replies[2] == ESC .. '_Gi=41,p=2;OK' .. ST, vim.inspect(replies))
    for _, p in pairs(bridge._test.states[buf].placements) do placement = p end
    assert(placement and placement.visible, 'placement not visible')
    local pos = vim.fn.screenpos(source, 3, 1)
    assert(placement.row == pos.row and placement.col == pos.col, 'wrong source pane position')
    result.before = { row = placement.row, col = placement.col }
    vim.api.nvim_win_close(source, true)
    later(function()
        assert(not placement.visible, 'hidden pane retained host placement')
        vim.api.nvim_set_current_buf(buf)
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.signcolumn = 'no'
        vim.cmd('redraw')
        bridge._test.refresh()
        assert(placement.visible, 'placement not restored')
        result.after = { row = placement.row, col = placement.col }
        -- The old pane had gutters; the replacement view has different origin.
        assert(result.before.col ~= result.after.col, 'test did not relocate the image')
        assert(#result.warnings == 0, vim.inspect(result.warnings))
        vim.api.nvim_chan_send(job, 'x')
        later(function() finish() end, 200)
    end, 100)
end

local polls = 0
local function await_child()
    polls = polls + 1
    if vim.fn.filereadable(child_result) == 1 then verify_replies(); return end
    assert(polls < 130, 'child protocol exchanges timed out')
    later(await_child)
end

later(function()
    vim.cmd('vsplit')
    source = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    job = vim.fn.jobstart({ 'python3', '-c', python, child_result }, { term = true })
    assert(job > 0, 'PTY failed to start')
    vim.wo.number = true
    vim.wo.signcolumn = 'yes:2'
    vim.cmd('wincmd l')
    vim.cmd('enew')
    vim.cmd('redraw')
    later(await_child)
end)
