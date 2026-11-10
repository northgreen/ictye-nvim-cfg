;;;@brief
;;;
;;; https://ast-grep.github.io/
;;;
;;; ast-grep(sg) is a fast and polyglot tool for code structural search, lint, rewriting at large scale.
;;; ast-grep LSP only works in projects that have `sgconfig.y[a]ml` in their root directories.
;;; ```sh
;;; npm install [-g] @ast-grep/cli
;;; ```

;;;@type vim.lsp.Config
{:cmd ["ast-grep" "lsp"]
  :workspace_required true
  :reuse_client (λ [?client ?config]
    (set ?config.cmd_cwd ?config.root_dir)
    (and (= ?client.name ?config.name)
      (= ?client.config.cmd_cwd ?config.cmd_cwd)))
  :filetypes [; https://ast-grep.github.io/reference/languages.html
    "bash" "c" "cpp" "cs" "css" "elixir" "go" "haskell" "html" "java"
    "javascript" "javascriptreact" "json" "kotlin" "lua" "nix" "php"
    "python" "ruby" "rust" "scala" "solidity" "swift" "typescript"
    "typescriptreact" "yaml"]
  :root_markers ["sgconfig.yaml" "sgconfig.yml"]}
