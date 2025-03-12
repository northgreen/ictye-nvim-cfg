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
                    i = {
                        ["<C-h>"] = "which_key"
                    },
                    n = {['q'] = require('telescope.actions').close}
                }
            },
            pickers = {
            },
            extensions = {
            }
        }

        pcall(telescope.load_extension, 'project_dir_cfg')
        pcall(telescope.load_extension, "noice")
    end
}
