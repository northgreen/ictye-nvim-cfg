local Autocmd = vim.api.nvim_create_autocmd

-- BufEnter autocmd to change directory to the current file's directory
Autocmd("BufEnter", {
    callback = function()
        if vim.bo[0].buftype ~= "terminal" then vim.cmd "lcd %:p:h" end
    end
})

Autocmd("BufRead", {callback = function() end})

-- FileType autocmd to enable filetype specific settings
local function open_nvim_tree(data)
    local directory = vim.fn.isdirectory(data.file) == 1
    if not directory then return end
    vim.cmd.cd(data.file)
    require("nvim-tree.api").tree.open()
end

Autocmd({"VimEnter"}, {callback = open_nvim_tree})

-- Fix the bug for saving shada file when leaving nvim
Autocmd("VimLeave", {
    pattern = "*",
    callback = function()
		local data_path = vim.fn.stdpath("data")
		local sdata_path = vim.fs.joinpath(tostring(data_path), "shada","main.shada.tmp.X")
        if vim.fn.filereadable(sdata_path) == 1 then
            vim.fn.delete(sdata_path)
        end
    end
})

-- Autocmd to save file when leaving insert mode
-- Autocmd({ 'InsertLeave' }, {
--        callback = function()
--  
--            vim.fn.execute('silent! write')
--        end,
-- })

