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
  { "<C-,>",      "<cmd>BufferLineMovePrev<cr>",             desc = "Move buffer prev" },
  { "<C-.>",      "<cmd>BufferLineMoveNext<cr>",             desc = "Move buffer next" },
  { "[b",         "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
  { "]b",         "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
  { "[B",         "<cmd>BufferLineMovePrev<cr>",             desc = "Move buffer prev" },
  { "]B",         "<cmd>BufferLineMoveNext<cr>",             desc = "Move buffer next" },
}

---@type LazyKeysSpec[]
M.ufo = {
  { 'zR', function() require('ufo').openAllFolds() end,         noremap = true, silent = true, desc = "Open all folds" },
  { 'zM', function() require('ufo').closeAllFolds() end,        noremap = true, silent = true, desc = "Close all folds" },
  { 'zr', function() require('ufo').openFoldsExceptKinds() end, noremap = true, silent = true, desc = "Open folds except kinds" },
  { 'zm', function() require('ufo').closeFoldsWith() end,       noremap = true, silent = true, desc = "Close folds with" },
  {
    'K',
    function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end,
    noremap = true,
    silent = true,
    desc = "Peek fold or hover"
  },
}

---@type LazyKeysSpec[]
M.undotree = {
  { '<C-x>u',    function() require('undotree').toggle() end, noremap = true, silent = true, desc = "Toggle undotree" },
  { '<leader>u', function() require('undotree').toggle() end, noremap = true, silent = true, desc = "Toggle undotree" }
}

---@type LazyKeysSpec[]
M.telescope = {
  { '<C-c>', '<Cmd>Telescope buffers theme=get_ivy<CR>',        noremap = true, silent = true, desc = 'Show buffer list' },
  { '<C-f>', '<Cmd>Telescope find_files theme=get_dropdown<CR>' },
  { '<C-p>', '<Cmd>Telescope<CR>' },
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

---@type LazyKeysSpec[]
M.lazygit = { { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' } }

---@type LazyKeysSpec[]
-- disabled
-- M.rip_substitute = {
--   {
--     '<leader>fs', function() require('rip-substitute').sub() end, mode = { 'n', 'x' }, desc = ' rip substitute',
--   },
-- }

---@type LazyKeysSpec[]
M.flash = {
  { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
  { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
  { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
  { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
  { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
}

---@type LazyKeysSpec[]
M.snacks = {
  { "<leader>ps", function() Snacks.profiler.scratch() end,                 desc = "Profiler Scratch Buffer" },
  { "<leader>pt", function() Snacks.profiler.toggle() end,                  desc = "Profiler Toggle" },
  { "<leader>de", function() Snacks.dim.enable() end,                       desc = "Enable Dim" },
  { "<leader>dd", function() Snacks.dim.disable() end,                      desc = "Disable Dim" },
  { "<leader>gi", function() Snacks.picker.gh_issue() end,                  desc = "GitHub Issues (open)" },
  { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
  { "<leader>gp", function() Snacks.picker.gh_pr() end,                     desc = "GitHub Pull Requests (open)" },
  { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end,    desc = "GitHub Pull Requests (all)" },
  { "<leader>z",  function() Snacks.zen() end,                              desc = "zen" },

}

---@type LazyKeysSpec[]
M.trouble = {
  { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)" },
  { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics (Trouble)" },
  { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols (Trouble)" },
  { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)" },
  { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List (Trouble)" },
  { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List (Trouble)" }
}

---@type LazyKeysSpec[]
M.which_key = {
  { '<leader>?', function() require('which-key').show({ global = false }) end, desc = 'Buffer Local Keymaps (which-key)' }
}

M.resession = {
  { "<leader>ss", function() require("resession").save() end },
  { "<leader>sl", function() require("resession").load() end },
  { "<leader>sd", function() require("resession").delete() end },
}

---@type LazyKeysSpec[]
M.opencode = {
  -- { "<C-x>", function() require("opencode").select() end, mode = { "n", "x" }, desc = "Execute opencode action…" },
  { "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Ask opencode…" },
  { "<leader>oC", function() require("opencode").select() end, mode = { "n", "t" }, desc = "Select opencode" },
  { "go", function() return require("opencode").operator("@this ") end, mode = { "n", "x" }, desc = "Add range to opencode", expr = true },
  { "goo", function() return require("opencode").operator("@this ") .. "_" end, mode = "n", desc = "Add line to opencode", expr = true },
  { "<S-C-u>", function() require("opencode").command("session.half.page.up") end, mode = "n", desc = "Scroll opencode up" },
  { "<S-C-d>", function() require("opencode").command("session.half.page.down") end, mode = "n", desc = "Scroll opencode down" },
}

M.quickbuf = {
  { "<Tab>",      "<cmd>QuickBuf<CR>",          desc = "QuickBuf",   mode = "n" },
  { "<leader>qt", "<cmd>QuickBufPinToggle<CR>", desc = "Pin toggle", mode = "n" },
}

M.refactoring = {
  { "<leader>re",  function() return require("refactoring").extract_func() end,                                        desc = "Extract Function",         mode = { "n", "x" }, expr = true, },
  { "<leader>ree", function() return require("refactoring").extract_func() .. "_" end,                                 desc = "Extract Function (line)",  mode = "n",          expr = true, },
  { "<leader>rE",  function() return require("roperatoroperatoroperatorefactoring").extract_func_to_file() end,        desc = "Extract Function To File", mode = { "n", "x" }, expr = true, },
  { "<leader>rv",  function() return require("refactoring").extract_var() end,                                         desc = "Extract Variable",         mode = { "n", "x" }, expr = true, },
  { "<leader>rvv", function() return require("refactoring").extract_var() .. "_" end,                                  desc = "Extract Variable (line)",  mode = "n",          expr = true, },
  { "<leader>ri",  function() return require("refactoring").inline_var() end,                                          desc = "Inline Variable",          mode = { "n", "x" }, expr = true, },
  { "<leader>rI",  function() return require("refactoring").inline_func() end,                                         desc = "Inline function",          mode = { "n", "x" }, expr = true, },
  { "<leader>rs",  function() return require("refactoring").select_refactor() end,                                     desc = "Select refactor",          mode = { "n", "x" }, expr = true, },
  { "<leader>pv",  function() return require("refactoring.debug").print_var { output_location = "below" } .. "iw" end, desc = "Debug print var below",    mode = "n",          expr = true, },
  { "<leader>pv",  function() return require("refactoring.debug").print_var { output_location = "below" } end,         desc = "Debug print var below",    mode = "x",          expr = true, },
  { "<leader>pV",  function() return require("refactoring.debug").print_var { output_location = "above" } .. "iw" end, desc = "Debug print var above",    mode = "n",          expr = true, },
  { "<leader>pV",  function() return require("refactoring.debug").print_var { output_location = "above" } end,         desc = "Debug print var above",    mode = "x",          expr = true, },
  { "<leader>pe",  function() return require("refactoring.debug").print_exp { output_location = "below" } end,         desc = "Debug print exp below",    mode = { "x", "n" }, expr = true, },
  { "<leader>pee", function() return require("refactoring.debug").print_exp { output_location = "below" } .. "_" end,  desc = "Debug print exp below",    mode = "n",          expr = true, },
  { "<leader>pE",  function() return require("refactoring.debug").print_exp { output_location = "above" } end,         desc = "Debug print exp above",    mode = { "x", "n" }, expr = true, },
  { "<leader>pEE", function() return require("refactoring.debug").print_exp { output_location = "above" } .. "_" end,  desc = "Debug print exp above",    mode = "n",          expr = true, },
  { "<leader>pP",  function() return require("refactoring.debug").print_loc { output_location = "above" } end,         desc = "Debug print location",     mode = "n",          expr = true, },
  { "<leader>pp",  function() return require("refactoring.debug").print_loc { output_location = "below" } end,         desc = "Debug print location",     mode = "n",          expr = true, },
  { "<leader>pc",  function() return require("refactoring.debug").cleanup { restore_view = true } end,                 desc = "Debug print clean",        mode = { "x", "n" }, expr = true, remap = true, }
}

M.ssr = {
  { "<leader>sr", function() require("ssr").open() end, mode = { "n", "x" } }
}

M.treesj = {
  { '<leader>m', function() require('treesj').toggle() end,                                 mode = 'n' },
  { '<leader>M', function() require('treesj').toggle({ split = { recursive = true } }) end, mode = 'n' }
}

M.cppassist = {
  { '<A-o>',      '<Cmd>SwitchSourceAndHeader<CR>',                                  mode = 'n', },
  { '<leader>cf', '<Cmd>ImplementInSource<CR>',                                      mode = 'n', },
  { '<leader>cv', '<Cmd>ImplementOutOfClass<CR>',                                    mode = 'n', },
  { '<leader>gh', '<Cmd>GotoHeaderFile<CR>',                                         mode = 'n', },
  { '<leader>cf', '<Cmd>lua require("cppassist").ImplementInSourceInVisualMode<CR>', mode = 'v', },
}

M.treewalker = {
  -- { '<C-k>',   '<Cmd>Treewalker Up<CR>',        mode = { 'n', 'x' }, },
  -- { '<C-j>',   '<Cmd>Treewalker Down<CR>',      mode = { 'n', 'x' }, },
  -- { '<C-h>',   '<Cmd>Treewalker Right<CR>',     mode = { 'n', 'x' }, },
  -- { '<C-l>',   '<Cmd>Treewalker Left<CR>',      mode = { 'n', 'x' }, },
  -- { '<C-S-j>', '<Cmd>Treewalker SwapDown<CR>',  mode = 'n', },
  -- { '<C-S-k>', '<Cmd>Treewalker SwapUp<CR>',    mode = 'n', },
  -- { '<C-S-h>', '<Cmd>Treewalker SwapLeft<CR>',  mode = 'n', },
  -- { '<C-S-l>', '<Cmd>Treewalker SwapRight<CR>', mode = 'n', },
}

function M.setup_keymap()
  if vim.g.neovide then
    require 'core.keymap.neovide'
  end

  local bind = require 'util.functions'.bind
  local lazy_call = require 'util.functions'.lazy_call

  -- REGION Init Dependencies
  local Hydra = require('hydra')
  local Keymap = vim.keymap.set
  local Command = vim.api.nvim_create_user_command
  local Menu = require("util.quickmenu")
  local Lsp = require("util.lsp")
  -- ENDREGION

  -- Test Menu
  local TestMenu = Menu({
    {
      ["Watch Test"] = function() require("neotest").watch.toggle() end,
      ["Toggle Summary"] = function() require("neotest").summary.toggle() end,
      ["Run Test"] = function() require("neotest").run.run() end,
      ["Show Cur Output"] = function() require("neotest").output.open() end,
      ["Toggle Output Panel"] = function() require("neotest").output_panel.toggle() end,
      ["Run With Debug"] = function() require("neotest").run.run({ strategy = "dap" }) end,

    }
  })

  -- QuickMenu
  local QuickMenu = Menu({
    {
      ["Search"] = lazy_call('telescope.builtin', 'builtin'),
      ["Questions"] = bind(lazy_call("trouble", "open"), "questions"),
      ["Find and Replace"] = bind(vim.cmd, "GrugFar"),
      ["Find in Files"] = bind(vim.cmd, "RipSubstitute"),
      ["Git"] = bind(vim.cmd, "LazyGit"),
      ["Debug"] = bind(vim.cmd, "DapNew"),
      ["Todo"] = bind(vim.cmd, "Trouble todo"),
      ["Tasks"] = bind(vim.cmd, "terminal dooit"),
      ["Run"] = bind(vim.cmd, "OverseerRun"),
    }
  })

  -- #region Commands
  do
    Command('IcUseage', function() vim.lsp.buf.incoming_calls() end, {})
    Command('IcDefine', function() vim.lsp.buf.definition() end, {})
    Command('IcLspRestart', Lsp.lsp_restart, { desc = 'Restart LSP servers for current buffer' })
    Command('IcDAP', function() require 'osv'.launch({ port = 8086 }) end, {})
    Command('IcDAPUIOpen', function() require('dapui').open() end, {})
    Command('IcDAPUIClose', function() require('dapui').close() end, {})
    Command('IcDAPUIToggle', function() require('dapui').toggle() end, {})

    Command('IcTestMenu', bind(TestMenu.mount, TestMenu), {})
    Command('QuickMenu', bind(QuickMenu.mount, QuickMenu), {})

    local jp = require("jit.p")

    Command('PrefStart', bind(jp.start,"csm0GlFpi1,10","/home/ictye/pref.log"), {})

    Command('PrefStop', bind(jp.stop), {})

    -- Adaptation for misstake
    Command('W', bind(vim.cmd, "w"), {})
    Command('Wa', bind(vim.cmd, "wa"), {})
    Command('Q', bind(vim.cmd, "q"), {})
    Command('Qa', bind(vim.cmd, "qa"), {})
  end
  -- #endregion

  local keymap_opt = { noremap = true, silent = true }

  -- Keymap("n",'<C-c>','<Cmd>Pick buffers<CR>'   ,{desc="",noremap=true})

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
  Keymap('n', '<C-x>tlt', "<Cmd>TunnelVision toggle<CR>", { noremap = true, silent = true, desc = "Toggle TunnelVision" })

  Keymap('n', '<C-x><C-f>', function() require("mini.files").open() end,
    { noremap = true, silent = true, desc = "Open a file" })
  Keymap('n', '<C-x>a', require("global.ui_util.ui.actions"),
    { noremap = true, silent = true, desc = "Show LSP actions" })

  Keymap('n', '<C-x>t', '<Cmd>IcTestMenu<CR>', { noremap = true, silent = true, desc = "Test:Show Test Menu" })
  Keymap('n', '<C-x>tm', '<Cmd>IcTestMenu<CR>', { noremap = true, silent = true, desc = "Test:Show Test Menu" })

  Keymap('n', '<C-x>ft', require("global.ui_util.ui.float_term"),
    { noremap = true, silent = true, desc = "Test:Show Test Menu" })
  Keymap('n', '<leader>lj', function() require("global.ui_util.ui.float_term")("jjui") end,
    { noremap = true, silent = true, desc = "Test:Show Test Menu" })

  -- Overseer
  Keymap('n', '<C-x>oo', '<Cmd>OverseerToggle<CR>', { noremap = true, silent = true, desc = 'Toggle Overseer' })
  Keymap('n', '<C-x>or', '<Cmd>OverseerRun<CR>', { noremap = true, silent = true, desc = 'Run Task' })


  -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
  Keymap("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
  Keymap("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

  -- Keymap('n', '<leader>mpt', require("mini.map").toggle, { noremap = true, silent = true, desc = "toggle minimap" })
  -- Keymap('n', '<leader>mps', require("mini.map").toggle_side, { noremap = true, silent = true, desc = "toggle minimap" })

  -- Oh Baby
  Keymap({ "n", "x" }, "cxk", function() vim.notify("只因你太美") end)
  Keymap({ "n", "x" }, "<leader>ts", "<Cmd>Translate zh-CN<CR>", { desc = "Translate to CN" })

  -- movement
  Keymap({ 'n', 'v' }, '<C-k>', '<cmd>Treewalker Up<cr>', { silent = true })
  Keymap({ 'n', 'v' }, '<C-j>', '<cmd>Treewalker Down<cr>', { silent = true })
  Keymap({ 'n', 'v' }, '<C-h>', '<cmd>Treewalker Left<cr>', { silent = true })
  Keymap({ 'n', 'v' }, '<C-l>', '<cmd>Treewalker Right<cr>', { silent = true })
  Keymap('n', '<C-S-k>', '<cmd>Treewalker SwapUp<cr>', { silent = true })
  Keymap('n', '<C-S-j>', '<cmd>Treewalker SwapDown<cr>', { silent = true })
  Keymap('n', '<C-S-h>', '<cmd>Treewalker SwapLeft<cr>', { silent = true })
  Keymap('n', '<C-S-l>', '<cmd>Treewalker SwapRight<cr>', { silent = true })


  Keymap({ "x", "o" }, "am", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
  end, { desc = "Outer Function" })
  Keymap({ "x", "o" }, "im", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
  end, { desc = "Inner Function" })
  Keymap({ "x", "o" }, "ac", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
  end, { desc = "Outer Class" })
  Keymap({ "x", "o" }, "ic", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
  end, { desc = "Inner Class" })
  Keymap({ "x", "o" }, "as", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
  end, { desc = "Scope Textobject" })
  -- You can use the capture groups defined in `textobjects.scm`
  Keymap({ "n", "x", "o" }, "]m", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
  end, { desc = "Next function start" })
  Keymap({ "n", "x", "o" }, "]]", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
  end, { desc = "Next class start" })
  -- You can also pass a list to group multiple queries.
  Keymap({ "n", "x", "o" }, "]o", function()
    require("nvim-treesitter-textobjects.move").goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
  end, { desc = "Next loop start" })
  -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
  Keymap({ "n", "x", "o" }, "]s", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
  end, { desc = "Next scope start" })
  Keymap({ "n", "x", "o" }, "]z", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
  end, { desc = "Next fold start" })

  Keymap({ "n", "x", "o" }, "]M", function()
    require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
  end, { desc = "Next function end" })
  Keymap({ "n", "x", "o" }, "][", function()
    require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
  end, { desc = "Next class end" })

  Keymap({ "n", "x", "o" }, "[m", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
  end, { desc = "Prev function start" })
  Keymap({ "n", "x", "o" }, "[[", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
  end, { desc = "Prev class start" })

  Keymap({ "n", "x", "o" }, "[M", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
  end, { desc = "Prev function end" })
  Keymap({ "n", "x", "o" }, "[]", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
  end, { desc = "Prev class end" })

  -- Go to either the start or the end, whichever is closer.
  -- Use if you want more granular movements
  Keymap({ "n", "x", "o" }, "]d", function()
    require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects")
  end, { desc = "Next conditional" })
  Keymap({ "n", "x", "o" }, "[d", function()
    require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects")
  end, { desc = "Prev conditional" })

  Keymap("n", "<leader>a", function()
    require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
  end, { desc = "Swap param next" })
  Keymap("n", "<leader>A", function()
    require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.outer"
  end, { desc = "Swap param prev" })

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

  -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
  vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
  vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

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

  Hydra({
    name = "DapMenu",
    mode = 'n',
    body = '<leader>dp',
    hint = [[
'c', '<Cmd>DapContinue<CR>',
'i', '<Cmd>DapStepInto<CR>',
'o', '<Cmd>DapStepOut<CR>',
'p', '<Cmd>DapStepOver<CR>',
'n', '<Cmd>DapNext<CR>',
]],
    heads = {
      { 'c', '<Cmd>DapContinue<CR>',                            { description = 'Continue' } },
      { 'i', '<Cmd>DapStepInto<CR>',                            { description = 'Step Into' } },
      { 'o', '<Cmd>DapStepOut<CR>',                             { description = 'Step Out' } },
      { 'p', '<Cmd>DapStepOver<CR>',                            { description = 'Step Over' } },
      { 'n', '<Cmd>DapNext<CR>',                                { description = 'Next Breakpoint' } },
      { 's', function() require("dap").stop() end,              { description = 'Stop' } },
      { 'r', function() require("dap").restart() end,           { description = 'Restart' } },
      { 'd', function() require("dap").disconnect() end,        { description = 'Disconnect' } },
      { 't', function() require("dap").toggle_breakpoint() end, { description = 'Toggle Breakpoint' } },
      { 'u', function() require('dapui').toggle() end,          { description = 'Toggle UI' } },
      { 'e', function() require('dapui').eval() end,            { description = 'Eval' } },
    }
  })

  require 'core.keymap.cfg_edit'
end

return M
