--- @return LazyPluginSpec
return {
    "folke/snacks.nvim",
    opts = {
        profiler = {
            enable = true,
            keymaps = {
                toggle = "<leader>pp"
            }
        },
        big_file = {
            enable = true,
        },
    },
    keys = {
      { "<leader>ps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Bufer" },
      { "<leader>pt", function() Snacks.profiler.toggle() end, desc = "Profiler Toggle" }
    }
}
