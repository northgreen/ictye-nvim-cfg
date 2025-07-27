local twc = require'util.functions'.three_way_compare
return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
        provider = "openai",
        openai = {
            endpoint = "https://api.openai-proxy.org/v1",
            model = "deepseek-chat",
            timeout = 30000,
            temperature = 0,
            max_tokens = 4096
        }
    },
    build = twc(options.env.os.win,
                "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false",
                "make"),
    dependencies = {
        "stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
		"echasnovski/mini.pick",
        "nvim-telescope/telescope.nvim",
		"hrsh7th/nvim-cmp",
		"ibhagwan/fzf-lua",
        "nvim-tree/nvim-web-devicons",
		"zbirenbaum/copilot.lua", {
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {insert_mode = true},
                    use_absolute_path = true
                }
            }
        }, {
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {file_types = {"markdown", "Avante"}},
            ft = {"markdown", "Avante"}
        }
    }
}
