local opt = {
	noremap = true,
	silent = true,
}

vim.api.nvim_set_keymap("n","<C-p>","<Cmd>Telescope find_files<CR>",opt)
----映射<\> + 數字鍵切換到對應標簽
vim.api.nvim_set_keymap("n","<leader>1","<Cmd>BufferLineGoToBuffer 1<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>2","<Cmd>BufferLineGoToBuffer 2<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>3","<Cmd>BufferLineGoToBuffer 3<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>4","<Cmd>BufferLineGoToBuffer 4<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>5","<Cmd>BufferLineGoToBuffer 5<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>6","<Cmd>BufferLineGoToBuffer 6<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>7","<Cmd>BufferLineGoToBuffer 7<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>8","<Cmd>BufferLineGoToBuffer 8<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>9","<Cmd>BufferLineGoToBuffer 9<CR>",opt)
----映射<\> + <+/-> 切換到前一個或者後一個標簽
vim.api.nvim_set_keymap("n","<leader>-","<Cmd>BufferLineCycleNext<CR>",opt)
vim.api.nvim_set_keymap("n","<leader>=","<Cmd>BufferLineCyclePrev<CR>",opt)
----映射<\> + <q> 推出當前tab
vim.api.nvim_set_keymap("n","<leader>q",":bp<cr>:bd #<CR>",opt)

vim.api.nvim_set_keymap("n","<F3>","<Cmd>TagbarToggle<CR>",opt)
vim.api.nvim_set_keymap("n","<F4>","<Cmd>NvimTreeToggle<CR>",opt)
vim.api.nvim_set_keymap("n","<F9>","<Cmd>DapContinue<CR>",opt)
vim.api.nvim_set_keymap("n","<C-b>","<Cmd>lua require'dap'.toggle_breakpoint()<CR>",opt)

vim.api.nvim_set_keymap("n","<C-r>","<Plug>coc-refactor",opt)

vim.api.nvim_command('command! IcRename lua vim.lsp.buf.rename()')
vim.api.nvim_command('command! IcUseage lua vim.lsp.buf.incoming_calls()')
vim.api.nvim_command('command! IcDefine lua vim.lsp.buf.definition()')

vim.api.nvim_set_keymap("n","<C-]>","<Cmd> IcDefine<CR>",opt)

vim.api.nvim_set_keymap("n","<C-n>","<Cmd>lua vim.lsp.buf.hover()<CR>",opt)

