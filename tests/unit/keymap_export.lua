local MiniTest = require('mini.test')
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()
local root, output
local hotpot = vim.env.HOTPOT_PATH
if not hotpot or hotpot == '' then hotpot = vim.fn.stdpath('data') .. '/lazy/hotpot.nvim' end
vim.opt.runtimepath:append(hotpot)
local filename = 'fnl/util/keymap_export/init.fnl'
local compiled = require('hotpot.fennel')['compile-string'](
  table.concat(vim.fn.readfile(filename), '\n'), { filename = filename })

local function contents()
  return child.lua_get([[ (function()
    local file = assert(io.open(output, 'rb'))
    local result = file:read('*a'); file:close(); return result
  end)() ]])
end

local function refresh()
  child.cmd('KeymapExport')
  return contents()
end

local function enabled()
  child.lua('vim.env.NVIM_KEYMAP_EXPORT = output; assert(exporter.setup())')
end

local T = MiniTest.new_set({ hooks = {
  pre_case = function()
    root = vim.fn.tempname() .. ' keymap tests'
    output = root .. '/nested/keymaps.csv'
    child.restart({ '-u', 'NONE', '--noplugin', '-n' })
    child.lua([[vim.env.NVIM_KEYMAP_EXPORT = nil; vim.g.keymap_export = nil
      output, exporter = ..., assert(loadstring(select(2, ...)))()]], { output, compiled })
  end,
  post_case = function()
    child.stop()
    vim.fn.delete(root, 'rf')
  end,
} })

T['disabled setup has no hooks, command or output'] = function()
  eq(child.lua_get('exporter.setup()'), false)
  eq(child.lua_get("vim.fn.exists(':KeymapExport')"), 0)
  eq(child.lua_get("#vim.api.nvim_get_autocmds({event='VimLeavePre'})"), 0)
  eq(vim.fn.filereadable(output), 0)
end

T['exports CSV quoting, all modes, options and callback source'] = function()
  child.lua([[
    for _, mode in ipairs({'n','x','s','o','i','l','c','t'}) do
      vim.keymap.set(mode, '<F24>', '<Nop>', {desc='all modes'})
    end
    vim.keymap.set('n', '<F23>', '<Nop>', {desc='comma,"quote"\nsecond line', silent=true, nowait=true})
    local callback = assert(loadstring('return function() return "x" end', '@/tmp/keymap callback.lua'))()
    vim.keymap.set('i', '<F22>', callback, {desc='callback fixture', expr=true})
  ]])
  enabled()
  local csv = refresh()
  for _, mode in ipairs({'n','x','s','o','i','l','c','t'}) do
    assert(csv:find('"' .. mode .. '","<F24>"', 1, true), mode .. ' missing')
  end
  assert(csv:find('"comma,""quote""\nsecond line"', 1, true))
  assert(csv:find('"/tmp/keymap callback.lua:1"', 1, true))
  assert(csv:find('"0","1","1","1","0"', 1, true))
  assert(csv:find('"1","1","0","0","0"', 1, true))
  assert(csv:find('\r\n', 1, true))
  eq(csv, refresh())
end

T['captures buffer-local mappings without losing global mapping'] = function()
  child.lua([[
    vim.g.mapleader = ' '; vim.g.maplocalleader = ','
    vim.keymap.set('n', '<leader>fixture', '<Nop>', {desc='global fixture'})
    fixture_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(fixture_buf, '/tmp/keymap-buffer-fixture.lua')
    vim.bo[fixture_buf].filetype = 'lua'
    vim.keymap.set('n', '<localleader>fixture', '<Nop>', {buffer=fixture_buf, desc='local fixture'})
  ]])
  enabled()
  local csv = refresh()
  assert(csv:find('"global fixture","","global","0","",""', 1, true))
  assert(csv:find('"local fixture","","buffer",', 1, true))
  assert(csv:find('keymap-buffer-fixture.lua","lua"', 1, true))
  assert(csv:find('," ",","\r\n', 1, true))
  child.lua('vim.api.nvim_buf_delete(fixture_buf, {force=true})')
  assert(not refresh():find('local fixture', 1, true))
end

T['refresh reflects overwritten and removed maps, not history'] = function()
  child.lua("vim.keymap.set('n', '<F24>', '<Nop>', {desc='old fixture'})")
  enabled()
  assert(refresh():find('old fixture', 1, true))
  child.lua("vim.keymap.set('n', '<F24>', '<Nop>', {desc='new fixture'})")
  local csv = refresh()
  assert(csv:find('new fixture', 1, true))
  assert(not csv:find('old fixture', 1, true))
  child.lua("vim.keymap.del('n', '<F24>')")
  assert(not refresh():find('new fixture', 1, true))
end

T['event refresh is deferred, setup is idempotent, unchanged output is not rewritten'] = function()
  enabled()
  child.lua([[assert(exporter.setup()); vim.wait(500, function() return vim.fn.filereadable(output)==1 end, 10)]])
  local before = child.lua_get('(vim.uv or vim.loop).fs_stat(output).mtime')
  refresh()
  eq(child.lua_get('(vim.uv or vim.loop).fs_stat(output).mtime'), before)
  child.lua([[
    vim.keymap.set('n', '<F24>', '<Nop>', {desc='late event fixture'})
    vim.api.nvim_exec_autocmds('User', {pattern='LazyLoad'})
    vim.api.nvim_exec_autocmds('SafeState', {})
    assert(vim.wait(1500, function()
      return table.concat(vim.fn.readfile(output), '\n'):find('late event fixture', 1, true) ~= nil
    end, 10))
  ]])
  assert(contents():find('late event fixture', 1, true))
  eq(child.lua_get("#vim.api.nvim_get_autocmds({group='KeymapExport', event='VimLeavePre'})"), 1)
end

T['VimLeavePre writes synchronously and global path takes priority'] = function()
  child.lua([[vim.g.keymap_export=output; vim.env.NVIM_KEYMAP_EXPORT=output..'.other'; assert(exporter.setup())
    vim.keymap.set('n', '<F24>', '<Nop>', {desc='exit fixture'})
    vim.api.nvim_exec_autocmds('VimLeavePre', {})]])
  assert(contents():find('exit fixture', 1, true))
  eq(vim.fn.filereadable(output .. '.other'), 0)
end

T['write failure is visible, preserves target, and removes temporary file'] = function()
  child.lua([[
    errors = {}
    vim.notify = function(message, level) errors[#errors+1] = {message, level} end
    vim.fn.mkdir(output, 'p')
  ]])
  enabled()
  child.cmd('KeymapExport')
  eq(child.lua_get('#errors'), 1)
  assert(child.lua_get('errors[1][1]'):find('KEYMAP_EXPORT_WRITE:', 1, true))
  eq(child.lua_get('errors[1][2]'), vim.log.levels.ERROR)
  eq(child.lua_get("vim.fn.isdirectory(output)"), 1)
  eq(child.lua_get("vim.fn.glob(output..'.*', false, true)"), {})
  child.cmd('KeymapExport')
  eq(child.lua_get('#errors'), 1)
  child.lua([[vim.fn.delete(output, 'd'); vim.cmd('KeymapExport')]])
  assert(contents():find('"mode","lhs"', 1, true))
end

T['SafeState does not recursively schedule refresh timers'] = function()
  enabled()
  child.lua([[
    local original = vim.defer_fn
    scheduled = 0
    vim.defer_fn = function(...) scheduled = scheduled + 1; return original(...) end
    for _=1,5 do vim.api.nvim_exec_autocmds('SafeState', {}) end
    vim.defer_fn = original
  ]])
  eq(child.lua_get('scheduled'), 0)
end

T['invalid explicit output path fails with a typed diagnostic'] = function()
  child.lua([[vim.g.keymap_export = true
    local ok, err = pcall(exporter.setup)
    assert(not ok and tostring(err):find('KEYMAP_EXPORT_PATH:', 1, true))]])
end

return T
