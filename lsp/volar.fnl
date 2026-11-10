;;;@brief
;;;
;;; Renamed to [vue_ls](#vue_ls)

;;;@type vim.lsp.Config
(vim.tbl_extend "force" vim.lsp.config.vue_ls
  {:on_init (λ [...]
      (vim.deprecate "volar" "vue_ls" "3.0.0" "nvim-lspconfig" false)
      (when vim.lsp.config.vue_ls.on_init
        (vim.lsp.config.vue_ls.on_init ...)))})
