local Autocmd = vim.api.nvim_create_autocmd

Autocmd("BufEnter", {
    callback = function()
        if vim.bo[0].buftype ~= "terminal" then vim.cmd "lcd %:p:h" end
    end
})

Autocmd("BufReadPre", {callback = function() end})

local function open_nvim_tree(data)
    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1

    if not directory then return end

    -- change to the directory
    vim.cmd.cd(data.file)

    -- open the tree
    require("nvim-tree.api").tree.open()
end

Autocmd({"VimEnter"}, {callback = open_nvim_tree})

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

