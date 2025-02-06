local opt = {noremap = true, silent = true}
local keymap = vim.api.nvim_set_keymap

local normal_keymaps = {
    ["<C-p>"] = "<Cmd>Telescope find_files<CR>",
    ["<leader>1"] = "<Cmd>BufferLineGoToBuffer 1<CR>",
    ["<leader>2"] = "<Cmd>BufferLineGoToBuffer 2<CR>",
    ["<leader>3"] = "<Cmd>BufferLineGoToBuffer 3<CR>",
    ["<leader>4"] = "<Cmd>BufferLineGoToBuffer 4<CR>",
    ["<leader>5"] = "<Cmd>BufferLineGoToBuffer 5<CR>",
    ["<leader>6"] = "<Cmd>BufferLineGoToBuffer 6<CR>",
    ["<leader>7"] = "<Cmd>BufferLineGoToBuffer 7<CR>",
    ["<leader>8"] = "<Cmd>BufferLineGoToBuffer 8<CR>",
    ["<leader>9"] = "<Cmd>BufferLineGoToBuffer 9<CR>",
    ["<leader>-"] = "<Cmd>BufferLineCycleNext<CR>",
    ["<leader>="] = "<Cmd>BufferLineCyclePrev<CR>",
    ["<leader>q"] = ":bp<cr>:bd #<CR>",
    ["<F3>"] = "<Cmd>TagbarToggle<CR>",
    ["<F4>"] = "<Cmd>NvimTreeToggle<CR>",
    ["<F9>"] = "<Cmd>DapContinue<CR>",
    ["<C-b>"] = "<Cmd>lua require'dap'.toggle_breakpoint()<CR>",
    ["<C-r_>"] = "<Plug>coc-refactor",
    ["<C-n>"] = "<Cmd>lua vim.lsp.buf.hover()<CR>",
    ["<C-]>"] = "<Cmd> IcDefine<CR>"
}

local edit_keymaps = {["jj"] = "<esc>"}

for key, mapping in pairs(normal_keymaps) do keymap("n", key, mapping, opt) end

for key, mapping in pairs(edit_keymaps) do keymap("i", key, mapping, opt) end


vim.api.nvim_create_user_command("IcRename",
function()
	vim.lsp.buf.rename()
end,
{})

vim.api.nvim_create_user_command("IcUseage",
function ()
	vim.buf.incoming_calls()
end,
{})

vim.api.nvim_create_user_command("IcDefine",
function()
	vim.buf.definition()
end,
{})

