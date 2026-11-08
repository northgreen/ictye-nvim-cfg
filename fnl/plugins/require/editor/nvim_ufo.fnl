{1 "kevinhwang91/nvim-ufo"
 :event "BufRead"
 :keys (. (require :core.keymap) :ufo)
 :config (fn []
           (set vim.o.foldcolumn "1")
           (set vim.o.foldlevel 99)
           (set vim.o.foldlevelstart 99)
           (set vim.o.foldenable true)
           (let [capabilities (vim.lsp.protocol.make_client_capabilities)]
             (set capabilities.textDocument.foldingRange
                  {:dynamicRegistration false :lineFoldingOnly true}))
           ((. (require :ufo) :setup) {})
           (values))
 :dependencies ["kevinhwang91/promise-async"]}
