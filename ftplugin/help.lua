if vim.g.lite_mode then
    return
end

vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = true, desc = "Close Quickfix" })
vim.keymap.set("n", "<Esc>", "<Cmd>quit<CR>", { buffer = true })
