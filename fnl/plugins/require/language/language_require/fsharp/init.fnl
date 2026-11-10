{1 "ionide/Ionide-vim"
  :enabled false
  :config (fn []
    (vim.api.nvim_create_autocmd
      ["CursorHold"]
      {:pattern ["*.fs" "*.fsi" "*.fsx"]
        :callback (fn []
          ((. vim.fn :fsharp#showTooltip))
          (values))})
    (values))}
