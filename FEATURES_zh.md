# 功能特性

> 本文档全面概述了此 Neovim 配置中包含的所有功能、语言支持和特殊能力。

## 目录
- [核心功能](#核心功能)
  - [AI 增强开发](#ai-增强开发)
  - [开发工具](#开发工具)
  - [现代 UI/UX](#现代-uiux)
  - [性能与生产力](#性能与生产力)
  - [搜索与导航](#搜索与导航)
  - [任务与终端管理](#任务与终端管理)
- [语言支持](#语言支持)
  - [Rust](#rust)
  - [Python](#python)
  - [Haskell](#haskell)
  - [C/C++](#cc)
  - [C#](#c)
  - [TypeScript/JavaScript](#typescriptjavascript)
  - [Shell 与配置文件](#shell-与配置文件)
  - [系统编程](#系统编程)
  - [游戏开发](#游戏开发)
  - [函数式与其他](#函数式与其他)
  - [LSP 管理](#lsp-管理)
  - [语言专属特性](#语言专属特性)
- [特殊功能](#特殊功能)
  - [AI 集成](#ai-集成)
  - [输入法集成](#输入法集成)
  - [图像处理](#图像处理)
  - [性能监控](#性能监控)
  - [高级工具](#高级工具)

---

## 核心功能

本配置旨在提供一个完整、开箱即用的生产级开发环境。以下是实现这一目标的关键功能类别。

### AI 增强开发
- **多 AI 提供商**: Avante 支持 OpenAI、GitHub Models、SiliconFlow 以及自定义端点
- **内联 AI 聊天**: OpenCode 集成，`<C-a>` 用于提问，`<C-x>` 用于代码操作
- **AI 操作符**: `go` / `goo` 操作符可直接将代码发送给 OpenCode
- **MCP Hub**: Model Context Protocol 支持，用于文件和工具集成 (`mcphub.nvim`)
- **Fitten Code**: AI 驱动的代码补全
- **Claude Code**: 直接集成 Claude 用于高级推理
- **Minuet AI**: 额外的 AI 助手，用于快速查询

### 开发工具
- **Git 集成**: Gitsigns 用于内联差异对比，LazyGit 用于 TUI Git 客户端，支持 Jujutsu (jj) VCS
- **调试器 (DAP)**: 完整的 Debug Adapter Protocol 支持，带 UI、虚拟文本和断点
- **测试运行器**: 通过 `nvim-test` 和 `<C-x>t` 菜单集成测试执行
- **代码重构**: 自动化重构工具，用于安全的代码转换
- **格式化**: 使用 `neo_format` 自动格式化代码
- **项目工具链**: 项目级别的工具配置 (`project_toolchain`)
- **代码生成**: Neogen 用于自动生成文档字符串和注释
- **REST 客户端**: 内置 REST API 测试工具 (`rest.nvim`)
- **WakaTime**: 自动时间追踪和生产力指标统计

### 现代 UI/UX
- **状态栏**: Lualine，可自定义、信息丰富的状态栏
- **缓冲区导航栏**: Tab 风格的缓冲区导航，带指示器
- **文件浏览器**: Neo-tree、Nvim-tree、Oil.nvim 和 Yazi，满足不同文件浏览需求
- **启动面板**: 精美的启动屏幕，带会话快速入口
- **代码折叠**: UFO 折叠，支持 LSP 感知的折叠文本
- **缩进引导线**: Indent-blankline 用于可视化缩进对齐
- **彩虹括号**: 彩色括号匹配
- **Trouble**: 集中化的诊断、引用和定义面板
- **Which-Key**: 菜单驱动的按键提示
- **Flash**: 通过字符搜索实现快速光标移动
- **Smear Cursor**: 平滑光标动画，更好的视觉跟踪
- **Smooth Scrolling**: Vim-smoothie 提供流畅的滚动体验
- **Code Window**: 代码迷你图，用于快速导航
- **Edgy**: 智能侧边栏布局管理
- **Noise Background**: 微妙的噪点纹理，增加视觉深度
- **Lens Line**: 虚拟行增强
- **Vim Illuminate**: 自动高亮光标下的单词
- **Play-One**: 动画回放支持

### 性能与生产力
- **双模式系统**: Full 模式（默认）与 Lite 模式 (`g:lite_mode`)，实现更快启动
- **Tree-sitter**: 50+ 语言的高级语法高亮和代码解析
- **LSP 集成**: 20+ 语言服务器，通过 Mason 自动配置
- **会话管理**: Resession 用于保存和恢复工作会话
- **TODO 管理**: 高亮并导航 TODO、FIXME、HACK 注释
- **Hardtime**: 强制执行正确的 Vim 键映射使用，建立肌肉记忆
- **多光标**: Visual-multi 和 multicursor 用于批量编辑
- **Surround**: 快速添加/更改/删除周围配对符号和标签
- **Auto Pairs**: 自动括号和引号闭合
- **Undo Tree**: 可视化撤销历史导航

### 搜索与导航
- **Telescope**: 强大的模糊查找器，基于 FZF 后端，支持文件、缓冲区、grep 等
- **Flash**: 闪电般快速跳转到任何可见文本
- **Ripgrep Substitute**: 在项目中进行快速查找和替换
- **Grug-Far**: 基于 TUI 的正则搜索和替换
- **Outline**: 代码结构侧边栏，带符号导航
- **Navic**: 基于 LSP 的位置导航（当前函数、类等）
- **Marks**: 书签功能，在不同重要位置之间跳转
- **Screenkey**: 显示最近的按键操作，适合演示

### 任务与终端管理
- **Overseer**: 任务运行器，支持持久化任务、依赖关系和输出查看
- **Floaterm**: 浮动终端窗口，用于快速执行命令
- **LuaPad**: 实时 Lua 代码执行沙箱
- **Snacks**: Neovim 实用工具和辅助功能集合

---

## 语言支持

本配置为 20+ 编程语言提供全面支持，包含专用的 LSP 服务器、调试适配器和语言专属工具。每种语言都能享受智能代码补全、诊断和重构功能。

### Rust
- **插件**: `rustaceanvim`（替代已废弃的 rust-tools.nvim）
- **LSP**: `rust-analyzer`，通过 rustaceanvim
- **特性**: Inlay hints、cargo 集成、crate 依赖图、可运行项、悬停操作
- **调试**: 通过 nvim-dap 使用 LLDB

### Python
- **LSP**: `pyright`（类型检查）、`ruff`（lint 和格式化）
- **特性**: 类型推断、自动导入、诊断代码、快速修复
- **调试**: 通过 nvim-dap 使用 Debugpy
- **测试**: pytest 集成

### Haskell
- **插件**: `haskell.nvim` 搭配 `haskell-tool`
- **LSP**: `haskell-language-server` (HLS)
- **特性**: 类型签名、跳转到定义、hoogle 搜索、cabal/stack 集成
- **特殊**: GHCup 工具链支持

### C/C++
- **LSP**: `clangd`，支持项目感知的配置
- **特性**: 交叉引用、include 管理、代码操作、语义高亮
- **调试**: 通过 nvim-dap 使用 GDB/LLDB
- **构建**: 通过 `cmake-tools` 集成 CMake

### C#
- **LSP**: `csharp-ls`、`omnisharp`、`roslyn`
- **特性**: IntelliSense、navigate-to、重命名、提取方法
- **DAP**: netcoredbg 用于 .NET 调试
- **插件**: `eazy-dotnet` 用于 .NET 项目管理
- **Unity**: Unity 引擎集成

### TypeScript/JavaScript
- **LSP**: `vtsls`、`ts_ls`、`volar` (Vue)、`vue_ls`
- **插件**: `ts_tool` 用于 TypeScript 工具链
- **特性**: 自动导入、inlay hints（参数名、类型）、组织导入
- **调试**: 通过 nvim-dap 使用 Node.js 调试器
- **Emmet**: `emmet_ls` 和 `emmet-language-server` 用于 HTML/CSS/JSX 展开

### Shell 与配置文件
- **Shell Script**: `bashls` 用于 Bash 语言服务器
- **JSON**: `jsonls` 用于 JSON schema 验证和补全
- **CSS/SCSS**: `cssls` 带 CSS IntelliSense
- **YAML**: `yamlls` 用于 schema 验证
- **Lua**: `lua_ls` 用于 Lua 语言服务器（本配置本身也使用）
- **Vim Script**: `vimls` 用于 VimL 补全

### 系统编程
- **Assembly**: `asm_lsp` 用于汇编语言支持
- **CMake**: CMake 语言服务器，用于构建配置
- **Zig**: `zls` 用于 Zig 语言服务器
- **Go**: `gopls` 用于 Go 语言服务器
- **PowerShell**: `powershell_es` 用于 PowerShell 脚本

### 游戏开发
- **GDScript**: 用于 Godot 4 脚本的 LSP
- **GLSL**: `glslls` 用于着色器语言
- **GDShader**: `gdshader_lsp` 用于 Godot 着色器文件
- **QML**: `qmlls` 用于 Qt Quick/QML

### 函数式与其他
- **F#**: `fsharp_language_server` 搭配 `fsautocomplete`
- **Common Lisp**: `cl-lsp` 用于 Common Lisp
- **Sonic Pi**: Sonic Pi 实时编码音乐集成
- **XML**: `lemminx` 用于 XML schema 验证
- **Hyprland**: `hyprls` 用于 Hyprland 窗口管理器配置
- **CSpell**: `cspell_ls` 用于代码拼写检查

### LSP 管理
- **Mason**: 通用的 LSP 服务器、lint 工具和格式化安装器
- **Mason-LSPConfig**: 为 Mason 安装的服务器自动配置 LSP
- **逐服务器配置**: 30+ 语言专属配置位于 `lsp/*.lua`
- **项目 LSP**: `lsp_project.lua` 用于项目特定的 LSP 覆盖
- **自动检测**: 自动为检测到的语言启用 LSP

### 语言专属特性
- **Blink.cmp**: 现代补全引擎，支持 snippet
- **LSP Signature**: 悬停和参数输入时显示函数签名帮助
- **Refactoring**: 安全的代码转换（提取函数、重命名等）
- **Neorg**: 在 Neovim 中记笔记和文档结构化
- **Render Markdown**: 在 Neovim 中提供丰富的 Markdown 渲染
- **Obsidian**: 集成 Obsidian 库，用于知识管理
- **Firenvim**: 使用 Neovim 编辑浏览器文本区域

---

## 特殊功能

除了标准编辑器功能外，本配置还包含多个独特的集成和高级工具，可增强开发工作流、提供跨平台生产力提升，并启用现代工具集成模式。

### AI 集成

#### 多 AI 提供商
本配置同时支持多个 AI 后端，让你可以为每项任务选择最合适的提供商：
- **OpenAI**: 通过 Avante 使用 GPT-4 和 GPT-4o 模型
- **GitHub Models**: 通过 GitHub 模型市场免费访问各种 LLM
- **SiliconFlow**: 高性价比的国产 LLM 提供商
- **自定义端点**: 可配置为自托管或私有模型

#### AI 功能
- **内联聊天**: 无需离开缓冲区即可提问、请求代码更改和获取解释 (`<C-a>`)
- **代码操作**: 选择代码并应用 AI 建议的重构、测试或优化 (`<C-x>`)
- **AI 操作符**: 使用 `go` 或 `goo` 将可视化选区直接发送给 OpenCode
- **上下文感知**: AI 可以看到当前缓冲区、选区和项目结构
- **面板切换**: `<leader>oC` 打开/关闭 OpenCode 面板，用于持续的 AI 会话

#### MCP (Model Context Protocol)
- **mcphub.nvim**: 在端口 37373 上运行 MCP Hub，用于工具集成
- **文件访问**: AI 代理可以读取、搜索和分析项目文件
- **可扩展**: 为任何外部工具或 API 添加自定义 MCP 服务器

#### OpenCode
- **一等公民集成**: 围绕 OpenCode 设计的原生键映射和操作符
- **操作符模式**: 可视化选区自动添加 AI 上下文前缀
- **面板管理**: 专用切换器，用于持久化的 AI 工作区

### 输入法集成

无缝输入法切换，支持双语打字工作流：
- **im-select**: 在进入/退出 Insert 模式时自动切换到正确的 IME 模式
- **Fcitx5 集成**: 完整的 Fcitx5 控制和状态显示
- **Fcitx5 UI**: 可视化指示器，显示当前输入法状态
- **Rime 输入法**: 内置 Rime（中州韵）集成，用于中文输入
- **自动切换**: 记住每个缓冲区和模式上次使用的 IME

### 图像处理

用于处理图像和视觉内容的工具：
- **Carbon.now**: 通过 Carbon.sh 生成精美的代码截图
- **NVim Highlight Colors**: 在文件中为十六进制颜色代码显示实际的颜色样本
- **Render Markdown**: 在 Markdown 缓冲区中进行丰富的图片渲染
- **Smear Cursor**: 可视化光标拖尾，适合演示和录制

### 性能监控

内置的性能和生产力跟踪：
- **WakaTime**: 跨所有语言和项目的自动时间追踪
- **启动分析**: Lite 模式与 Full 模式的性能对比
- **LSP 诊断**: 实时显示错误、警告和提示
- **问题计数**: 状态栏中集成诊断计数
- **内存感知**: 针对 AI 交互的 token 和性能监控

### 高级工具

生产力提升器和生活质量改进：
- **Undotree**: 可视化并导航完整的撤销历史树
- **Hydra**: 多键映射序列（窗口调整大小、DAP 控制）
- **Snacks**: Neovim 工具的多功能瑞士军刀（选择器、通知器等）
- **Mark**: 快速书签，用于在不同重要位置之间跳转
- **Resession**: 保存和恢复整个 Neovim 会话，含布局
- **Hardtime**: 强制执行正确的 Vim 导航（防止滥用方向键）
- **Neovide 支持**: GPU 加速的 Neovim GUI，带自定义字体和效果
- **Kitty Navigator**: 与 Kitty 终端模拟器无缝窗口分割
- **Vim-Tmux Navigator**: Vim 和 Tmux 之间的跨面板导航
- **Screenkey**: 显示最近的按键操作（适合教程和演示）
- **MinInvim**: 极简 Vim 配置模式
- **Unity Editor**: Unity 引擎项目集成
- **Project Toolchain**: 每个项目的工具和 LSP 配置管理
- **Rest Client**: 在 Neovim 中进行 HTTP 请求测试
- **Firenvim**: 将浏览器的文本区域转换为 Neovim 缓冲区

## 另请参阅

- [README_zh.md](./README_zh.md) - 安装指南和快速参考
- [DEVELOP_zh.md](./DEVELOP_zh.md) - 开发指南和配置结构
