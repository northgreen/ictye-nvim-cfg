;;;@brief
;;;
;;; https://sr.ht/~xerool/fennel-ls/
;;;
;;; A language server for fennel.
;;;
;;; fennel-ls is configured using the closest file to your working directory named `flsproject.fnl`.
;;; All fennel-ls configuration options [can be found here](https://git.sr.ht/~xerool/fennel-ls/tree/HEAD/docs/manual.md#configuration).

;;;@type vim.lsp.Config
{:cmd ["fennel-ls"]
  :filetypes ["fennel"]
  :root_dir (λ [?bufnr ?on_dir]
    (let [fname (vim.api.nvim_buf_get_name ?bufnr)
        has_fls_project_cfg (λ [?path]
          (let [fnlpath (vim.fs.joinpath ?path "flsproject.fnl")]
            (= (. (or (vim.uv.fs_stat fnlpath) {}) :type) "file")))]
      (?on_dir (or (: (vim.iter (vim.fs.parents fname)) :find has_fls_project_cfg)
          (vim.fs.root 0 ".git")))))
  :settings {}
  :capabilities {:offsetEncoding ["utf-8" "utf-16"]}}
