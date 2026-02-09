return -- lazy.nvim
{
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', },
    -- event = "VeryLazy",
    ft = {'cs','fs'},
    -- enabled = false,
    config = function()
        require("easy-dotnet").setup({
            lsp = {
                enabled = false, -- it will take away many of inotify,FUCK!!!!
            },
            debugger = {
                bin_path = "netcoredbg",
            }
        })
    end
}
