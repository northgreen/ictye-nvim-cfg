return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {'nvim-lua/plenary.nvim'},
    cmd = {'Telescope'},
    config = function()
        local telescope = require('telescope')
        telescope.setup {
            defaults = {
                mappings = {
                    i = {["<C-h>"] = "which_key"},
                    n = {['q'] = require('telescope.actions').close}
                }
            },
            pickers = {},
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case"
                }
            }
        }

        -- pcall(telescope.load_extension, 'project_toolchain')
        pcall(telescope.load_extension, "noice")
        pcall(telescope.load_extension, "fzf")
    end
}
