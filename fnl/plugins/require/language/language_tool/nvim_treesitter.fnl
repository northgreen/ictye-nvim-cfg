{1 "nvim-treesitter/nvim-treesitter"
  :build ":TSUpdate"
  :event "BufReadPre"
  :enabled false
  :opt {
    :ensure_installed ["c" "lua" "vim" "vimdoc" "markdown" "json" "c_sharp" "fsharp" "xml"]
    :sync_install false
    :highlight {:enable true}
    :indent {:enable true}
    :modules {}
    :auto_install true
    :ignore_install ["vim" "vimdoc"]}
  :config (λ [_ opt]
    (local configs (require :nvim-treesitter.configs))
    (tset (require :nvim-treesitter.install) :prefer_git false)
    (tset (require :nvim-treesitter.install) :compilers ["clang" "gcc"])
    (configs.setup opt)
    (vim.api.nvim_create_autocmd
      "FileType"
      {:pattern ["rust" "c" "fsharp" "cpp" "vimdoc" "json" "markdown" "xml"]
        :callback (fn []
          (vim.treesitter.start)
          (set vim.wo.foldexpr "v:lua.vim.treesitter.foldexpr()")
          (set vim.wo.foldmethod "expr"))}))}
