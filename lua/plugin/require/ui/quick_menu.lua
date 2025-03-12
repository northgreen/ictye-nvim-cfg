--- @return LazyPluginSpec
local bind = require'util.functions'.bind
local lazy_call = require'util.functions'.lazy_call

return {
    "quick_menu",
    dev = true,
    dependencies = {'MunifTanjim/nui.nvim'},
    opts = {
        opt = {
            {
                ["Search"] = lazy_call('telescope.builtin', 'builtin'),
                ["Questions"] = bind(lazy_call("trouble", "open"), "questions"),
                ["Find and Replace"] = bind(vim.cmd, "GrugFar"),
                ["Find in Files"] = bind(vim.cmd, "RipSubstitute"),
                ["Terminal"] = bind(vim.cmd, "FloatermNew powershell"),
                ["Git"] = bind(vim.cmd, "LazyGit"),
                ["Debug"] = bind(vim.cmd, "DapNew"),
                ["Todo"] = bind(vim.cmd, "Trouble todo")
            }
        }
    },
}
