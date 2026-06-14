local Autocmd = vim.api.nvim_create_autocmd

-- BufEnter autocmd to change directory to the current file's directory
-- Autocmd("BufEnter", {
--     callback = function()
--         if vim.bo.filetype == "oil" then
--             return
--         end
--         if vim.bo[0].buftype ~= "terminal" then vim.cmd "lcd %:p:h" end
--     end
-- })


-- Autocmd to save file when leaving insert mode
-- Autocmd({ 'InsertLeave' }, {
--        callback = function()
--
--            vim.fn.execute('silent! write')
--        end,
-- })
