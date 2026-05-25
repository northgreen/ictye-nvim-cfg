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

Autocmd("BufRead", { callback = function() end })

-- FileType autocmd to enable filetype specific settings
local function open_nvim_tree(data)
  local directory = vim.fn.isdirectory(data.file) == 1
  if not directory then return end
  vim.cmd.cd(data.file)
  require("nvim-tree.api").tree.open()
end

-- Autocmd({"VimEnter"}, {callback = open_nvim_tree})

-- Fix the bug for saving shada file when leaving nvim
Autocmd("VimLeave", {
  pattern = "*",
  callback = function()
    local data_path = vim.fn.stdpath("data")
    local sdata_path = vim.fs.joinpath(tostring(data_path), "shada", "main.shada.tmp.X")
    if vim.fn.filereadable(sdata_path) == 1 then
      vim.fn.delete(sdata_path)
    end
  end
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local resession = require("resession")
    -- Always save a special session named "last"
    resession.save("last")
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "OilActionsPost",
  callback = function(event)
    if event.data.actions[1].type == "move" then
      Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
    end
  end,
})

-- Autocmd to save file when leaving insert mode
-- Autocmd({ 'InsertLeave' }, {
--        callback = function()
--
--            vim.fn.execute('silent! write')
--        end,
-- })
