if vim.g.neovide then
    require 'core.keymap.neovide'
end

local Hydra = require('hydra')
local Keymap = vim.keymap.set
local Command = vim.api.nvim_create_user_command
local Menu = require("util.quickmenu")

local bind = require 'util.functions'.bind
local lazy_require = require 'util.functions'.lazy_require
local lazy_call = require'util.functions'.lazy_call

local neotest = lazy_require("neotest")
local telescope_builtin = lazy_require("telescope.builtin")

-- Test Menu
local TestMenu = Menu({
    {
        ["Watch Test"] = function() neotest.watch.toggle() end,
        ["Toggle Summary"] = function() neotest.summary.toggle() end,
        ["Run Test"] = function() neotest.run.run() end,
        ["Show Cur Output"] = function() neotest.output.open() end,
        ["Toggle Output Panel"] = function() neotest.output_panel.toggle() end,
        ["Run With Debug"] = function() neotest.run.run({ strategy = "dap" }) end,

    }
})

-- QuickMenu
local QuickMenu = Menu({
    {
        ["Search"] = lazy_call('telescope.builtin', 'builtin'),
        ["Questions"] = bind(lazy_call("trouble", "open"), "questions"),
        ["Find and Replace"] = bind(vim.cmd, "GrugFar"),
        ["Find in Files"] = bind(vim.cmd, "RipSubstitute"),
        ["Terminal"] = bind(vim.cmd, "FloatermNew zsh"),
        ["Git"] = bind(vim.cmd, "LazyGit"),
        ["Debug"] = bind(vim.cmd, "DapNew"),
        ["Todo"] = bind(vim.cmd, "Trouble todo"),
        ["Tasks"] = bind(vim.cmd, "terminal dooit"),
        ["Run"] = bind(vim.cmd, "OverseerRun"),
    }
})


Command("IcFormat", function() vim.lsp.buf.format() end, {})
Command('IcRename', function() vim.lsp.buf.rename() end, {})
Command('IcUseage', function() vim.lsp.buf.incoming_calls() end, {})
Command('IcDefine', function() vim.lsp.buf.definition() end, {})
Command('IcDAP', function() require "osv".launch({ port = 8086 }) end, {})
Command("IcDAPUIOpen", function() require("dapui").open() end, {})
Command("IcDAPUIClose", function() require("dapui").close() end, {})
Command("IcDAPUIToggle", function() require("dapui").toggle() end, {})
Command("Lsbf", function() telescope_builtin.buffers() end, {})

Command("IcTestMenu", bind(TestMenu.mount, TestMenu), {})
Command("QuickMenu", bind(QuickMenu.mount, QuickMenu), {})


local keymap_opt = { noremap = true, silent = true }
local normal_keymaps = {
    ['<F3>']   = '<Cmd>Outline<CR>',
    ['<F4>']   = '<Cmd>Neotree toggle<CR>',

    ['<F9>']   = '<Cmd>DapContinue<CR>',
    ['<F10>']  = '<Cmd>DapStepOver<CR>',
    ['<F11>']  = '<Cmd>DapStepInto<CR>',
    ['<F12>']  = '<Cmd>DapStepOut<CR>',

    ['<C-b>']  = '<Cmd>lua require"dap".toggle_breakpoint()<CR>',
    ['<C-r_>'] = '<Plug>coc-refactor',
    ['<C-n>']  = '<Cmd>lua vim.lsp.buf.hover()<CR>',
    ['<C-]>']  = '<Cmd> IcDefine<CR>',
    ['<C-f>']  = '<Cmd>Telescope find_files<CR>',
    ['<C-p>']  = '<Cmd>Telescope<CR>',

    ['<F5>']   = '<Cmd>QuickMenu<CR>',
    ['<F6>']   = '<Cmd>IcDAPUIToggle<CR>',
    ['<F2>']   = '<Cmd>Lazy<CR>',
}

-- Buffer Keymaps
Keymap('n', '<leader>1', '<Cmd>BufferLineGoToBuffer 1<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>2', '<Cmd>BufferLineGoToBuffer 2<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>3', '<Cmd>BufferLineGoToBuffer 3<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>4', '<Cmd>BufferLineGoToBuffer 4<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>5', '<Cmd>BufferLineGoToBuffer 5<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>6', '<Cmd>BufferLineGoToBuffer 6<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>7', '<Cmd>BufferLineGoToBuffer 7<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>8', '<Cmd>BufferLineGoToBuffer 8<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>9', '<Cmd>BufferLineGoToBuffer 9<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>-', '<Cmd>BufferLineCyclePrev<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>=', '<Cmd>BufferLineCycleNext<CR>', { noremap = true, silent = true })
Keymap('n', '<leader>q', ':bp<cr>:bd #<CR>', { noremap = true, silent = true })
Keymap('n','gf',require('snacks').image.hover,{ noremap = true, silent = true })

Keymap('n', '<C-x>q', '<Cmd>QuickMenu<CR>', { noremap = true, silent = true, desc = 'Open QuickMenu' })
Keymap('n', '<C-x>u', require 'undotree'.toggle, { noremap = true, silent = true, desc = "Toggle undotree" })
Keymap('n', '<C-x>f', "<Cmd>Pick files<CR>", { noremap = true, silent = true, desc = "Pick a file" })
Keymap('n', '<C-x><C-f>', require("mini.files").open, { noremap = true, silent = true, desc = "Open a file" })
Keymap("n", "<C-x>a", require("global.ui_util.ui.actions"), { noremap = true, silent = true, desc = "Show lsp actions" })
Keymap("n", "<C-x>t", "<Cmd>IcTestMenu<CR>", { noremap = true, silent = true, desc = "Show lsp actions" })
Keymap("n", "<C-x>bf", "<Cmd>Telescope buffers<CR>", { noremap = true, silent = true, desc = "Show lsp actions" })
Keymap("n", "<C-x><C-b>", "<Cmd>Telescope buffers<CR>", { noremap = true, silent = true, desc = "Show lsp actions" })

Keymap("n", "<leader>O", "<Cmd>Oil<CR>",{ noremap = true, silent = true, desc = "Open Oil View" })
Keymap('n', '<A-x>', ":", { desc = "Command line" })

-- Keymap('n', '<leader>mpt', require("mini.map").toggle, { noremap = true, silent = true, desc = "toggle minimap" })
-- Keymap('n', '<leader>mps', require("mini.map").toggle_side, { noremap = true, silent = true, desc = "toggle minimap" })



-- Newline below and above
Keymap('n', '<CR>', function()
    if vim.bo.filetype == "qf" then
        vim.cmd([[execute "normal! \<CR>"]])
    else
        local line = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, line, line, false, { '' })
        vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
    end
end, { noremap = true, silent = true })

Keymap('n', '<S-CR>', function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, { '' })
    vim.api.nvim_win_set_cursor(0, { line, 0 })
end, { noremap = true, silent = true })

-- 'jj' for exit
Keymap('i', 'jj', '<esc>', { noremap = true, silent = true, desc = "Exit insert mode" })


--Hydras

Hydra({
    name = 'Window Change',
    mode = 'n',
    body = '<C-w>c',
    heads = {
        { 'h', '<C-w>h', { description = 'Move to left window' } },
        { 'j', '<C-w>j', { description = 'Move to down window' } },
        { 'k', '<C-w>k', { description = 'Move to up window' } },
        { 'l', '<C-w>l', { description = 'Move to right window' } }
    }
})

Hydra({
    name = "Tab Change",
    mode = 'n',
    body = '<C-w>W',
    heads = {
        { 'h', '<C-w>>', { description = 'Decrease window width' } },
        { 'l', '<C-w><', { description = 'Incraese window width' } },
        { 'j', '<C-w>+', { description = 'Increase window height' } },
        { 'k', '<C-w>-', { description = 'Decrease window height' } }
    }
})

Hydra({
    name = "Tab Change",
    mode = 'n',
    body = '<leader>t',
    heads = {
        { 'j', '<Cmd>BufferLineCyclePrev<CR>', { description = 'Move to previous tab' } },
        { 'k', '<Cmd>BufferLineCycleNext<CR>', { description = 'Move to next tab' } }
    }
})



-- auto set some keymaps
for key, mapping in pairs(normal_keymaps) do Keymap('n', key, mapping, keymap_opt) end

require 'core.keymap.cfg_edit'
