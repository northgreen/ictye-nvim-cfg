{1 "iabdelkareem/csharp.nvim"
 :enabled false
 :dependencies ["williamboman/mason.nvim" "mfussenegger/nvim-dap"
                "Tastyep/structlog.nvim"]
 :config (fn []
           ((. (require :csharp) :setup))
           (values))}
