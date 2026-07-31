[
  ;- dependencies of configs

  (require :plugin.require.ui.colortheme.catppuccin)                       ; Catppuccin主题: 柔和 pastel 配色的 Neovim 主题
  (require :plugin.require.ui.indent_blankline)                            ; 缩进线: 显示代码缩进对齐线
  (require :plugin.require.tool.vcs.git.gitsigns)                          ; Git状态: 行内Git提示和操作
  (require :plugin.require.language.language_tool.nvim_dap)                ; DAP调试: Neovim内置调试协议支持
  (require :plugin.require.tool.neo_format)                                ; 代码格式化: 自动格式化代码
  (require :plugin.require.editor.nvim_surround)                           ; 环绕编辑: 快速添加/修改/删除包围符号
  (require :plugin.require.ui.nvim_dap_virtual_text)                       ; 调试信息: DAP变量虚拟文本显示
  (require :plugin.require.language.language_require.rust.rustaceanvim)    ; Rust支持: Rust语言服务器和工具链
  (require :plugin.require.editor.which_key)                               ; 快捷键提示: 菜单式快捷键提示
  (require :plugin.require.tool.vcs.git.lazygit)                           ; LazyGit: TUI Git客户端
  (require :plugin.require.tool.luapad)                                    ; Lua沙盒: 实时Lua代码执行
  (require :plugin.require.tool.markdown_preview)                          ; Markdown预览: 实时预览Markdown
  (require :plugin.require.ui.dashboard)                                   ; 启动画面: Neovim启动页
  (require :plugin.require.tool.visual_multi)                              ; 多光标: 批量编辑相同内容
  (require :plugin.require.language.language_tool.lsp_cfg)                 ; LSP配置: 语言服务器配置
  (require :plugin.require.language.language_tool.nvim_dap_ui)             ; DAP UI: 调试UI界面
  (require :plugin.require.language.language_tool.mason)                   ; LSP安装: 安装管理LSP服务器
  (require :plugin.require.language.language_tool.mason_lspconfig)         ; LSP配置: Mason的LSP配置
  (require :plugin.require.language.language_tool.mason_nvim_dap)          ; DAP安装: Mason的调试适配器安装
  (require :plugin.require.ui.lualine)                                     ; 状态栏: 底部状态栏
  (require :plugin.require.ui.bufferline)                                  ; 标签页: 缓冲区标签页
  (require :plugin.require.editor.rainbow_delimiters)                      ; 彩虹括号: 不同层级括号不同颜色
  (require :plugin.require.language.language_tool.refactoring)             ; 重构: 代码重构工具
  (require :plugin.require.tool.telescope)                                 ; 模糊搜索: 强大的模糊查找
  (require :plugin.require.tool.grugfar)                                   ; GrugFar: 正则替换TUI
  (require :plugin.require.tool.outline)                                   ; 大纲: 代码结构侧边栏
  (require :plugin.require.editor.nvim_ufo)                                ; 折叠: 现代代码折叠
  (require :plugin.require.ui.nvim_navic)                                  ; 导航: 位置导航(函数/类)
  (require :plugin.require.ui.nvim_treesitter_contest)                     ; Treesitter竞赛: Treesitter高亮竞赛
  (require :plugin.require.ui.noise_nvim)                                  ; 噪声背景: 噪点背景效果
  (require :plugin.require.editor.trouble)                                 ; 问题列表: 诊断错误警告列表
  (require :plugin.require.tool.hydra)                                     ; Hydra: 多头映射
  (require :plugin.require.tool.im-select)                                 ; 输入法: 自动切换输入法
  (require :plugin.require.editor.project_toolchain)                       ; 项目工具链: 项目级工具配置
  (require :plugin.require.language.language_tool.ostf_vimkind)            ; VimKind: Neovim开发辅助
  (require :plugin.require.editor.render_markdown)                         ; Markdown渲染: Markdown实时渲染
  (require :plugin.require.ui.nvim_highight_colors)                        ; 高亮颜色: 显示颜色代码实际颜色
  (require :plugin.require.ui.vim_illuminate)                              ; 高亮词: 相同词高亮
  (require :plugin.require.editor.todo_comments)                           ; TODO注释: TODO/FIXME等注释管理
  (require :plugin.require.editor.rime_nvim)                               ; Rime输入法: 中州韵输入法集成
  (require :plugin.require.language.language_tool.lsp-signature)           ; 函数签名: LSP函数签名提示
  (require :plugin.require.tool.telescope_fzf)                             ; Telescope FZF: FZF模糊匹配
  (require :plugin.require.language.language_require.haskell.haskell_tool) ; Haskell支持
  (require :plugin.require.language.language_tool.nvim_test)               ; 测试运行: Neovim测试运行器
  (require :plugin.require.tool.undotree)                                  ; 撤销树: 可视化撤销历史
  (require :plugin.require.editor.mininvim)                                ; Minivim: Neovim配置
  (require :plugin.require.ui.flash)                                       ; Flash: 快速跳转搜索
  (require :plugin.require.ui.smear-cursor)                                ; 鼠标光标: 跟随鼠标位置
  (require :plugin.require.ui.vim-smoothie)                                ; 平滑滚动: Vim滚动增强
  (require :plugin.require.language.language_require.sonicpi)              ; Sonic Pi: Sonic Pi语言支持
  (require :plugin.require.tool.snacks)                                    ; Snacks: Neovim小工具集合
  (require :plugin.require.ui.neotree)                                     ; Neo-tree: 文件浏览器(新版)
  (require :plugin.require.ui.edgy)                                        ; Edgy: 侧边栏布局
  (require :plugin.require.tool.mcp)                                       ; MCP: 模型上下文协议
  (require :plugin.require.tool.eazy-dotnet)                               ; Easy .NET: .NET开发工具
  (require :plugin.require.ui.play-one)                                    ; PlayOne: 播放动画
  (require :plugin.require.tool.oil)                                       ; Oil: 文件浏览器(纯文本)
  (require :plugin.require.language.language_tool.bink-cmp)                ; Blink.cmp: 现代代码补全
  (require :plugin.require.tool.vcs.jj)                                    ; Jujutsu: VCS版本控制
  (require :plugin.require.tool.obsidian)                                  ; Obsidian: Obsidian笔记集成
  (require :plugin.require.editor.fcitx5)                                  ; Fcitx5: 输入法控制
  (require :plugin.require.tool.overseer)                                  ; Overseer: 任务运行器
  (require :plugin.require.tool.ai.opencode)                               ; OpenCode: OpenCode AI集成
  (require :plugin.require.language.language_require.fsharp)               ; F#支持
  (require :plugin.require.tool.multicursor)                               ; 多光标: 多光标编辑
  (require :plugin.require.ui.lensline)                                    ; 透镜行: 虚拟行号
  (require :plugin.require.tool.ression)                                   ; Resession: 会话管理
  (require :plugin.require.language.language_require.typescript.ts_tool)   ; TypeScript工具
  (require :plugin.require.tool.mark)                                      ; Mark: 书签标记
  (require :plugin.require.editor.vim-tmux-navigator)
  (require :plugin.require.editor.kitty-navigator)
  (require :plugin.require.tool.wakatime)
  (require :plugin.require.tool.neogen)
  (require :plugin.require.tool.ai.minuet-ai)
  (require :plugin.require.tool.screenkey)
  (require :plugin.require.tool.none-ls)
  (require :plugin.require.language.language_require.common-lisp)
  (require :plugin.require.tool.hotpot)
  (require :plugin.require.tool.conjure)
  (require :plugin.require.tool.nfnl)
  (require :plugin.require.tool.rest)
  (require :plugin.require.tool.remote.remote)
  (require :plugin.require.tool.remote.distant)
  (require :plugin.require.tool.cppassist)
  (require :plugin.require.ui.wombient)
  (require :plugin.require.ui.drop-bar)
  (require :plugin.require.tool.meow-yarn)


  (require :plugins.require.quickbuf)
  (require :plugins.require.vcs.diffview)
  (require :plugins.require.vcs.codediff)
  (require :plugins.require.ssr)
  (require :plugins.require.tool.treesj)
  (require :plugins.require.tool.translate)
  (require :plugins.require.tool.tunnelvision)
  (require :plugins.require.tool.fluoride)
  (require :plugins.require.language.tree-sitter-manager)
  (require :plugins.require.treewalker)
  (require :plugins.require.nvim-treesitter-textobjects)
  (require :plugins.require.neoghidra)

  ;;;;others
  (require :plugin.require.tool.firenvim) ; Firenvim: 在浏览器中编辑


  ; require 'plugin.require.tool.ai.claude',

  ;;;;disabled
  ; (require :plugin.require.language.language_tool.playground) ; Treesitter playground: 已废弃
  ; (require :plugin.require.editor.fcitx5ui)                                ; Fcitx5 UI: 输入法状态显示
  ; require :plugin.require.editor.unity()
  ; (require :plugin.require.tool.ai.bink-mcp-avante) ; Avante MCP: 已禁用
  ; (require :plugin.require.tool.hardtime)                                  ; Hardtime: 强制使用正确快捷键
  ; (require :plugin.require.language.language_require.csharp) ; C#支持: 已禁用
  ; (require :plugin.require.tool.carbon-now)                                ; Carbon: 代码截图
  ; (require :plugin.require.editor.orgmode) ; Org模式: 已禁用
  ; (require :plugin.require.editor.neorg)                                   ; Neorg: Neovim组织工具
  ; (require :plugin.require.tool.yazi)                                      ; Yazi: 终端文件管理器
  ; (require :plugin.require.language.language_tool.cmp_rime) ; Rime补全: 已废弃
  ; (require :plugin.require.tool.ai.avante)                                 ; Avante: AI编程助手
  ; (require :plugin.require.language.language_tool.cmp_cmdline) ; 命令行补全: 已废弃
  ; (require :plugin.require.language.language_tool.nvim_cmp) ; 代码补全: 已废弃,使用blink.cmp
  ; (require :plugin.require.tool.floaterm)                              ; 浮动终端: 悬浮终端窗口
  ; (require :plugin.require.ui.nvim_tree)                                   ; 文件浏览器: 左侧文件树导航
  ; (require :plugin.require.ui.codewindow)                                  ; Codewindow: 代码小地图
  ; (require :plugin.require.tool.nvim_rip_substitute)                       ; 批量替换: Ripgrep批量替换
  ; (require :plugin.require.language.language_tool.nvim_treesitter)         ; Treesitter: 代码语法高亮和解析
  ; (require :plugin.require.editor.auto_pairs)                              ; 自动配对: 自动闭合括号引号
]
