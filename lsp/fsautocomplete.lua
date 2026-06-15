--- fsautocomplete 配置 - 针对 Godot + F# 项目优化
--- 解决 typechecking 卡死问题

---@type vim.lsp.Config
return {
  -- 使用标准模式而非 adaptive 模式
  cmd = { 'fsautocomplete' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root_markers = { '*.fsproj', '*.sln', '.git' }
    local root = vim.fs.dirname(
      vim.fs.find(root_markers, { path = fname, upward = true })[1] or '')
    on_dir(root ~= '' and root or nil)
  end,
  filetypes = { 'fsharp' },
  init_options = {
    AutomaticWorkspaceInit = true, -- 启用自动工作区初始化
  },
  log_level = "WARN",

  -- 覆盖 LSP 服务器的能力，防止 blink.cmp 错误
  capabilities = vim.tbl_extend('force', require('blink-cmp').get_lsp_capabilities(), {
    textDocument = {
      semanticTokens = nil, -- 完全禁用语义令牌
    },
  }),

  -- 关键配置：在 on_attach 中只禁用语义令牌，保留其他功能
  on_attach = function(client, bufnr)
    -- 完全禁用语义令牌 - 这是导致卡死的主要原因
    client.server_capabilities.semanticTokensProvider = nil

    -- 保留所有其他功能（补全、跳转、悬停等）
    -- 不要修改 server_capabilities 中的其他项，让 LSP 服务器自己决定
  end,

  settings = {
    FSharp = {
      -- 核心功能
      keywordsAutocomplete = true,
      ExternalAutocomplete = false,

      -- 禁用所有分析器
      Linter = false,
      UnusedOpensAnalyzer = false,
      UnusedDeclarationsAnalyzer = false,
      SimplifyNameAnalyzer = false,
      ResolveNamespaces = false,

      -- 禁用代码生成
      UnionCaseStubGeneration = false,
      RecordStubGeneration = false,
      InterfaceStubGeneration = false,

      -- 禁用代码镜头和提示
      EnableReferenceCodeLens = false,
      BackgroundAnalysisEnabled = false,
      InlayHintsEnabled = false,
      SemanticHighlighting = false,

      -- 禁用日志
      trace = { server = "off" },

      -- 格式化设置
      keywordsFormat = {
        SpaceAfterKeyword = true,
        SpaceAfterLambdaArrow = true,
        SpaceAfterMatchReturn = true,
      },
      Indentation = {
        IndentSize = 4,
        TabSize = 4,
        UseTabs = false,
      },
      FormatOnKeyTyped = true,
    },
  },
}
