--- @return LazyPluginSpec
return {
    "folke/trouble.nvim",
    opts = {
        modes = {
            questions = {
                mode = "diagnostics",
                desc = "Trouble Diagnostics",
                relative = "editor",
            }
        },
        icons = {
            kinds = {
                File = ' ',
                Module = ' ',
                Namespace = ' ',
                Package = ' ',
                Class = ' ',
                Method = ' ',
                Property = ' ',
                Field = ' ',
                Constructor = ' ',
                Enum = ' ',
                Interface = ' ',
                Function = ' ',
                Variable = ' ',
                Constant = ' ',
                String = ' ',
                Number = ' ',
                Boolean = ' ',
                Array = ' ',
                Object = ' ',
                Key = ' ',
                Null = ' ',
                EnumMember = ' ',
                Struct = ' ',
                Event = ' ',
                Operator = ' ',
                TypeParameter = ' '
            }
        }
    },
    cmd = "Trouble",
    keys = require("core.keymap").trouble
}
