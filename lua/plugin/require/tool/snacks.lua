--- @return LazyPluginSpec
return {
    "folke/snacks.nvim",
    opts = {
        profiler = {
            enabled = true,
            keymaps = {
                toggle = "<leader>pp"
            }
        },
        big_file = {
            enabled = true,
        },
        dim = {
            enabled = true,
        },
        image = {
            enabled = true,
            inline = true,
            doc = {
                enabled = true,
                inline = true,
                float = true,
                max_width = 80,
                max_height = 40,
                conceal = function(lang, type)
                    -- only conceal math expressions
                    return type == "math"
                end,
            },
            resolve = function(path, src)
                if require("obsidian.api").path_is_note(path) then
                    return require("obsidian.api").resolve_image_path(src)
                end
                return path
            end,
        },
        gh = {
            enabled = true
        },
        picker = {

        }
    },
    keys = require("core.keymap").snacks
}
