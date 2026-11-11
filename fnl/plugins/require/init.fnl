(print "use other way")
[
  ;- dependencies of configs
  (require :plugins.require.ui.colortheme.catppuccin) ; Catppuccin主题: 柔和 pastel 配色的 Neovim 主题
  (require :plugins.require.ui.indent_blankline) ; 缩进线: 显示代码缩进对齐线
  (require :plugins.require.tool.vcs.git.gitsigns) ; Git状态: 行内Git提示和操作
  (require :plugins.require.language.language_tool.nvim_dap) ; DAP调试: Neovim内置调试协议支持
  (require :plugins.require.tool.neo_format) ; 代码格式化: 自动格式化代码
  (require :plugins.require.editor.nvim_surround) ; 环绕编辑: 快速添加/修改/删除包围符号
  (require :plugins.require.ui.nvim_dap_virtual_text) ; 调试信息: DAP变量虚拟文本显示
  (require :plugins.require.language.language_require.rust.rustaceanvim) ; Rust支持: Rust语言服务器和工具链
  (require :plugins.require.editor.which_key) ; 快捷键提示: 菜单式快捷键提示
  (require :plugins.require.tool.vcs.git.lazygit) ; LazyGit: TUI Git客户端
  (require :plugins.require.tool.luapad) ; Lua沙盒: 实时Lua代码执行
  (require :plugins.require.tool.markdown_preview) ; Markdown预览: 实时预览Markdown
  (require :plugins.require.ui.dashboard) ; 启动画面: Neovim启动页
  (require :plugins.require.tool.visual_multi) ; 多光标: 批量编辑相同内容
  (require :plugins.require.language.language_tool.lsp_cfg) ; LSP配置: 语言服务器配置
  (require :plugins.require.language.language_tool.nvim_dap_ui) ; DAP UI: 调试UI界面
  (require :plugins.require.language.language_tool.mason) ; LSP安装: 安装管理LSP服务器
  (require :plugins.require.language.language_tool.mason_lspconfig) ; LSP配置: Mason的LSP配置
  (require :plugins.require.language.language_tool.mason_nvim_dap) ; DAP安装: Mason的调试适配器安装
  (require :plugins.require.ui.lualine) ; 状态栏: 底部状态栏
  (require :plugins.require.ui.bufferline) ; 标签页: 缓冲区标签页
  (require :plugins.require.editor.rainbow_delimiters) ; 彩虹括号: 不同层级括号不同颜色
  (require :plugins.require.language.language_tool.refactoring) ; 重构: 代码重构工具
  (require :plugins.require.tool.telescope) ; 模糊搜索: 强大的模糊查找
  (require :plugins.require.tool.grugfar) ; GrugFar: 正则替换TUI
  (require :plugins.require.tool.outline) ; 大纲: 代码结构侧边栏
  (require :plugins.require.editor.nvim_ufo) ; 折叠: 现代代码折叠
  (require :plugins.require.ui.nvim_navic) ; 导航: 位置导航(函数/类)
  (require :plugins.require.ui.nvim_treesitter_contest) ; Treesitter竞赛: Treesitter高亮竞赛
  (require :plugins.require.ui.noise_nvim) ; 噪声背景: 噪点背景效果
  (require :plugins.require.editor.trouble) ; 问题列表: 诊断错误警告列表
  (require :plugins.require.editor.tobira) ; 问题列表: 诊断错误警告列表
  (require :plugins.require.tool.hydra) ; Hydra: 多头映射
  (require :plugins.require.tool.im-select) ; 输入法: 自动切换输入法
  (require :plugins.require.editor.project_toolchain) ; 项目工具链: 项目级工具配置
  (require :plugins.require.language.language_tool.ostf_vimkind) ; VimKind: Neovim开发辅助
  (require :plugins.require.editor.render_markdown) ; Markdown渲染: Markdown实时渲染
  (require :plugins.require.ui.nvim_highight_colors) ; 高亮颜色: 显示颜色代码实际颜色
  (require :plugins.require.ui.vim_illuminate) ; 高亮词: 相同词高亮
  (require :plugins.require.editor.todo_comments) ; TODO注释: TODO/FIXME等注释管理
  (require :plugins.require.editor.rime_nvim) ; Rime输入法: 中州韵输入法集成
  (require :plugins.require.language.language_tool.lsp-signature) ; 函数签名: LSP函数签名提示
  (require :plugins.require.tool.telescope_fzf) ; Telescope FZF: FZF模糊匹配
  (require :plugins.require.language.language_require.haskell.haskell_tool) ; Haskell支持
  (require :plugins.require.language.language_tool.nvim_test) ; 测试运行: Neovim测试运行器
  (require :plugins.require.tool.undotree) ; 撤销树: 可视化撤销历史
  (require :plugins.require.editor.mininvim) ; Minivim: Neovim配置
  (require :plugins.require.ui.flash) ; Flash: 快速跳转搜索
  (require :plugins.require.ui.smear-cursor) ; 鼠标光标: 跟随鼠标位置
  (require :plugins.require.ui.vim-smoothie) ; 平滑滚动: Vim滚动增强
  (require :plugins.require.language.language_require.sonicpi) ; Sonic Pi: Sonic Pi语言支持
  (require :plugins.require.tool.snacks) ; Snacks: Neovim小工具集合
  (require :plugins.require.ui.neotree) ; Neo-tree: 文件浏览器(新版)
  (require :plugins.require.ui.edgy) ; Edgy: 侧边栏布局
  (require :plugins.require.tool.mcp) ; MCP: 模型上下文协议
  (require :plugins.require.tool.eazy-dotnet) ; Easy .NET: .NET开发工具
  (require :plugins.require.ui.play-one) ; PlayOne: 播放动画
  (require :plugins.require.tool.oil) ; Oil: 文件浏览器(纯文本)
  (require :plugins.require.language.language_tool.bink-cmp) ; Blink.cmp: 现代代码补全
  (require :plugins.require.tool.vcs.jj) ; Jujutsu: VCS版本控制
  (require :plugins.require.tool.obsidian) ; Obsidian: Obsidian笔记集成
  (require :plugins.require.editor.fcitx5) ; Fcitx5: 输入法控制
  (require :plugins.require.tool.overseer) ; Overseer: 任务运行器
  (require :plugins.require.tool.ai.opencode) ; OpenCode: OpenCode AI集成
  (require :plugins.require.language.language_require.fsharp) ; F#支持
  (require :plugins.require.tool.multicursor) ; 多光标: 多光标编辑
  (require :plugins.require.ui.lensline) ; 透镜行: 虚拟行号
  (require :plugins.require.tool.ression) ; Resession: 会话管理
  (require :plugins.require.language.language_require.typescript.ts_tool) ; TypeScript工具
  (require :plugins.require.tool.mark) ; Mark: 书签标记
  (require :plugins.require.editor.vim-tmux-navigator)
  (require :plugins.require.editor.kitty-navigator)
  (require :plugins.require.tool.wakatime)
  (require :plugins.require.tool.neogen)
  (require :plugins.require.tool.ai.minuet-ai)
  (require :plugins.require.tool.screenkey)
  (require :plugins.require.tool.none-ls)
  (require :plugins.require.language.language_require.common-lisp)
  (require :plugins.require.tool.hotpot)
  (require :plugins.require.tool.conjure)
  (require :plugins.require.tool.nfnl)
  (require :plugins.require.tool.rest)
  (require :plugins.require.tool.remote.remote)
  (require :plugins.require.tool.remote.distant)
  (require :plugins.require.tool.cppassist)
  (require :plugins.require.ui.wombient)
  (require :plugins.require.ui.drop-bar)
  (require :plugins.require.ui.hawtkeys)
  (require :plugins.require.tool.meow-yarn)

  (require :plugins.require.quickbuf)
  (require :plugins.require.vcs.diffview)
  (require :plugins.require.vcs.codediff)
  (require :plugins.require.ssr)
  (require :plugins.require.tool.fff)
  (require :plugins.require.tool.treesj)
  (require :plugins.require.tool.translate)
  (require :plugins.require.tool.tunnelvision)
  (require :plugins.require.tool.fluoride)
  (require :plugins.require.language.tree-sitter-manager)
  (require :plugins.require.treewalker)
  (require :plugins.require.nvim-treesitter-textobjects)
  (require :plugins.require.neoghidra)
  (require :plugins.require.tool.herdr)
  (require :plugins.require.tool.perfanno)
  (require :plugins.require.tool.harpoon)

  ;;;;others
  (require :plugins.require.tool.firenvim) ; Firenvim: 在浏览器中编辑

  (require :plugins.require.tool.ai.avante) ; Avante: AI编程助手
  (require :plugins.require.tool.ai.pi2)

  ; require 'plugins.require.tool.ai.claude',

  ;;;;disabled
  ; (require :plugins.require.language.language_tool.playground) ; Treesitter playground: 已废弃
  ; (require :plugins.require.editor.fcitx5ui)                                ; Fcitx5 UI: 输入法状态显示
  ; require :plugins.require.editor.unity()
  ; (require :plugins.require.tool.ai.bink-mcp-avante) ; Avante MCP: 已禁用
  ; (require :plugins.require.tool.hardtime)                                  ; Hardtime: 强制使用正确快捷键
  ; (require :plugins.require.language.language_require.csharp) ; C#支持: 已禁用
  ; (require :plugins.require.tool.carbon-now)                                ; Carbon: 代码截图
  ; (require :plugins.require.editor.orgmode) ; Org模式: 已禁用
  ; (require :plugins.require.editor.neorg)                                   ; Neorg: Neovim组织工具
  ; (require :plugins.require.tool.yazi)                                      ; Yazi: 终端文件管理器
  ; (require :plugins.require.language.language_tool.cmp_rime) ; Rime补全: 已废弃
  ; (require :plugins.require.language.language_tool.cmp_cmdline) ; 命令行补全: 已废弃
  ; (require :plugins.require.language.language_tool.nvim_cmp) ; 代码补全: 已废弃,使用blink.cmp
  ; (require :plugins.require.tool.floaterm)                                 ; 浮动终端: 悬浮终端窗口
  ; (require :plugins.require.ui.nvim_tree)                                   ; 文件浏览器: 左侧文件树导航
  ; (require :plugins.require.ui.codewindow)                                  ; Codewindow: 代码小地图
  ; (require :plugins.require.tool.nvim_rip_substitute)                       ; 批量替换: Ripgrep批量替换
  ; (require :plugins.require.language.language_tool.nvim_treesitter)         ; Treesitter: 代码语法高亮和解析
  ; (require :plugins.require.editor.auto_pairs)                              ; 自动配对: 自动闭合括号引号
]
