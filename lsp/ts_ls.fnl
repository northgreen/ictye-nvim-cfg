;;;@brief
;;;
;;; https://github.com/typescript-language-server/typescript-language-server
;;;
;;; `ts_ls`, aka `typescript-language-server`, is a Language Server Protocol implementation for TypeScript wrapping `tsserver`. Note that `ts_ls` is not `tsserver`.
;;;
;;; `typescript-language-server` depends on `typescript`. Both packages can be installed via `npm`:
;;; ```sh
;;; npm install -g typescript typescript-language-server
;;; ```
;;;
;;; To configure typescript language server, add a
;;; [`tsconfig.json`](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html) or
;;; [`jsconfig.json`](https://code.visualstudio.com/docs/languages/jsconfig) to the root of your
;;; project.
;;;
;;; Here's an example that disables type checking in JavaScript files.
;;;
;;; ```json
;;; {
;;;   "compilerOptions": {
;;;     "module": "commonjs",
;;;     "target": "es6",
;;;     "checkJs": false
;;;   },
;;;   "exclude": [
;;;     "node_modules"
;;;   ]
;;; }
;;; ```
;;;
;;; Use the `:LspTypescriptSourceAction` command to see "whole file" ("source") code-actions such as:
;;; - organize imports
;;; - remove unused code
;;;
;;; Use the `:LspTypescriptGoToSourceDefinition` command to navigate to the source definition of a symbol (e.g., jump to the original implementation instead of type definitions).
;;;
;;; ### Monorepo support
;;;
;;; `ts_ls` supports monorepos by default. It will automatically find the `tsconfig.json` or `jsconfig.json` corresponding to the package you are working on.
;;; This works without the need of spawning multiple instances of `ts_ls`, saving memory.
;;;
;;; It is recommended to use the same version of TypeScript in all packages, and therefore have it available in your workspace root. The location of the TypeScript binary will be determined automatically, but only once.
;;;
;;; Some care must be taken here to correctly infer whether a file is part of a Deno program, or a TS program that
;;; expects to run in Node or Web Browsers. This supports having a Deno module using the denols LSP as a part of a
;;; mostly-not-Deno monorepo. We do this by finding the nearest package manager lock file, and the nearest deno.json
;;; or deno.jsonc.
;;;
;;; Example:
;;;
;;; ```
;;; project-root
;;; +-- node_modules/...
;;; +-- package-lock.json
;;; +-- package.json
;;; +-- packages
;;;     +-- deno-module
;;;     |   +-- deno.json
;;;     |   +-- package.json <-- It's normal for Deno projects to have package.json files!
;;;     |   +-- src
;;;     |       +-- index.ts <-- this is a Deno file
;;;     +-- node-module
;;;         +-- package.json
;;;         +-- src
;;;             +-- index.ts <-- a non-Deno file (ie, should use ts_ls or tsgols)
;;; ```
;;;
;;; From the file being edited, we walk up to find the nearest package manager lockfile. This is PROJECT ROOT.
;;; From the file being edited, find the nearest deno.json or deno.jsonc. This is DENO ROOT.
;;; From the file being edited, find the nearest deno.lock. This is DENO LOCK ROOT
;;; If DENO LOCK ROOT is found, and PROJECT ROOT is missing or shorter, then this is a deno file, and we abort.
;;; If DENO ROOT is found, and it's longer than or equal to PROJECT ROOT, then this is a Deno file, and we abort.
;;; Otherwise, attach at PROJECT ROOT, or the cwd if not found.

;;;@type vim.lsp.Config
{:init_options {:hostInfo "neovim"}
  :cmd ["typescript-language-server" "--stdio"]
  :filetypes ["javascript" "javascriptreact" "typescript" "typescriptreact" "vue"]
  :root_dir (λ [?bufnr ?on_dir]
    ; The project root is where the LSP can be started from
    ; As stated in the documentation above, this LSP supports monorepos and simple projects.
    ; We select then from the project root, which is identified by the presence of a package
    ; manager lock file.
    (var root_markers ["package-lock.json" "yarn.lock" "pnpm-lock.yaml" "bun.lockb" "bun.lock"])
    ; Give the root markers equal priority by wrapping them in a table
    (set root_markers (or (and (= (vim.fn.has "nvim-0.11.3") 1) [root_markers [".git"]])
        (vim.list_extend root_markers [".git"])))
    ; exclude deno
    (let [deno_root (vim.fs.root ?bufnr ["deno.json" "deno.jsonc"])
        deno_lock_root (vim.fs.root ?bufnr ["deno.lock"])
        project_root (vim.fs.root ?bufnr root_markers)]
      ; Skip Deno files; each exclusion is a condition, not an empty if branch.
      (when (not (or
            (and deno_lock_root (or (not project_root) (> (length deno_lock_root) (length project_root))))
            (and deno_root (or (not project_root) (>= (length deno_root) (length project_root))))))
        ; project is standard TS, not deno
        ; We fallback to the current working directory if no project root is found
        (?on_dir (or project_root (vim.fn.getcwd))))))
  :handlers {; handle rename request for certain code actions like extracting functions / types
    :_typescript.rename
    (λ [?_ ?result ?ctx]
      (let [client (assert (vim.lsp.get_client_by_id ?ctx.client_id))]
        (vim.lsp.util.show_document {:uri ?result.textDocument.uri
            :range {:start ?result.position :end ?result.position}}
          client.offset_encoding)
        (vim.lsp.buf.rename))
      vim.NIL)}
  :commands {:editor.action.showReferences
    (λ [?command ?ctx]
      (let [client (assert (vim.lsp.get_client_by_id ?ctx.client_id))
          (file_uri position references) (unpack ?command.arguments)
          quickfix_items (vim.lsp.util.locations_to_items references ;;;@as any
            client.offset_encoding)]
        (vim.fn.setqflist {} " "
          {:title ?command.title
            :items quickfix_items
            :context {:command ?command :bufnr ?ctx.bufnr}})
        (vim.lsp.util.show_document {:uri file_uri ;;;@as string
            :range {:start position ;;;@as lsp.Position
              :end position}} ;;;@as lsp.Position
          client.offset_encoding)
        ;;;@diagnostic enable: assign-type-mismatch
        (vim.cmd "botright copen")))}
  :on_attach (λ [?client ?bufnr]
    ; ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
    ; `vim.lsp.buf.code_action()` if specified in `context.only`.
    (vim.api.nvim_buf_create_user_command ?bufnr "LspTypescriptSourceAction"
      (λ []
        (let [source_actions (vim.tbl_filter (λ [?action] (vim.startswith ?action "source."))
              ?client.server_capabilities.codeActionProvider.codeActionKinds)]
          (vim.lsp.buf.code_action {:context {:only source_actions :diagnostics {}}})))
      {})

    ; Go to source definition command
    (vim.api.nvim_buf_create_user_command ?bufnr "LspTypescriptGoToSourceDefinition"
      (λ []
        (let [win (vim.api.nvim_get_current_win)
            params (vim.lsp.util.make_position_params win ?client.offset_encoding)]
          (?client:exec_cmd
            {:command "_typescript.goToSourceDefinition"
              :title "Go to source definition"
              :arguments [params.textDocument.uri params.position]}
            {:bufnr ?bufnr}
            (λ [?err ?result]
              (if ?err
                (vim.notify (.. "Go to source definition failed: " ?err.message) vim.log.levels.ERROR)
                (or (not ?result) (vim.tbl_isempty ?result))
                (vim.notify "No source definition found" vim.log.levels.INFO)
                (vim.lsp.util.show_document (. ?result 1) ?client.offset_encoding {:focus true}))))))
      {:desc "Go to source definition"}))
  :capabilities ((require "global.language.capabilities"))}
