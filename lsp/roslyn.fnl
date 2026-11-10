;;;@brief
;;;
;;; https://github.com/dotnet/roslyn
;;
; To install the server, compile from source or download as nuget package.
; Go to `https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl/NuGet/Microsoft.CodeAnalysis.LanguageServer.<platform>/overview`
; replace `<platform>` with one of the following `linux-x64`, `osx-x64`, `win-x64`, `neutral` (for more info on the download location see https://github.com/dotnet/roslyn/issues/71474#issuecomment-2177303207).
; Download and extract it (nuget's are zip files).
; - if you chose `neutral` nuget version, then you have to change the `cmd` like so:
;   cmd = {
;     'dotnet',
;     '<my_folder>/Microsoft.CodeAnalysis.LanguageServer.dll',
;     '--logLevel', -- this property is required by the server
;     'Information',
;     '--extensionLogDirectory', -- this property is required by the server
;     fs.joinpath(uv.os_tmpdir(), 'roslyn_ls/logs'),
;     '--stdio',
;   },
;   where `<my_folder>` has to be the folder you extracted the nuget package to.
; - for all other platforms put the extracted folder to neovim's PATH (`vim.env.PATH`)

(local uv vim.uv)
(local fs vim.fs)

;;;@param client vim.lsp.Client
;;;@param target string
(λ on_init_sln [?client ?target]
  (vim.notify (.. "Initializing: " ?target) vim.log.levels.TRACE {:title "roslyn_ls"})
  ;;;@diagnostic disable-next-line: param-type-mismatch
  (?client:notify "solution/open" {:solution (vim.uri_from_fname ?target)}))

;;;@param client vim.lsp.Client
;;;@param project_files string[]
(λ on_init_project [?client ?project_files]
  (vim.notify "Initializing: projects" vim.log.levels.TRACE {:title "roslyn_ls"})
  ;;;@diagnostic disable-next-line: param-type-mismatch
  (?client:notify "project/open"
    {:projects (vim.tbl_map (λ [?file] (vim.uri_from_fname ?file)) ?project_files)}))

;;;@param client vim.lsp.Client
(λ refresh_diagnostics [?client]
  (each [buf _ (pairs ?client.attached_buffers)]
    (when (vim.api.nvim_buf_is_loaded buf)
      (?client:request vim.lsp.protocol.Methods.textDocument_diagnostic
        {:textDocument (vim.lsp.util.make_text_document_params buf)} nil buf))))

(λ roslyn_handlers []
  {:workspace/projectInitializationComplete
    (λ [?_1 ?_2 ?ctx]
      (vim.notify "Roslyn project initialization complete" vim.log.levels.INFO {:title "roslyn_ls"})
      (let [client (assert (vim.lsp.get_client_by_id ?ctx.client_id))]
        (refresh_diagnostics client))
      vim.NIL)
    :workspace/_roslyn_projectNeedsRestore
    (λ [?_ ?result ?ctx]
      (let [client (assert (vim.lsp.get_client_by_id ?ctx.client_id))]
        ;;;@diagnostic disable-next-line: param-type-mismatch
        (client:request "workspace/_roslyn_restore" ?result
          (λ [?err ?response]
            (when ?err
              (vim.notify ?err.message vim.log.levels.ERROR {:title "roslyn_ls"}))
            (when ?response
              (each [_ v (ipairs ?response)]
                (vim.notify v.message vim.log.levels.INFO {:title "roslyn_ls"}))))))
      vim.NIL)
    :razor/provideDynamicFileInfo
    (λ [?_1 ?_2 ?_3]
      (vim.notify "Razor is not supported.\nPlease use https://github.com/tris203/rzls.nvim"
        vim.log.levels.WARN {:title "roslyn_ls"})
      vim.NIL)})

;;;@type vim.lsp.Config
{:name "roslyn_ls"
  :offset_encoding "utf-8"
  :cmd ["roslyn" "--logLevel" "Information" "--extensionLogDirectory"
    (fs.joinpath (uv.os_tmpdir) "roslyn_ls/logs") "--stdio"]
  :filetypes ["cs"]
  ; Avoid thread-pool/GC oversubscription while full-solution analysis is active.
  :cmd_env {:DOTNET_PROCESSOR_COUNT "4"}
  :handlers (roslyn_handlers)

  :commands {:roslyn.client.completionComplexEdit
    (λ [?command ?ctx]
      (let [client (assert (vim.lsp.get_client_by_id ?ctx.client_id))
          args (or ?command.arguments {})
          uri (. args 1)
          edit (. args 2)]
        ;;;@diagnostic disable: undefined-field
        (if (and uri edit edit.newText edit.range)
          (let [workspace_edit {:changes {uri.uri [{:range edit.range :newText edit.newText}]}}]
            (vim.lsp.util.apply_workspace_edit workspace_edit client.offset_encoding)
            ;;;@diagnostic enable: undefined-field
            (values))
          (do
            (vim.notify (.. "roslyn_ls: completionComplexEdit args not understood: " (vim.inspect args)) vim.log.levels.WARN)
            (values)))))}

  :root_dir (λ [?bufnr ?cb]
    (let [bufname (vim.api.nvim_buf_get_name ?bufnr)]
      ; don't try to find sln or csproj for files from libraries
      ; outside of the project
      (when (not (: bufname :match (.. "^" (fs.joinpath "/tmp/MetadataAsSource/"))))
        ; try find solutions root first
        (var root_dir (fs.root ?bufnr (λ [?fname ?_]
              (not= (: ?fname :match "%.sln[x]?$") nil))))
        (when (not root_dir)
          ; try find projects root
          (set root_dir (fs.root ?bufnr (λ [?fname ?_]
                (not= (: ?fname :match "%.csproj$") nil)))))
        (when root_dir
          (?cb root_dir))))
    (values))
  :on_init [(λ [?client]
      (let [root_dir ?client.config.root_dir]
        ; try load first solution we find
        (each [entry type (fs.dir root_dir)]
          (when (and (= type "file") (or (vim.endswith entry ".sln") (vim.endswith entry ".slnx")))
            (on_init_sln ?client (fs.joinpath root_dir entry))
            (lua "return")))

        ; if no solution is found load project
        (each [entry type (fs.dir root_dir)]
          (when (and (= type "file") (vim.endswith entry ".csproj"))
            (on_init_project ?client [(fs.joinpath root_dir entry)]))))
      (values))]

  ; Native didOpen/didChange pulling handles edits without an all-buffer InsertLeave refresh.
  :capabilities ((require "global.language.capabilities")
    {; HACK: Doesn't show any diagnostics if we do not set this to true
      :textDocument {:diagnostic {:dynamicRegistration true}}})
  :settings {:csharp|background_analysis {:dotnet_analyzer_diagnostics_scope "openFiles"
      :dotnet_compiler_diagnostics_scope "fullSolution"}
    :csharp|inlay_hints {:csharp_enable_inlay_hints_for_implicit_object_creation true
      :csharp_enable_inlay_hints_for_implicit_variable_types true
      :csharp_enable_inlay_hints_for_lambda_parameter_types true
      :csharp_enable_inlay_hints_for_types true
      :dotnet_enable_inlay_hints_for_indexer_parameters true
      :dotnet_enable_inlay_hints_for_literal_parameters true
      :dotnet_enable_inlay_hints_for_object_creation_parameters true
      :dotnet_enable_inlay_hints_for_other_parameters true
      :dotnet_enable_inlay_hints_for_parameters true
      :dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix true
      :dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name true
      :dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent true}
    :csharp|symbol_search {:dotnet_search_reference_assemblies true}
    :csharp|completion {:dotnet_show_name_completion_suggestions true
      :dotnet_show_completion_items_from_unimported_namespaces true
      :dotnet_provide_regex_completions true}
    :csharp|code_lens {:dotnet_enable_references_code_lens true}}}
