-- mini.test 用例：语言工具单次初始化与 bufferline 重绘合并。
local MiniTest = require('mini.test')
local eq = MiniTest.expect.equality
local T = MiniTest.new_set()

local child = MiniTest.new_child_neovim()
T = MiniTest.new_set({ hooks = {
    pre_case = function() child.restart({ '-u', 'tests/minimal_init.lua' }) end,
    post_case = child.stop,
} })

T['语言工具只初始化一次，重绘合并且到期刷新'] = function()
    child.lua([[
        local setup_calls = 0
        package.loaded.dapui = { setup = function() setup_calls = setup_calls + 1 end }
        package.loaded['configs.language_cfg.toolchain.toolchain_init'] = {}
        dofile('lua/configs/language_cfg/init.lua')
        for _ = 1, 100 do
            vim.api.nvim_exec_autocmds('BufRead', { buffer = 0, modeline = false })
        end
        MiniTest.expect.equality(setup_calls, 1)

        local render_calls = 0
        local render = require('util.bufferline_render')(function()
            render_calls = render_calls + 1
            return 'tabline-' .. render_calls, { count = render_calls }
        end)
        MiniTest.expect.equality(require('util.bufferline_render')(render), render)
        for _ = 1, 100 do
            local text, state = render()
            MiniTest.expect.equality(text, 'tabline-1')
            MiniTest.expect.equality(state.count, 1)
        end
        MiniTest.expect.equality(render_calls, 1)
        vim.wait(150, function() return false end, 10)
        MiniTest.expect.equality(render(), 'tabline-2')
        MiniTest.expect.equality(render_calls, 2)
    ]])
end

return T
