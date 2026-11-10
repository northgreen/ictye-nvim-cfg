;;;@brief
;;;
;;; https://github.com/golang/tools/tree/master/gopls
;;;
;;; Google's lsp server for golang.

;;; @class go_dir_custom_args
;;;
;;; @field envvar_id string
;;;
;;; @field custom_subdir string?

(var mod_cache nil)
(var std_lib nil)

;;;@param custom_args go_dir_custom_args
;;;@param on_complete fun(dir: string | nil)
(λ identify_go_dir [?custom_args ?on_complete]
  (let [cmd ["go" "env" ?custom_args.envvar_id]]
    (vim.system cmd {:text true}
      (λ [?output]
        (var res (vim.trim (or ?output.stdout "")))
        (if (and (= ?output.code 0) (not= res ""))
          (do
            (when (and ?custom_args.custom_subdir (not= ?custom_args.custom_subdir ""))
              (set res (.. res ?custom_args.custom_subdir)))
            (?on_complete res))
          (do
            (vim.schedule
              (λ []
                (vim.notify
                  (: (.. "[gopls] identify " ?custom_args.envvar_id " dir cmd failed with code %d: %s\n%s")
                    :format ?output.code (vim.inspect cmd) ?output.stderr))))
            (?on_complete nil)))))))

;;;@return string?
(λ get_std_lib_dir []
  (if (and std_lib (not= std_lib ""))
    std_lib
    (do
      (identify_go_dir {:envvar_id "GOROOT" :custom_subdir "/src"}
        (λ [?dir]
          (when ?dir
            (set std_lib ?dir))))
      std_lib)))

;;;@return string?
(λ get_mod_cache_dir []
  (if (and mod_cache (not= mod_cache ""))
    mod_cache
    (do
      (identify_go_dir {:envvar_id "GOMODCACHE"}
        (λ [?dir]
          (when ?dir
            (set mod_cache ?dir))))
      mod_cache)))

;;;@param fname string
;;;@return string?
(λ get_root_dir [?fname]
  (when (and mod_cache (= (?fname:sub 1 (length mod_cache)) mod_cache))
    (let [clients (vim.lsp.get_clients {:name "gopls"})]
      (when (> (length clients) 0)
        (lua "return clients[#clients].config.root_dir"))))
  (when (and std_lib (= (?fname:sub 1 (length std_lib)) std_lib))
    (let [clients (vim.lsp.get_clients {:name "gopls"})]
      (when (> (length clients) 0)
        (lua "return clients[#clients].config.root_dir"))))
  (or (vim.fs.root ?fname "go.work")
    (vim.fs.root ?fname "go.mod")
    (vim.fs.root ?fname ".git")))

;;;@type vim.lsp.Config
{:cmd ["gopls"]
  :filetypes ["go" "gomod" "gowork" "gotmpl"]
  :root_dir (λ [?bufnr ?on_dir]
    (let [fname (vim.api.nvim_buf_get_name ?bufnr)]
      (get_mod_cache_dir)
      (get_std_lib_dir)
      ; see: https://github.com/neovim/nvim-lspconfig/issues/804
      (?on_dir (get_root_dir fname))))}
