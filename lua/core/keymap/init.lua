local M = {}

---@type LazyKeysSpec[]
M.bufferline = {
    { '<leader>1',  '<Cmd>BufferLineGoToBuffer 1<CR>',         noremap = true,                      silent = true },
    { '<leader>2',  '<Cmd>BufferLineGoToBuffer 2<CR>',         noremap = true,                      silent = true },
    { '<leader>3',  '<Cmd>BufferLineGoToBuffer 3<CR>',         noremap = true,                      silent = true },
    { '<leader>4',  '<Cmd>BufferLineGoToBuffer 4<CR>',         noremap = true,                      silent = true },
    { '<leader>5',  '<Cmd>BufferLineGoToBuffer 5<CR>',         noremap = true,                      silent = true },
    { '<leader>6',  '<Cmd>BufferLineGoToBuffer 6<CR>',         noremap = true,                      silent = true },
    { '<leader>7',  '<Cmd>BufferLineGoToBuffer 7<CR>',         noremap = true,                      silent = true },
    { '<leader>8',  '<Cmd>BufferLineGoToBuffer 8<CR>',         noremap = true,                      silent = true },
    { '<leader>9',  '<Cmd>BufferLineGoToBuffer 9<CR>',         noremap = true,                      silent = true },
    { '<leader>-',  '<Cmd>BufferLineCyclePrev<CR>',            noremap = true,                      silent = true },
    { '<leader>=',  '<Cmd>BufferLineCycleNext<CR>',            noremap = true,                      silent = true },
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Toggle Pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>",           desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",            desc = "Delete Buffers to the Left" },
    { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
    { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
    { "[b",         "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
    { "]b",         "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
    { "[B",         "<cmd>BufferLineMovePrev<cr>",             desc = "Move buffer prev" },
    { "]B",         "<cmd>BufferLineMoveNext<cr>",             desc = "Move buffer next" }
}

---@type LazyKeysSpec[]
M.undo_tree = {
    { '<C-x>u',    function() require 'undotree'.toggle() end, noremap = true, silent = true, desc = "Toggle undotree" },
    { '<leader>u', function() require 'undotree'.toggle() end, noremap = true, silent = true, desc = "Toggle undotree" }
}

---@type LazyKeysSpec[]
M.telescope = {
    { '<C-x><C-b>', '<Cmd>Telescope buffers<CR>',   mode = { 'n', 't' }, noremap = true, silent = true,            desc = 'Show buffer list' },
    { '<C-x>bf',    '<Cmd>Telescope buffers<CR>',   noremap = true,      silent = true,  desc = 'Show buffer list' },
    { '<C-f>',      '<Cmd>Telescope find_files<CR>' },
    { '<C-p>',      '<Cmd>Telescope<CR>' },
}

---@type LazyKeysSpec[]
M.muti_cursor = {
    { "<up>",            function() require("multicursor-nvim").lineAddCursor(-1) end,   mode = { "n", "x" } },
    { "<down>",          function() require("multicursor-nvim").lineAddCursor(1) end,    mode = { "n", "x" } },
    { "<leader><up>",    function() require("multicursor-nvim").lineSkipCursor(-1) end,  mode = { "n", "x" } },
    { "<leader><down>",  function() require("multicursor-nvim").lineSkipCursor(1) end,   mode = { "n", "x" } },
    { "<leader>n",       function() require("multicursor-nvim").matchAddCursor(1) end,   mode = { "n", "x" } },
    { "<leader>s",       function() require("multicursor-nvim").matchSkipCursor(1) end,  mode = { "n", "x" } },
    { "<leader>N",       function() require("multicursor-nvim").matchAddCursor(-1) end,  mode = { "n", "x" } },
    { "<leader>S",       function() require("multicursor-nvim").matchSkipCursor(-1) end, mode = { "n", "x" } },
    { "<c-leftmouse>",   function() require("multicursor-nvim").handleMouse() end },
    { "<c-leftdrag>",    function() require("multicursor-nvim").handleMouseDrag() end },
    { "<c-leftrelease>", function() require("multicursor-nvim").handleMouseRelease() end },
    { "<c-q>",           function() require("multicursor-nvim").toggleCursor() end,      mode = { "n", "x" } },
}

function M.setup_keymap()
    if vim.g.neovide then
        require 'core.keymap.neovide'
    end

    local bind = require 'util.functions'.bind
    local lazy_require = require 'util.functions'.lazy_require
    local lazy_call = require 'util.functions'.lazy_call

    -- REGION Init Dependencies
    local Hydra = require('hydra')
    local Keymap = vim.keymap.set
    local Command = vim.api.nvim_create_user_command
    local Menu = require("util.quickmenu")


    -- ENDREGION

    -- Test Menu
    local TestMenu = Menu({
        {
            ["Watch Test"] = function() lazy_require("neotest").watch.toggle() end,
            ["Toggle Summary"] = function() lazy_require("neotest").summary.toggle() end,
            ["Run Test"] = function() lazy_require("neotest").run.run() end,
            ["Show Cur Output"] = function() lazy_require("neotest").output.open() end,
            ["Toggle Output Panel"] = function() lazy_require("neotest").output_panel.toggle() end,
            ["Run With Debug"] = function() lazy_require("neotest").run.run({ strategy = "dap" }) end,

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

    -- #region Commands
    do
        Command('IcFormat', function() vim.lsp.buf.format() end, {})
        Command('IcRename', function() vim.lsp.buf.rename() end, {})
        Command('IcUseage', function() vim.lsp.buf.incoming_calls() end, {})
        Command('IcDefine', function() vim.lsp.buf.definition() end, {})
        Command('IcDAP', function() require 'osv'.launch({ port = 8086 }) end, {})
        Command('IcDAPUIOpen', function() require('dapui').open() end, {})
        Command('IcDAPUIClose', function() require('dapui').close() end, {})
        Command('IcDAPUIToggle', function() require('dapui').toggle() end, {})

        Command('IcTestMenu', bind(TestMenu.mount, TestMenu), {})
        Command('QuickMenu', bind(QuickMenu.mount, QuickMenu), {})

        -- Adaptation for misstake
        Command('Wa', bind(vim.cmd, "wa"), {})
        Command('Q', bind(vim.cmd, "q"), {})
        Command('W', bind(vim.cmd, "w"), {})
    end
    -- #endregion

    local keymap_opt = { noremap = true, silent = true }

    -- Navigation and files
    Keymap('n', '<F3>', '<Cmd>Outline<CR>', keymap_opt)
    Keymap('n', '<F4>', '<Cmd>Neotree toggle<CR>', keymap_opt)


    -- Debugging
    Keymap('n', '<F9>', '<Cmd>DapContinue<CR>', keymap_opt)
    Keymap('n', '<F10>', '<Cmd>DapStepOver<CR>', keymap_opt)
    Keymap('n', '<F11>', '<Cmd>DapStepInto<CR>', keymap_opt)
    Keymap('n', '<F12>', '<Cmd>DapStepOut<CR>', keymap_opt)
    Keymap('n', '<C-b>', function() require "dap".toggle_breakpoint() end, keymap_opt)

    -- LSP and code actions
    Keymap('n', '<C-]>', '<Cmd>IcDefine<CR>', keymap_opt)

    -- Utility menus
    Keymap('n', '<F5>', '<Cmd>QuickMenu<CR>', keymap_opt)
    Keymap('n', '<F6>', '<Cmd>IcDAPUIToggle<CR>', keymap_opt)
    Keymap('n', '<F2>', '<Cmd>Lazy<CR>', keymap_opt)

    -- Buffer Keymaps
    do
        Keymap('n', '<leader>q', ':bp<cr>:bd #<CR>', { noremap = true, silent = true })
    end

    Keymap('n', '<leader>O', '<Cmd>Oil<CR>', { noremap = true, silent = true, desc = 'Open Oil View' })

    Keymap('n', 'gf', require('snacks').image.hover, { noremap = true, silent = true })

    Keymap('n', '<C-x>q', '<Cmd>QuickMenu<CR>', { noremap = true, silent = true, desc = 'Open QuickMenu' })


    Keymap('n', '<C-x>f', "<Cmd>Pick files<CR>", { noremap = true, silent = true, desc = "Pick a file" })
    Keymap('n', '<C-x>ft', "<Cmd>FloatermNew<CR>", { noremap = true, silent = true, desc = "Open a floaterm" })

    Keymap('n', '<C-x><C-f>', require("mini.files").open, { noremap = true, silent = true, desc = "Open a file" })
    Keymap('n', '<C-x>a', require("global.ui_util.ui.actions"),
        { noremap = true, silent = true, desc = "Show LSP actions" })

    Keymap('n', '<C-x>t', '<Cmd>IcTestMenu<CR>', { noremap = true, silent = true, desc = "Test:Show Test Menu" })


    -- Overseer
    Keymap('n', '<C-x>oo', '<Cmd>OverseerToggle<CR>', { noremap = true, silent = true, desc = 'Toggle Overseer' })
    Keymap('n', '<C-x>or', '<Cmd>OverseerRun<CR>', { noremap = true, silent = true, desc = 'Run Task' })

    Keymap('n', '<A-x>', ":", { desc = 'Command line' })

    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
    Keymap("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
    Keymap("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

    -- Keymap('n', '<leader>mpt', require("mini.map").toggle, { noremap = true, silent = true, desc = "toggle minimap" })
    -- Keymap('n', '<leader>mps', require("mini.map").toggle_side, { noremap = true, silent = true, desc = "toggle minimap" })

    -- Oh Baby
    Keymap({ "n", "x" }, "cxk", function() vim.notify("只因你太美") end)


    --- Add or skip cursor above/below the main cursor.

    -- Newline below and above
    do
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
    end

    do
        local resession = require("resession")
        resession.setup({})
        -- Resession does NOTHING automagically, so we have to set up some keymaps
        vim.keymap.set("n", "<leader>ss", resession.save)
        vim.keymap.set("n", "<leader>sl", resession.load)
        vim.keymap.set("n", "<leader>sd", resession.delete)
    end

    -- #region Hydras

    Hydra({
        name = 'Window Change',
        hint = 'Navigate windows',
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
            { 'l', '<C-w><', { description = 'Increase window width' } },
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

    require 'core.keymap.cfg_edit'
end

return M
