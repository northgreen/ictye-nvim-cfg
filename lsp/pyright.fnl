;;;@brief
;;;
;;; https://github.com/microsoft/pyright
;;;
;;; `pyright`, a static type checker and language server for python

(λ set_python_path [?command]
  (let [path ?command.args
      clients (vim.lsp.get_clients {:bufnr (vim.api.nvim_get_current_buf)
          :name "pyright"})]
    (each [_ client (ipairs clients)]
      (if client.settings
        (set client.settings.python (vim.tbl_deep_extend "force" client.settings.python {:pythonPath path}))
        (set client.config.settings (vim.tbl_deep_extend "force" client.config.settings {:python {:pythonPath path}})))
      (client:notify "workspace/didChangeConfiguration" {:settings nil}))))

;;;@type vim.lsp.Config
{:cmd ["pyright-langserver" "--stdio"]
  :filetypes ["python"]
  :root_markers ["pyproject.toml" "setup.py" "setup.cfg" "requirements.txt" "Pipfile"
    "pyrightconfig.json" ".git"]
  :settings {:python {:analysis {:autoSearchPaths true
        :useLibraryCodeForTypes true
        :diagnosticMode "openFilesOnly"}}}
  :on_attach (λ [?client ?bufnr]
    (vim.api.nvim_buf_create_user_command ?bufnr "LspPyrightOrganizeImports"
      (λ []
        (let [params {:command "pyright.organizeimports"
              :arguments [(vim.uri_from_bufnr ?bufnr)]}]
          ; Using client.request() directly because "pyright.organizeimports" is private
          ; (not advertised via capabilities), which client:exec_cmd() refuses to call.
          ; https://github.com/neovim/neovim/blob/c333d64663d3b6e0dd9aa440e433d346af4a3d81/runtime/lua/vim/lsp/client.lua#L1024-L1030
          (?client.request "workspace/executeCommand" params nil ?bufnr)))
      {:desc "Organize Imports"})
    (vim.api.nvim_buf_create_user_command ?bufnr "LspPyrightSetPythonPath" set_python_path
      {:desc "Reconfigure pyright with the provided python path"
        :nargs 1
        :complete "file"}))}
