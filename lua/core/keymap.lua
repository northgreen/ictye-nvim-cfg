local Hydra = require('hydra')
local Keymap = vim.keymap.set
local Command = vim.api.nvim_create_user_command

local keymap_opt = {noremap = true, silent = true}
local normal_keymaps = {
    ['<C-p>'] = '<Cmd>Telescope find_files<CR>',
    ['<leader>1'] = '<Cmd>BufferLineGoToBuffer 1<CR>',
    ['<leader>2'] = '<Cmd>BufferLineGoToBuffer 2<CR>',
    ['<leader>3'] = '<Cmd>BufferLineGoToBuffer 3<CR>',
    ['<leader>4'] = '<Cmd>BufferLineGoToBuffer 4<CR>',
    ['<leader>5'] = '<Cmd>BufferLineGoToBuffer 5<CR>',
    ['<leader>6'] = '<Cmd>BufferLineGoToBuffer 6<CR>',
    ['<leader>7'] = '<Cmd>BufferLineGoToBuffer 7<CR>',
    ['<leader>8'] = '<Cmd>BufferLineGoToBuffer 8<CR>',
    ['<leader>9'] = '<Cmd>BufferLineGoToBuffer 9<CR>',
    ['<leader>-'] = '<Cmd>BufferLineCyclePrev<CR>',
    ['<leader>='] = '<Cmd>BufferLineCycleNext<CR>',
    ['<leader>q'] = ':bp<cr>:bd #<CR>',

    ['<F3>'] = '<Cmd>Outline<CR>',
    ['<F4>'] = '<Cmd>NvimTreeToggle<CR>',

    ['<F9>'] = '<Cmd>DapContinue<CR>',
	['<F10>'] = '<Cmd>DapStepOver<CR>',
	['<F11>'] = '<Cmd>DapUIStepInto<CR>',
    ['<F12>'] = '<Cmd>DapStepOut<CR>',

    ['<C-b>'] = '<Cmd>lua require"dap".toggle_breakpoint()<CR>',
    ['<C-r_>'] = '<Plug>coc-refactor',
    ['<C-n>'] = '<Cmd>lua vim.lsp.buf.hover()<CR>',
    ['<C-]>'] = '<Cmd> IcDefine<CR>',
    ['<C-f>'] = '<Cmd>Telescope<CR>',
    ['<leader>cq'] = '<Cmd>QuickMenu<CR>',

    ['<F5>'] = '<Cmd>QuickMenu<CR>',
	['<F6>'] = '<Cmd>IcDAPUIToggle<CR>',
	['<F2>'] = '<Cmd>Lazy<CR>',
}


for key, mapping in pairs(normal_keymaps) do Keymap('n', key, mapping, keymap_opt) end

Keymap('i','jj','<esc>',keymap_opt)

Hydra({
    name = 'Window Change',
    mode = 'n',
    body = '<C-w>c',
    heads = {
        {'h', '<C-w>h', {description = 'Move to left window'}},
        {'j', '<C-w>j', {description = 'Move to down window'}},
        {'k', '<C-w>k', {description = 'Move to up window'}},
        {'l', '<C-w>l', {description = 'Move to right window'}}
    }
})

Hydra({
	name = "Tab Change",
	mode = 'n',
	body = '<C-w>W',
	heads = {
		{'h','<C-w>>', {description = 'Decrease window width'}},
		{'l','<C-w><', {description = 'Incraese window width'}},
		{'j','<C-w>+', {description = 'Increase window height'}},
		{'k','<C-w>-', {description = 'Decrease window height'}}
	}
})

Hydra({
	name = "Tab Change",
	mode = 'n',
	body = '<leader>t',
	heads = {
		{'j','<Cmd>BufferLineCyclePrev<CR>', {description = 'Move to previous tab'}},
		{'k','<Cmd>BufferLineCycleNext<CR>', {description = 'Move to next tab'}}
	}
})

Command("IcFormat",function() vim.lsp.buf.format() end, {})
Command('IcRename', function() vim.lsp.buf.rename() end, {})
Command('IcUseage', function() vim.lsp.buf.incoming_calls() end, {})
Command('IcDefine', function() vim.lsp.buf.definition() end, {})
Command('IcDAP', function() require"osv".launch({port = 8086}) end, {})
Command("IcDAPUIOpen", function() require("dapui").open() end, {})
Command("IcDAPUIClose", function() require("dapui").close() end, {})
Command("IcDAPUIToggle", function() require("dapui").toggle() end, {})

