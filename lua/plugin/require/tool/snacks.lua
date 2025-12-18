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
    keys = {
        { "<leader>ps", function() Snacks.profiler.scratch() end,                 desc = "Profiler Scratch Bufer" },
        { "<leader>pt", function() Snacks.profiler.toggle() end,                  desc = "Profiler Toggle" },
        { "<leader>de", function() Snacks.dim.enable() end,                       desc = "Enable Dim" },
        { "<leader>dd", function() Snacks.dim.disable() end,                      desc = "Disable Dim" },
        { "<leader>gi", function() Snacks.picker.gh_issue() end,                  desc = "GitHub Issues (open)" },
        { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
        { "<leader>gp", function() Snacks.picker.gh_pr() end,                     desc = "GitHub Pull Requests (open)" },
        { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end,    desc = "GitHub Pull Requests (all)" },
    }
}
