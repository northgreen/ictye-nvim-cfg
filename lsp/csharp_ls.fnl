;;;@brief
;;;
;;; https://github.com/razzmatazz/csharp-language-server
;;;
;;; Language Server for C#.
;;;
;;; csharp-ls requires the [dotnet-sdk](https://dotnet.microsoft.com/download) to be installed.
;;;
;;; The preferred way to install csharp-ls is with `dotnet tool install --global csharp-ls`.

(local util (require "util.lsp"))

;;;@type vim.lsp.Config
{:cmd ["csharp-ls"]
  :root_dir (λ [?bufnr ?on_dir]
    (let [fname (vim.api.nvim_buf_get_name ?bufnr)]
      (?on_dir (or ((util.root_pattern "*.sln") fname)
          ((util.root_pattern "*.slnx") fname)
          ((util.root_pattern "*.csproj") fname)))))
  :capabilities ((. (require "blink.cmp") :get_lsp_capabilities))
  :filetypes ["cs"]
  :init_options {:AutomaticWorkspaceInit true}}
