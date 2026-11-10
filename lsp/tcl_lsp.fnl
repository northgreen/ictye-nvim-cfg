;;;@brief
;;;
;;; https://github.com/bitwisecook/tcl-lsp
;;;
;;; `tcl-lsp-server`, a language server for Tcl (native Rust binary,
;;; installed at ~/.local/bin/tcl-lsp-server by the release installer).
;;;
;;; The editor language id picks the dialect: `tcl-expect` for `.exp`/`.expect`
;;; and Expect shebangs, `tk` for `.tk` and `#!/usr/bin/wish` scripts.
;;; Everything else is plain `tcl`, where the server detects the dialect from
;;; a `# tcl-dialect:` directive, the shebang, or the extension.

(local EXTENSION_LANGUAGE_IDS {:exp "tcl-expect" :expect "tcl-expect" :tk "tk"})
(local SHEBANG_LANGUAGE_IDS [["expect" "tcl-expect"] ["wish" "tk"] ["jimsh" "tcl-jim"]])

; A `# tcl-dialect:` directive outranks the extension and the shebang on the
; server side, so when one is present let the server read it: sending a
; language id would pin the dialect above it.
(λ has_dialect_directive [?bufnr]
  (each [_ line (ipairs (vim.api.nvim_buf_get_lines ?bufnr 0 5 false))]
    (when (line:match "^%s*#%s*tcl%-dialect:")
      (lua "return true")))
  false)

;;;@param bufnr integer
;;;@param filetype string
;;;@return string
(λ language_id [?bufnr ?filetype]
  (if (has_dialect_directive ?bufnr)
    ?filetype
    (let [name (vim.api.nvim_buf_get_name ?bufnr)
        extension (name:match "%.([%w_]+)$")]
      (if (and extension (. EXTENSION_LANGUAGE_IDS extension))
        (. EXTENSION_LANGUAGE_IDS extension)
        (let [shebang (or (. (vim.api.nvim_buf_get_lines ?bufnr 0 1 false) 1) "")]
          (when (= (shebang:sub 1 2) "#!")
            (each [_ entry (ipairs SHEBANG_LANGUAGE_IDS)]
              (when (shebang:find (. entry 1) 1 true)
                (lua "return entry[2]"))))
          ?filetype)))))

;;;@type vim.lsp.Config
{:cmd [(vim.fn.expand "~/.local/bin/tcl-lsp-server")]
  :filetypes ["tcl"]
  :root_markers ["tclpkg.tcl" ".git"]
  :get_language_id language_id
  :settings {:tclLsp {:dialect "tcl8.6"}}}
