return {
    'stevearc/overseer.nvim',
    ---@module 'overseer'
    ---@type overseer.SetupOpts
    opts = {
        task_list = {
            keymaps = {
                [options.keymaps.exit] = { "<CMD>close<CR>", desc = "Close task list" },
            }
        }
    },
}
