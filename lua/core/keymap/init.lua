if vim.g.neovide then
    require 'core.keymap.neovide'
end

-- REGION Init Dependencies
local mc = require("multicursor-nvim")
local Hydra = require('hydra')
local Keymap = vim.keymap.set
local Command = vim.api.nvim_create_user_command
local Menu = require("util.quickmenu")
local WhichKey = require("which-key")

local bind = require 'util.functions'.bind
local lazy_require = require 'util.functions'.lazy_require
local lazy_call = require 'util.functions'.lazy_call

local neotest = lazy_require("neotest")
local telescope_builtin = lazy_require("telescope.builtin")
-- ENDREGION

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

-- #region Commands
do
    Command('IcFormat'     , function() vim.lsp.buf.format() end                 , {})
    Command('IcRename'     , function() vim.lsp.buf.rename() end                 , {})
    Command('IcUseage'     , function() vim.lsp.buf.incoming_calls() end         , {})
    Command('IcDefine'     , function() vim.lsp.buf.definition() end             , {})
    Command('IcDAP'        , function() require 'osv'.launch({ port = 8086 }) end, {})
    Command('IcDAPUIOpen'  , function() require('dapui').open() end              , {})
    Command('IcDAPUIClose' , function() require('dapui').close() end             , {})
    Command('IcDAPUIToggle', function() require('dapui').toggle() end            , {})

    Command('IcTestMenu'   , bind(TestMenu.mount, TestMenu)                      , {})
    Command('QuickMenu'    , bind(QuickMenu.mount, QuickMenu)                    , {})

    -- Adaptation for misstake
    Command('Wa', bind(vim.cmd, "wa"), {})
    Command('Q', bind(vim.cmd, "q"), {})
    Command('W', bind(vim.cmd, "w"), {})
end
-- #endregion

local keymap_opt = { noremap = true, silent = true }

-- Navigation and files
Keymap('n', '<F3>' , '<Cmd>Outline<CR>'             , keymap_opt)
Keymap('n', '<F4>' , '<Cmd>Neotree toggle<CR>'      , keymap_opt)
Keymap('n', '<C-f>', '<Cmd>Telescope find_files<CR>', keymap_opt)
Keymap('n', '<C-p>', '<Cmd>Telescope<CR>'           , keymap_opt)

-- Debugging
Keymap('n', '<F9>' , '<Cmd>DapContinue<CR>'                         , keymap_opt)
Keymap('n', '<F10>', '<Cmd>DapStepOver<CR>'                         , keymap_opt)
Keymap('n', '<F11>', '<Cmd>DapStepInto<CR>'                         , keymap_opt)
Keymap('n', '<F12>', '<Cmd>DapStepOut<CR>'                          , keymap_opt)
Keymap('n', '<C-b>', '<Cmd>lua require"dap".toggle_breakpoint()<CR>', keymap_opt)

-- LSP and code actions
Keymap('n', '<C-]>', '<Cmd>IcDefine<CR>', keymap_opt)

-- Utility menus
Keymap('n', '<F5>', '<Cmd>QuickMenu<CR>'    , keymap_opt)
Keymap('n', '<F6>', '<Cmd>IcDAPUIToggle<CR>', keymap_opt)
Keymap('n', '<F2>', '<Cmd>Lazy<CR>'         , keymap_opt)

-- Buffer Keymaps
do
    Keymap('n', '<leader>1', '<Cmd>BufferLineGoToBuffer 1<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>2', '<Cmd>BufferLineGoToBuffer 2<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>3', '<Cmd>BufferLineGoToBuffer 3<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>4', '<Cmd>BufferLineGoToBuffer 4<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>5', '<Cmd>BufferLineGoToBuffer 5<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>6', '<Cmd>BufferLineGoToBuffer 6<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>7', '<Cmd>BufferLineGoToBuffer 7<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>8', '<Cmd>BufferLineGoToBuffer 8<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>9', '<Cmd>BufferLineGoToBuffer 9<CR>', { noremap = true, silent = true })
    Keymap('n', '<leader>-', '<Cmd>BufferLineCyclePrev<CR>'   , { noremap = true, silent = true })
    Keymap('n', '<leader>=', '<Cmd>BufferLineCycleNext<CR>'   , { noremap = true, silent = true })
    Keymap('n', '<leader>q', ':bp<cr>:bd #<CR>'               , { noremap = true, silent = true })
end

Keymap('n', '<leader>O', '<Cmd>Oil<CR>', { noremap = true, silent = true, desc = 'Open Oil View' })

Keymap('n', 'gf', require('snacks').image.hover, { noremap = true, silent = true })

Keymap('n', '<C-x>q', '<Cmd>QuickMenu<CR>', { noremap = true, silent = true, desc = 'Open QuickMenu' })

Keymap('n', '<C-x>u', require 'undotree'.toggle, { noremap = true, silent = true, desc = "Toggle undotree" })

Keymap('n', '<C-x>f', "<Cmd>Pick files<CR>", { noremap = true, silent = true, desc = "Pick a file" })
Keymap('n', '<C-x>ft', "<Cmd>FloatermNew<CR>", { noremap = true, silent = true, desc = "Open a floaterm" })
Keymap('n', '<C-x><C-f>', require("mini.files").open, { noremap = true, silent = true, desc = "Open a file" })
Keymap('n', '<C-x>a', require("global.ui_util.ui.actions"), { noremap = true, silent = true, desc = "Show LSP actions" })
Keymap('n', '<C-x>t', '<Cmd>IcTestMenu<CR>', { noremap = true, silent = true, desc = "Test:Show Test Menu" })
Keymap({ 'n', 't' }, '<C-x><C-b>', '<Cmd>Telescope buffers<CR>', { noremap = true, silent = true, desc = 'Show buffer list' })
Keymap('n', '<C-x>bf', '<Cmd>Telescope buffers<CR>', { noremap = true, silent = true, desc = 'Show buffer list' })

-- Overseer
Keymap('n', '<C-x>oo', '<Cmd>OverseerToggle<CR>', { noremap = true, silent = true, desc = 'Toggle Overseer' })
Keymap('n', '<C-x>or', '<Cmd>OverseerRun<CR>'   , { noremap = true, silent = true, desc = 'Run Task' })

Keymap('n', '<A-x>', ":", { desc = 'Command line' })

do
    local opencode = require("opencode")
    Keymap({ "n", "x" }, "<C-a>", function() opencode.ask("@this: ", { submit = true }) end,
        { desc = "Ask opencode…" })
    Keymap({ "n", "x" }, "<C-x>", function() opencode.select() end, { desc = "Execute opencode action…" })
    Keymap({ "n", "t" }, "<C-.>", function() opencode.toggle() end, { desc = "Toggle opencode" })

    Keymap({ "n", "x" }, "go", function() return opencode.operator("@this ") end,
        { desc = "Add range to opencode", expr = true })
    Keymap("n", "goo", function() return opencode.operator("@this ") .. "_" end,
        { desc = "Add line to opencode", expr = true })

    Keymap({"n", "x"}, "<S-C-u>", function() opencode.command("session.half.page.up") end,
        { desc = "Scroll opencode up" })
    Keymap({"n", "x"}, "<S-C-d>", function() opencode.command("session.half.page.down") end,
        { desc = "Scroll opencode down" })
end

-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
Keymap("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
Keymap("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

-- Keymap('n', '<leader>mpt', require("mini.map").toggle, { noremap = true, silent = true, desc = "toggle minimap" })
-- Keymap('n', '<leader>mps', require("mini.map").toggle_side, { noremap = true, silent = true, desc = "toggle minimap" })

-- Oh Baby
Keymap({ "n", "x" }, "cxk", function() vim.notify("只因你太美") end)


--- Add or skip cursor above/below the main cursor.
do
    Keymap({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end)
    Keymap({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end)
    Keymap({ "n", "x" }, "<leader><up>", function() mc.lineSkipCursor(-1) end)
    Keymap({ "n", "x" }, "<leader><down>", function() mc.lineSkipCursor(1) end)
    Keymap({ "n", "x" }, "<leader>n", function() mc.matchAddCursor(1) end)
    Keymap({ "n", "x" }, "<leader>s", function() mc.matchSkipCursor(1) end)
    Keymap({ "n", "x" }, "<leader>N", function() mc.matchAddCursor(-1) end)
    Keymap({ "n", "x" }, "<leader>S", function() mc.matchSkipCursor(-1) end)

    Keymap("n", "<c-leftmouse>", mc.handleMouse)
    Keymap("n", "<c-leftdrag>", mc.handleMouseDrag)
    Keymap("n", "<c-leftrelease>", mc.handleMouseRelease)
    Keymap({ "n", "x" }, "<c-q>", mc.toggleCursor)

    mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)


        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            else
                mc.clearCursors()
            end
        end)
    end)
end


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

-- NOTE: Confident With multi cursor

-- Hydra({
--     name = "MultiCursor",
--     mode = 'n',
--     body = '<leader>c',
--     hint = "MultiCursor",
--     config = {
--         hint = {
--         }
--     },
--     heads = {
--         { 'j',     bind(mc.lineAddCursor, 1),    { description = 'Add cursor below' } },
--         { 'k',     bind(mc.lineAddCursor, -1),   { description = 'Add cursor above' } },
--         { '<C-j>', bind(mc.lineSkipCursor, 1),   { description = 'Skip cursor below' } },
--         { '<C-k>', bind(mc.lineSkipCursor, -1),  { description = 'Skip cursor above' } },
--
--         { 'l',     mc.nextCursor,                { description = 'Move to next cursor' } },
--         { 'h',     mc.prevCursor,                { description = 'Move to previous cursor' } },
--
--         { 'n',     bind(mc.matchAddCursor, 1),   { description = 'Match add cursor below' },
--         { '<C-n>', bind(mc.matchSkipCursor, 1),  { description = 'Match skip cursor below' },
--         { 'p',     bind(mc.matchAddCursor, -1),  { description = 'Match add cursor above' } },
--         { '<C-p>', bind(mc.matchSkipCursor, -1), { description = 'Match skip cursor above' },
--
--         { 'd',     mc.deleteCursor,              { description = 'Delete main cursor' } },
--         { 'x',     mc.toggleCursor,              { description = 'Toggle multi-cursor mode' } },
--
--         { 's',     mc.searchAddCursor,           { description = 'Match cursors' } },
--
--         { 'q',     nil,                          { exit = true, description = 'Exit multi-cursor mode' } }
--     }
-- })

-- #endregion

require 'core.keymap.cfg_edit'
