-- Run from the repository root: nvim --headless -u NONE -l tests/unit/performance.lua
package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local setup_calls = 0
package.loaded.dapui = { setup = function() setup_calls = setup_calls + 1 end }
package.loaded['configs.language_cfg.toolchain.toolchain_init'] = {}
dofile('lua/configs/language_cfg/init.lua')
for _ = 1, 100 do
    vim.api.nvim_exec_autocmds('BufRead', { buffer = 0, modeline = false })
end
assert(setup_calls == 1, 'language tools must initialize once, got ' .. setup_calls)

local render_calls = 0
local render = require('util.bufferline_render')(function()
    render_calls = render_calls + 1
    return 'tabline-' .. render_calls, { count = render_calls }
end)
assert(require('util.bufferline_render')(render) == render, 'reinstalling must not stack wrappers')
for _ = 1, 100 do
    local text, state = render()
    assert(text == 'tabline-1' and state.count == 1, 'cached return values must be preserved')
end
assert(render_calls == 1, 'a redraw burst must render once')
vim.wait(150, function() return false end, 10)
local text, state = render()
assert(text == 'tabline-2' and state.count == 2, 'cache must expire after the redraw interval')
assert(render_calls == 2, 'expired cache must render once')
print('performance regressions: initialization once; redraw coalescing and expiry passed')
