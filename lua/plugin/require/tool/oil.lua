return {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
        columns = {
            "icon",
            "size",
            "mtime",
            "permissions"
        },
        constrain_cursor = "name",
        watch_for_changes = true,
        lsp_file_method = {
            enabled = true,
        },
        view_options = {
            is_hidden_file = function (name,bufnr)
                local n = name:match("^%.") ~= nil
                -- ignore rubbish file for godot
                local n = n or name:match("(%.uid)$") ~= nil
                local n = n or name:match("(%.import)$") ~= nil
                return n
            end
        },
        keymaps = {
            [_G.options.keymaps.exit] = { "actions.close", mode = "n" }
        }
    },
    -- Optional dependencies
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
}
