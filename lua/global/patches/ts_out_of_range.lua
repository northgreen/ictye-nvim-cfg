-- Fix below problem
-- Error in decoration provider "line" (ns=nvim.treesitter.highlighter):
-- Error executing lua: ...nt/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:370: Invalid 'end_col': out of range
-- stack traceback:
--	[C]: in function 'nvim_buf_set_extmark'
--	...nt/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:370: in function 'fn'
--	...nt/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:232: in function 'for_each_highlight_state'
--	...nt/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:322: in function 'on_line_impl'
--	...nt/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:411: in function <...nt/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:405>
local M = {}

function M.apply_fixes()
    vim.cmd [[TSUpdate]]

    local hl_mod = require('vim.treesitter.highlighter')
    if not hl_mod.__patched then
        local orig_on_line = hl_mod.on_line
        hl_mod.on_line = function(self, ...)
            local args = { ... }
            local ok, err = pcall(function()
                orig_on_line(self, unpack(args))
            end)
            if not ok then
                if not string.find(err, 'Invalid') then
                    vim.notify('Treesitter error: ' .. err, vim.log.levels.ERROR)
                end
                -- 禁用问题缓冲区的高亮
                vim.schedule(function()
                    pcall(vim.cmd, 'TSBufDisable highlight')
                end)
            end
        end
        hl_mod.__patched = true
    end
    
end

-- 应用修复
M.apply_fixes()

-- 自动重新加载修复
vim.api.nvim_create_autocmd('VimEnter', {
    callback = M.apply_fixes
})

return M
