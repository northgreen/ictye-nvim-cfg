-- Run from the repository root: nvim --headless -u NONE -l tests/unit/meow_yarn.lua
local lazy = vim.fn.stdpath('data') .. '/lazy/'
package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path
local function load_patch()
    require('fennel').dofile('plugin/patch-meow-yarn.fnl')
end
vim.opt.runtimepath:append(lazy .. 'nui.nvim')
vim.opt.runtimepath:append(lazy .. 'meow.yarn.nvim')

-- Installing before the plugin loads must preserve lazy loading.
load_patch()
assert(not package.loaded['meow.yarn.hierarchy'], 'patch must not eagerly load the plugin')
vim.cmd('runtime plugin/meow-yarn.lua')
require('meow.yarn').setup({})
vim.api.nvim_exec_autocmds('User', { pattern = 'LazyLoad', data = 'meow.yarn.nvim' })
local Hierarchy = require('meow.yarn.hierarchy')
local util = require('meow.yarn.util')
local patched_new, patched_unique = Hierarchy.new, util.unique_id_for
load_patch()
assert(Hierarchy.new == patched_new and util.unique_id_for == patched_unique, 'patch must be idempotent')

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
local hierarchy = Hierarchy:new({ cancel_request = function() end }, item, strategy, 'callers')
hierarchy:mount()
vim.wait(30, function() return false end, 5)
local root = hierarchy.tree:get_nodes()[1]
hierarchy:update_node(root)
local first = vim.tbl_extend('force', item, { call_site_ranges = { range } })
local second = vim.tbl_extend('force', item, { call_site_ranges = { range, range } })
respond({ first, second })
local children = hierarchy.tree:get_nodes(root:get_id())
assert(#children == 2 and children[1]:get_id() ~= children[2]:get_id(), 'duplicate siblings need distinct IDs')
assert(children[1].lsp_item == first and children[2].lsp_item == second, 'call-site data must be preserved')
assert(hierarchy.tree:get_node(children[1]:get_id()) == children[1], 'explicit ID lookups must work')
assert(hierarchy.tree:get_node(), 'visible cursor lookup must work')

-- Reserved IDs must also avoid literal suffixed names and existing tree nodes.
local id = util.unique_id_for(hierarchy.tree, children[2]:get_id())
assert(id ~= children[2]:get_id(), 'existing IDs must not be reused')
local reserved = util.unique_id_for(hierarchy.tree, 'reserved')
local suffixed = util.unique_id_for(hierarchy.tree, 'reserved#2')
local duplicate = util.unique_id_for(hierarchy.tree, 'reserved')
assert(reserved == 'reserved' and suffixed == 'reserved#2' and duplicate == 'reserved#3', 'pending suffix collision')

-- Let the real debounce timer enqueue its preview, then close before it executes.
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

local other = require('nui.tree')({ bufnr = vim.api.nvim_create_buf(false, true) })
assert(util.unique_id_for(other, 'reserved') == 'reserved', 'reservations must be isolated per tree')
print('meow.yarn regressions: duplicate siblings, call-site preservation, delayed preview, lazy loading and idempotence passed')
