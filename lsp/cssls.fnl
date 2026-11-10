;;;@brief
;;;
;;; https://github.com/hrsh7th/vscode-langservers-extracted
;;;
;;; `css-languageserver` can be installed via `npm`:
;;;
;;; ```sh
;;; npm i -g vscode-langservers-extracted
;;; ```
;;;
;;; Neovim does not currently include built-in snippets. `vscode-css-language-server` only provides completions when snippet support is enabled. To enable completion, install a snippet plugin and add the following override to your language client capabilities during setup.
;;;
;;; ```lua
;;; --Enable (broadcasting) snippet capability for completion
;;; local capabilities = vim.lsp.protocol.make_client_capabilities()
;;; capabilities.textDocument.completion.completionItem.snippetSupport = true
;;;
;;; vim.lsp.config('cssls', {
;;;   capabilities = capabilities,
;;; })
;;; ```

;;;@type vim.lsp.Config
{:cmd (λ [?dispatchers ?config]
    (var cmd "vscode-css-language-server")
    (when (. (or ?config {}) :root_dir)
      (let [local_cmd (vim.fs.joinpath ?config.root_dir "node_modules/.bin" cmd)]
        (when (= (vim.fn.executable local_cmd) 1)
          (set cmd local_cmd))))
    (vim.lsp.rpc.start [cmd "--stdio"] ?dispatchers))
  :filetypes ["css" "scss" "less"]
  :init_options {:provideFormatter true} ; needed to enable formatting capabilities
  :root_markers ["package.json" ".git"]
  ;;;@type lspconfig.settings.cssls
  :settings {:css {:validate true}
    :scss {:validate true}
    :less {:validate true}}}
