;;;@brief
;;;
;;; https://github.com/vuejs/language-tools/tree/master/packages/language-server
;;;
;;; The official language server for Vue
;;;
;;; It can be installed via npm:
;;; ```sh
;;; npm install -g @vue/language-server
;;; ```
;;;
;;; The language server only supports Vue 3 projects by default.
;;; For Vue 2 projects, [additional configuration](https://github.com/vuejs/language-tools/blob/master/extensions/vscode/README.md?plain=1#L19) are required.
;;;
;;; The Vue language server works in "hybrid mode" that exclusively manages the CSS/HTML sections.
;;; You need the `vtsls` server with the `@vue/typescript-plugin` plugin to support TypeScript in `.vue` files.
;;; See `vtsls` section and https://github.com/vuejs/language-tools/wiki/Neovim for more information.
;;;
;;; NOTE: Since v3.0.0, the Vue Language Server [no longer supports takeover mode](https://github.com/vuejs/language-tools/pull/5248).

;;;@type vim.lsp.Config
{:cmd ["vue-language-server" "--stdio"]
  :filetypes ["vue"]
  :root_markers ["package.json"]
  :on_init (λ [?client]
    (var retries 0)

    ;;;@param _ lsp.ResponseError
    ;;;@param result any
    ;;;@param context lsp.HandlerContext
    (λ typescriptHandler [?_ ?result ?context]
      (let [ts_client (or (. (vim.lsp.get_clients {:bufnr ?context.bufnr :name "ts_ls"}) 1)
            (. (vim.lsp.get_clients {:bufnr ?context.bufnr :name "vtsls"}) 1)
            (. (vim.lsp.get_clients {:bufnr ?context.bufnr :name "typescript-tools"}) 1))]
        (if (not ts_client)
          ; there can sometimes be a short delay until `ts_ls`/`vtsls` are attached so we retry for a few times until it is ready
          (if (<= retries 10000)
            (do
              (set retries (+ retries 1))
              (vim.defer_fn (λ []
                  (typescriptHandler ?_ ?result ?context))
                1000))
            (vim.notify "Could not find `ts_ls`, `vtsls`, or `typescript-tools` lsp client required by `vue_ls`."
              vim.log.levels.ERROR))
          (let [param (unpack ?result)
              (id command payload) (unpack param)]
            (ts_client:exec_cmd
              {:title "vue_request_forward" ; You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
                :command "typescript.tsserverRequest"
                :arguments [command payload]}
              {:bufnr ?context.bufnr}
              (λ [?_ ?r]
                (let [response_data [[id (and ?r ?r.body)]]]
                  ;;;@diagnostic disable-next-line: param-type-mismatch
                  (?client:notify "tsserver/response" response_data))))))))

    (set (. ?client.handlers "tsserver/request")
      (λ [?_ ?result ?context]
        (typescriptHandler ?_ ?result ?context))))
  :capabilities ((require "global.language.capabilities"))}
