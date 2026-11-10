;;;@brief
;;;
;;; https://clangd.llvm.org/installation.html
;;;
;;; - **NOTE:** Clang >= 11 is recommended! See [#23](https://github.com/neovim/nvim-lspconfig/issues/23).
;;; - If `compile_commands.json` lives in a build directory, you should
;;;   symlink it to the root of your source tree.
;;;   ```
;;;   ln -s /path/to/myproject/build/compile_commands.json /path/to/myproject/
;;;   ```
;;; - clangd relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
;;;   specified as compile_commands.json, see https://clangd.llvm.org/installation#compile_commandsjson

; https://clangd.llvm.org/extensions.html#switch-between-sourceheader
(λ switch_source_header [?bufnr ?client]
  (let [method_name "textDocument/switchSourceHeader"]
    ;;;@diagnostic disable-next-line:param-type-mismatch
    (if (or (not ?client) (not (?client:supports_method method_name)))
      (vim.notify (: "method %s is not supported by any servers active on the current buffer" :format method_name))
      (let [params (vim.lsp.util.make_text_document_params ?bufnr)]
        ;;;@diagnostic disable-next-line:param-type-mismatch
        (?client:request method_name params
          (λ [?err ?result]
            (when ?err
              (error (tostring ?err)))
            (if (not ?result)
              (vim.notify "corresponding file cannot be determined")
              (vim.cmd.edit (vim.uri_to_fname ?result))))
          ?bufnr)))))

(λ symbol_info [?bufnr ?client]
  (let [method_name "textDocument/symbolInfo"]
    ;;;@diagnostic disable-next-line:param-type-mismatch
    (if (or (not ?client) (not (?client:supports_method method_name)))
      (vim.notify "Clangd client not found" vim.log.levels.ERROR)
      (let [win (vim.api.nvim_get_current_win)
          params (vim.lsp.util.make_position_params win ?client.offset_encoding)]
        ;;;@diagnostic disable-next-line:param-type-mismatch
        (?client:request method_name params
          (λ [?err ?res]
            (when (and (not ?err) ?res (> (length ?res) 0))
              ; Errors and empty responses have no symbol data to display.
              (let [container (string.format "container: %s" (. ?res 1 :containerName)) ;;;@type string
                  name (string.format "name: %s" (. ?res 1 :name))] ;;;@type string
                (vim.lsp.util.open_floating_preview [name container] ""
                  {:height 2
                    :width (math.max (string.len name) (string.len container))
                    :focusable false
                    :focus false
                    :title "Symbol Info"}))))
          ?bufnr)))))

;;;@class ClangdInitializeResult: lsp.InitializeResult
;;;@field offsetEncoding? string

;;;@type vim.lsp.Config
{:cmd ["clangd"]
  :filetypes ["c" "cpp" "objc" "objcpp" "cuda"]
  :root_markers [".clangd" ".clang-tidy" ".clang-format" "compile_commands.json"
    "compile_flags.txt" "configure.ac" ; AutoTools
    ".git"]
  :capabilities {:textDocument {:completion {:editsNearCursor true}}
    :offsetEncoding ["utf-8" "utf-16"]}
  ;;;@param init_result ClangdInitializeResult
  :on_init (λ [?client ?init_result]
    (when ?init_result.offsetEncoding
      (set ?client.offset_encoding ?init_result.offsetEncoding)))
  :on_attach (λ [?client ?bufnr]
    (vim.api.nvim_buf_create_user_command ?bufnr "LspClangdSwitchSourceHeader"
      (λ []
        (switch_source_header ?bufnr ?client))
      {:desc "Switch between source/header"})
    (vim.api.nvim_buf_create_user_command ?bufnr "LspClangdShowSymbolInfo"
      (λ []
        (symbol_info ?bufnr ?client))
      {:desc "Show symbol info"}))}
