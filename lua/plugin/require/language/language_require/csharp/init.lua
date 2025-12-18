return {
    "iabdelkareem/csharp.nvim",
    enabled = false;
    dependencies = {
        "williamboman/mason.nvim", -- Required, automatically installs omnisharp
        "mfussenegger/nvim-dap",
        "Tastyep/structlog.nvim",  -- Optional, but highly recommended for debugging
    },
    config = function()
        require("csharp").setup()
    end
}
