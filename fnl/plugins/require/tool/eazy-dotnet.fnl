;; lazy.nvim
{1 "GustavEikaas/easy-dotnet.nvim"
 :dependencies ["nvim-lua/plenary.nvim" "nvim-telescope/telescope.nvim"]
 ;; :event "VeryLazy"
 :ft ["cs" "fs"]
 ;; :enabled false
 :config (fn []
           ((. (require :easy-dotnet) :setup)
            {:lsp {;; The built-in LSP consumes too many inotify watches.
                   :enabled false}
             :debugger {:bin_path "netcoredbg"}})
           nil)}
