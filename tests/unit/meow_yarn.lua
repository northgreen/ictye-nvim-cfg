local MiniTest = require("mini.test")
local child = MiniTest.new_child_neovim()
local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
      child.lua([[
                local lazy = vim.fn.stdpath('data') .. '/lazy/'
                for _, dependency in ipairs({ 'nui.nvim', 'meow.yarn.nvim' }) do
                    local path = lazy .. dependency
                    assert(vim.fn.isdirectory(path) == 1, 'Install test dependency ' .. dependency .. ' at ' .. path)
                    vim.opt.runtimepath:append(path)
                end
                assert(vim.fn.filereadable('lua/fennel.lua') == 1,
                    'Missing repository dependency lua/fennel.lua; run tests from the repository root')
                function load_patch()
                    require('fennel').dofile('plugin/patch-meow-yarn.fnl')
                end
                function start_plugin()
                    vim.cmd('runtime plugin/meow-yarn.lua')
                    require('meow.yarn').setup({})
                    vim.api.nvim_exec_autocmds('User', { pattern = 'LazyLoad', data = 'meow.yarn.nvim' })
                end
            ]])
    end,
    post_case = child.stop,
  },
})

local function mount_hierarchy()
  child.lua([[
        load_patch()
        start_plugin()
        local range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 1 } }
        local item = {
            name = 'caller', kind = 12, uri = vim.uri_from_fname(vim.fn.getcwd() .. '/tests/unit/meow_yarn.lua'),
            range = range, selectionRange = range,
        }
        local strategy = vim.tbl_extend('force', require('meow.yarn.strategies.call'), {})
        local respond
        strategy.fetch_children = function(_, _, _, callback)
            respond = callback
            return 1
        end
        hierarchy = require('meow.yarn.hierarchy'):new({ cancel_request = function() end }, item, strategy, 'callers')
        hierarchy:mount()
        vim.wait(30, function() return false end, 5)
        local root = hierarchy.tree:get_nodes()[1]
        hierarchy:update_node(root)
        first = vim.tbl_extend('force', item, { call_site_ranges = { range } })
        second = vim.tbl_extend('force', item, { call_site_ranges = { range, range } })
        respond({ first, second })
        children = hierarchy.tree:get_nodes(root:get_id())
    ]])
end

T["patch preserves lazy loading and repeated installation is idempotent"] = function()
  child.lua([[
        load_patch()
        assert(not package.loaded['meow.yarn.hierarchy'], 'patch must not eagerly load the plugin')
        start_plugin()
        local Hierarchy = require('meow.yarn.hierarchy')
        local util = require('meow.yarn.util')
        local patched_new, patched_unique = Hierarchy.new, util.unique_id_for
        load_patch()
        assert(Hierarchy.new == patched_new and util.unique_id_for == patched_unique, 'patch must be idempotent')
    ]])
end

T["duplicate and suffixed IDs preserve call sites and reservations stay per tree"] = function()
  mount_hierarchy()
  child.lua([[
        local util = require('meow.yarn.util')
        assert(#children == 2 and children[1]:get_id() ~= children[2]:get_id(), 'duplicate siblings need distinct IDs')
        assert(children[1].lsp_item == first and children[2].lsp_item == second, 'call-site data must be preserved')
        assert(hierarchy.tree:get_node(children[1]:get_id()) == children[1], 'explicit ID lookups must work')
        assert(hierarchy.tree:get_node(), 'visible cursor lookup must work')
        local id = util.unique_id_for(hierarchy.tree, children[2]:get_id())
        assert(id ~= children[2]:get_id(), 'existing IDs must not be reused')
        local reserved = util.unique_id_for(hierarchy.tree, 'reserved')
        local suffixed = util.unique_id_for(hierarchy.tree, 'reserved#2')
        local duplicate = util.unique_id_for(hierarchy.tree, 'reserved')
        assert(reserved == 'reserved' and suffixed == 'reserved#2' and duplicate == 'reserved#3', 'pending suffix collision')
        local other = require('nui.tree')({ bufnr = vim.api.nvim_create_buf(false, true) })
        assert(util.unique_id_for(other, 'reserved') == 'reserved', 'reservations must be isolated per tree')
    ]])
end

T["delayed preview survives closing the popup while explicit ID lookup remains available"] = function()
  mount_hierarchy()
  child.lua([[
        -- Enqueue the real debounce callback, then close before it executes.
        local scheduled, schedule = {}, vim.schedule
        vim.schedule = function(callback) scheduled[#scheduled + 1] = callback end
        vim.api.nvim_exec_autocmds('CursorMoved', { buffer = hierarchy.tree.bufnr })
        vim.wait(150, function() return #scheduled > 0 end, 5)
        vim.schedule = schedule
        assert(#scheduled > 0, 'preview timer must enqueue a callback')
        hierarchy:unmount()
        for _, callback in ipairs(scheduled) do
            local ok, err = pcall(callback)
            assert(ok, 'closed-window callback failed: ' .. tostring(err))
        end
        assert(hierarchy.tree:get_node() == nil, 'closed popup has no cursor node')
        assert(hierarchy.tree:get_node(children[1]:get_id()) == children[1], 'closed popup retains explicit ID lookup')
    ]])
end

return T
