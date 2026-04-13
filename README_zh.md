# 个人 Neovim 配置

本仓库包含我的个人 Neovim 配置文件。

> **⚠️ 免责声明**: 如果你想使用此配置，建议 fork 本仓库或锁定特定版本以避免后续更新导致的不兼容问题。

## 目录
- [功能特性](#功能特性)
- [已知问题](#已知问题)
- [依赖要求](#依赖要求)
- [安装指南](#安装指南)
  - [前置条件](#前置条件)
  - [Windows 安装](#windows-安装)
  - [Linux/macOS 安装](#linuxmacos-安装)
  - [语言工具配置](#语言工具配置)
- [快捷键](#快捷键)
  - [快速参考](#快速参考)
- [Lite 模式](#lite-模式)
- [配置结构](#配置结构)
- [问题排查](#问题排查)

## 功能特性

### 🚀 核心功能
- **现代 Neovim 架构**: 基于 Neovim 0.9+ 的 Lua 配置
- **模块化设计**: 清晰有序的配置结构，易于维护
- **双模式支持**: 完整版和 Lite 版两种模式适配不同场景
- **跨平台兼容**: 针对 Linux、macOS 和 Windows 优化

### 🤖 AI 增强开发
- **多 AI 提供商**: 通过 `avante.nvim` 支持 OpenAI、GitHub Models、SiliconFlow 等
- **MCP 集成**: Model Context Protocol 支持高级 AI 交互
- **FitteCode 集成**: 额外的 AI 编码助手
- **图像处理**: AI 驱动的图像分析和处理能力

### 🔧 开发工具
- **全面 LSP 支持**: 20+ 语言服务器，智能补全和诊断
- **高级调试**: 完整的 `nvim-dap` 调试功能和语言特定适配器
- **测试框架**: 集成 `neotest` 实现无缝测试执行
- **任务管理**: `overseer.nvim` 用于运行和管理开发任务

### 🎨 现代 UI/UX
- **Catppuccin 主题**: 精美的 frappe 风格配色方案
- **增强状态栏**: 信息丰富的 `lualine.nvim`，包含 git、诊断和导航信息
- **智能缓冲区管理**: `bufferline.nvim` 实现直观的缓冲区导航
- **文件管理**: 双文件浏览器支持 (`nvim-tree.nvim` 和 `neo-tree.nvim`)
- **启动面板**: 带有 ASCII 艺术的自定义启动画面

### ⚡ 性能与效率
- **Tree-Sitter 集成**: 50+ 语言的快速准确语法高亮
- **智能代码折叠**: `nvim-ufo` 实现智能代码折叠
- **多光标支持**: 高级多光标编辑功能
- **快速导航**: `flash.nvim` 实现闪电般的跳转和导航
- **大文件处理**: 自动优化 5000+ 行的文件

### 🔍 搜索与导航
- **Telescope 集成**: 支持 FZF 加速的模糊搜索
- **全局搜索与替换**: `grug-far.nvim` 实现高级搜索替换操作
- **Git 集成**: 全面的 Git 支持，包含 `gitsigns.nvim` 和 `lazygit.nvim`
- **版本控制**: 支持 Git 和 Jujutsu (jj)
- **文件管理器**: 终端文件管理工具 `yazi`
- **会话管理**: `resession.nvim` 用于保存/恢复工作区会话

### 🛠️ 任务与终端管理
- **任务运行器**: `overseer.nvim` 用于运行和管理开发任务
- **终端**: `floaterm` 用于浮动终端窗口
- **任务自动化**: QuickMenu 用于常见开发工作流

## 已知问题
- **启动时间较长**: 本配置优先考虑功能完整性，启动时间比最小化配置更长
- **配置复杂度**: 全面的配置可能需要一定的学习曲线

> **平台说明**: Windows 用户由于平台性能限制可能体验到明显较慢的启动时间。虽然提供了 lite 模式来缓解此问题，但目前在 Unix 类系统 (Linux/macOS) 上可获得最佳性能。

## 依赖要求

### 必需依赖
- **Neovim**: 0.9+ (推荐 0.10+)
- **Git**: 插件管理和版本控制必需
- **Node.js**: 许多 LSP 服务器和工具必需
- **Python**: 某些语言服务器和工具必需

### 强烈推荐
- **LazyGit**: 现代 Git GUI
- **Ripgrep** (rg): 快速文本搜索，用于 Telescope 和全局搜索
- **Tree-sitter CLI**: 用于解析器安装和管理

### 构建工具 (部分功能必需)
- **Windows**: Clang 或 MSVC Build Tools
- **Linux**: gcc/clang 和 make
- **macOS**: Xcode Command Line Tools (`xcode-select --install`)

### 增强体验的可选依赖
- **Neovide**: 具有额外优化的现代 Neovim GUI
- **Nerd Font**: 用于正确显示图标 (如 FiraCode Nerd Font)
- **Jujutsu**: 用于 Jujutsu (jj) 版本控制用户
- **剪贴板工具**: 系统剪贴板集成
  - **Linux**: xclip 或 xsel
  - **macOS**: pbcopy/pbpaste (内置)
  - **Windows**: win32yank 或 WSL 剪贴板集成

### 语言工具链 (按需安装)
- **Rust**: rustup
- **Haskell**: GHCup + HLS
- **Python**: pip/conda
- **C/C++**: MSVC/LLVM
- **.NET**: .NET SDK
- **Node.js**: npm/yarn/pnpm
- **Go**: go toolchain
- **Java**: JDK + Maven/Gradle
- **PHP**: Composer + PHP 运行时

## 安装指南

### 前置条件
- Neovim 0.9+ (推荐 0.10+)
- Git (必需), LazyGit (可选但推荐)
- Ripgrep (rg) 用于搜索
- Tree-sitter 编译器: Windows 安装 Clang 或 MSVC Build Tools; Linux/macOS 安装 gcc/clang 和 make
- Node.js (必需)
- 按需安装语言工具链: Rust 用 rustup, C/C++ 用 MSVC/LLVM, Haskell 用 GHCup + HLS 等

### Windows 安装
1) 备份现有配置 (如有): 将 %LOCALAPPDATA%\nvim 移动到备份文件夹。
2) 将本仓库克隆到 Neovim 配置目录:
   - Fork 本仓库
   - `git clone <你的仓库地址> "%LOCALAPPDATA%/nvim"`
   - 如果没有设置 SSH 密钥，首次运行前编辑 `lua/options/gitpull_cfg.lua` 设置 `use_ssh=false` 以使用 HTTPS 克隆插件。
3) 首次运行
   - 启动 Neovim: `nvim`
   - lazy.nvim 会自动引导并安装插件。
   - 如果 Tree-sitter 解析器编译失败，确保 C/C++ 编译器工具链 (MSVC 或 LLVM/Clang) 在 PATH 中。
4) 可选: Lite 模式加快启动
   - `nvim --cmd "let g:lite_mode=v:true"`
5) 按需通过 Mason 安装外部工具
   - 运行 `:Mason` 打开 UI 安装语言服务器、格式化器和 DAP 适配器。
   - 在 Windows 上，本配置会自动将 Mason 的 bin 目录添加到当前 Neovim 会话的 PATH。
6) 字体和图标
   - 安装 Nerd Font (如 FiraCode Nerd Font) 并配置终端使用，以正确显示 UI 插件的图标。

### Linux/macOS 安装
1) 克隆到配置目录:
   - `git clone <你的仓库地址> ~/.config/nvim`
2) 确保安装构建工具:
   - gcc/clang 和 make 用于 Tree-sitter; ripgrep 用于搜索。
3) 首次运行
   - `nvim`
   - 如果解析器或原生依赖编译失败，安装所需工具链后重试 `:TSUpdate`。
4) 可选: Lite 模式
   - `nvim --cmd "let g:lite_mode=v:true"`

### 语言支持

本配置通过智能 LSP 集成、调试、测试和语言特定工具全面支持 20+ 编程语言。

#### 🦀 Rust
- **LSP**: rustaceanvim 搭配 rust-analyzer
- **功能**: Cargo 集成、飞行检查、代码操作
- **测试**: neotest 集成 cargo test
- **调试**: codelldb 通过 nvim-dap
- **安装**: 安装 rustup 和 rust-analyzer

#### 🐍 Python
- **LSP**: pyright 搭配 ruff 用于检查和格式化
- **功能**: 类型检查、自动导入、文档字符串生成
- **测试**: pytest 通过 neotest 集成
- **调试**: debugpy 适配器
- **安装**: 安装 python 和所需 pip 包

#### 🟢 Haskell
- **LSP**: haskell-language-server (HLS)
- **功能**: GHC 集成、hlint、brittany 格式化
- **工具**: haskell-tools.nvim 增强 Haskell 体验
- **安装**: 安装 GHCup 和 HLS
- **快速设置**: `curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh`

#### 🔧 C/C++
- **LSP**: clangd
- **功能**: 编译命令、交叉引用
- **调试**: codelldb 或 GDB 通过 nvim-dap
- **安装**: 安装 clangd 和构建工具
- **设置**: 为项目生成 `compile_commands.json`

#### 🔷 C#
- **LSP**: roslyn, omnisharp 或 csharp_ls (可配置)
- **功能**: .NET 解决方案集成
- **测试**: dotnet test 支持
- **安装**: 安装 .NET SDK 和 Mason 管理的服务器
- **注意**: 如需要可在 `lua/core/lsp.lua` 中启用

#### 🌐 TypeScript/JavaScript
- **LSP**: ts_tool (TypeScript) 和 biome 用于格式化
- **功能**: Node.js 集成、JSX/TSX 支持
- **测试**: Jest/vitest 集成
- **安装**: 安装 Node.js 和 TypeScript

#### 🐚 Shell 脚本
- **LSP**: bashls 用于 Bash
- **功能**: Shell 脚本验证和补全
- **安装**: 通过 npm 安装 bash-language-server

#### 📝 配置文件
- **JSON**: jsonls 带 schema 验证
- **YAML**: yamlls
- **TOML**: taplo
- **Markdown**: marksman 用于导航和链接
- **Docker**: dockerls
- **Git**: gitui 用于 git 操作

#### 🖥️ 系统编程
- **Assembly**: asm_lsp 用于 x86/x64 汇编
- **CMake**: cmake 语言服务器
- **GLSL**: glslls 用于 OpenGL 着色器
- **Lua**: lua_ls 带 Neovim 特定 API 支持

#### 🎮 游戏开发
- **GDScript**: Godot 引擎的 gdscript LSP
- **安装**: 安装 Godot 并启用 GDScript LSP

#### 📚 函数式及其他语言
- **Common Lisp**: cl-lsp 集成 SBCL
- **F#**: .NET F# 的 fsautocomplete
- **PowerShell**: 用于 Windows 自动化的 powershell_es
- **AutoHotkey**: 用于 Windows 脚本的 autohotkey_lsp

#### 🔧 LSP 管理

所有语言服务器都通过 Mason 管理以便于安装和更新:

```vim
:Mason                    " 打开 Mason UI
:MasonInstall <服务器>    " 安装特定的 LSP 服务器
:MasonUpdate             " 更新所有已安装的服务器
```

#### 🎯 语言特定功能

- **保存时自动格式化**: 每种语言可配置
- **代码操作**: 重构、导入组织、错误修复
- **智能补全**: 上下文感知的建议
- **诊断**: 实时错误检查和警告
- **文档**: Hover 和签名帮助
- **导航**: 跳转到定义、引用、类型定义
- **调试**: 集成调试，支持断点和变量检查

## 快捷键

使用 `\?` 查看所有缓冲区本地快捷键。

### 快速参考

| 快捷键 | 描述 |
|--------|------|
| `<C-x>f` | 选择文件 (mini.files) |
| `<C-x><C-f>` | 打开文件 |
| `<C-x>a` | 显示 LSP 操作菜单 |
| `<C-x>t` | 显示测试菜单 |
| `<C-x>q` | 打开 QuickMenu |
| `<F3>` | 切换大纲 |
| `<F4>` | 切换 Neotree |
| `<F5>` | 打开 QuickMenu |
| `<F6>` | 切换 DAP UI |
| `<F9>` | DAP 继续 |
| `<F10>` | DAP 跳过 |
| `<F11>` | DAP 进入 |
| `<F12>` | DAP 跳出 |
| `<C-b>` | 切换断点 |
| `<C-]>` | 跳转到定义 |
| `<C-w>W` + h/j/k/l | 窗口导航 (Hydra) |
| `<leader>dp` | DAP 菜单 (Hydra) |
| `<leader>lg` | 打开 LazyGit |
| `<leader>u` | 切换 UndoTree |
| `<leader>q` | 关闭当前缓冲区 |
| `<leader>t` + j/k | 上一个/下一个缓冲区 |
| `s` | Flash 跳转 |
| `zR` / `zM` | 打开/关闭所有折叠 |
| `K` | 预览折叠或 hover |
| `<C-f>` | Telescope find_files |
| `<C-p>` | Telescope 搜索 |
| `<S-h>` / `<S-l>` | 上一个/下一个缓冲区 |
| `[b` / `]b` | 循环缓冲区 |
| `jj` | 退出插入模式 |

## Lite 模式

Lite 模式提供更短启动时间的极简 Neovim 体验:

### 使用方法
```bash
nvim --cmd "let g:lite_mode=v:true"
```

### Lite 模式禁用的功能
- 大多数 UI 插件 (lualine, which-key 等)
- AI 集成功能
- 高级调试工具
- 测试集成
- 部分语言特定增强

### Lite 模式保留的功能
- 基本 LSP 功能
- Tree-sitter 语法高亮
- 核心导航和编辑功能
- 文件操作

## 特殊功能

### 🤖 AI 集成
本配置包含增强开发的先进 AI 功能:

#### 多 AI 提供商
- **OpenAI**: GPT 模型用于代码生成和辅助
- **GitHub Models**: 访问 GitHub 的 AI 模型
- **SiliconFlow**: 替代 AI 提供商
- **本地模型**: 支持本地托管的 AI 模型

#### AI 功能
- **代码生成**: 从自然语言描述生成代码
- **代码解释**: 理解复杂代码片段
- **重构建议**: AI 驱动的代码改进
- **文档生成**: 自动生成注释和文档
- **Bug 检测**: 识别潜在问题并建议修复

#### MCP (Model Context Protocol)
- **上下文感知辅助**: AI 理解你的项目结构
- **文件集成**: AI 可以读取和分析你的代码库
- **智能建议**: 上下文相关的推荐

#### OpenCode
- **内联 AI 聊天**: 通过 `<C-a>` 直接从编辑器查询 AI
- **选择操作**: 通过 `<C-x>` 处理选中的代码
- **操作符模式**: 使用 `go` / `goo` 将文本发送给 OpenCode
- **面板切换**: 通过 `<C-.>` 切换 OpenCode 面板

### 🎨 输入法集成
对中文和其他非拉丁输入法的特殊支持:

- **Fcitx5 支持**: 进入/退出插入模式时自动切换输入法
- **Rime 集成**: 支持 Rime 输入法补全
- **状态显示**: UI 中输入法状态的可视化反馈

### 🖼️ 图像处理
高级图像处理能力:

#### 图像预览
- **内联显示**: 直接在 Neovim 中预览图像
- **多种格式**: 支持 PNG、JPG、GIF、SVG
- **智能缩放**: 自动缩放图像以获得最佳查看效果

#### AI 图像分析
- **内容描述**: AI 驱动的图像分析和描述
- **OCR 支持**: 从图像中提取文本
- **代码生成**: 从截图/图表生成代码

### 📊 性能监控
内置性能分析和优化:

#### 启动分析
- **时间分析**: 详细的启动时间分解
- **瓶颈检测**: 识别加载缓慢的组件
- **优化建议**: 自动性能建议

#### 运行时监控
- **内存使用**: 跟踪内存消耗
- **GC 优化**: 智能垃圾回收管理
- **大文件处理**: 大文件自动优化

### 🔧 高级工具
增强生产力的专业工具:

#### Carbon.now 集成
- **代码片段分享**: 生成精美的代码图片
- **社交媒体就绪**: 非常适合分享到 Twitter 等
- **可自定义主题**: 多种语法高亮主题

#### Obsidian 集成
- **笔记管理**: 无缝的 Obsidian 库集成
- **链接导航**: 智能 wiki 风格链接
- **知识图谱**: 笔记连接的可视化表示

#### 浏览器集成
- **Firenvim 支持**: 直接在浏览器中使用 Neovim
- **远程开发**: 基于 SSH 的远程编辑
- **Web 开发**: 实时浏览器同步

#### ASCII 艺术面板
- **自定义启动**: 个性化的 ASCII 艺术欢迎画面
- **动态内容**: 上下文感知的启动信息
- **品牌集成**: 自定义品牌和标志

## 配置结构

```
~/.config/nvim/
├── init.lua                           # 主配置入口
├── AGENTS.md                         # 助手操作日志
├── cspell.json                       # 拼写词典
├── lazy-lock.json                    # 插件版本锁定文件
├── lua/
│   ├── env_init.lua                  # 环境初始化和 lazy.nvim 设置
│   ├── full_init.lua                 # 完整模式初始化
│   ├── lite_init.lua                 # Lite 模式初始化
│   ├── core/                         # 核心配置模块
│   │   ├── init.lua                  # 核心模块加载器
│   │   ├── vimpreconfig.lua          # 基本 Vim 设置 (编码、缩进)
│   │   ├── vimconfig.lua             # 主题和外观设置
│   │   ├── lsp.lua                   # LSP 服务器激活
│   │   ├── autocommand_set.lua      # 自定义自动命令
│   │   ├── highlights.lua            # 自定义高亮组
│   │   └── neovide.lua               # Neovide 特定优化
│   ├── plugin/                       # 插件规格和配置
│   │   ├── init.lua                  # 插件管理器初始化
│   │   └── require/                  # 插件配置文件
│   │       ├── ui.lua                # UI 插件 (主题、状态栏等)
│   │       ├── tool.lua              # 开发工具 (telescope、git 等)
│   │       ├── editor.lua           # 编辑器增强 (surround、pairs 等)
│   │       ├── language/            # 语言特定插件
│   │       │   ├── lspconfig.lua    # LSP 配置
│   │       │   ├── rust.lua         # Rust 特定设置
│   │       │   ├── haskell.lua      # Haskell 特定设置
│   │       │   ├── ai.lua           # AI 集成插件
│   │       │   ├── debug.lua        # 调试适配器设置
│   │       │   ├── test.lua         # 测试框架设置
│   │       │   └── version_control.lua # Git 和版本控制
│   │       ├── other.lua            # 其他插件
│   │       └── rock.lua             # Lua rocks 配置
│   ├── lsp/                          # LSP 服务器配置
│   │   ├── setup/                    # 独立 LSP 服务器设置
│   │   └── config/                   # 共享 LSP 配置
│   ├── ftplugin/                     # 文件类型特定插件
│   ├── util/                         # 工具函数和辅助函数
│   │   ├── functions.lua             # 常用工具函数
│   │   ├── module_load_utils.lua    # 安全模块加载工具
│   │   ├── keymap.lua                # 键映射工具
│   │   ├── bf_actions.lua           # 缓冲区操作函数
│   │   └── quickmenu.lua            # 快速菜单实现
│   ├── global/                       # 全局配置和常量
│   │   ├── language/                 # 语言相关全局变量
│   │   │   ├── capabilities.lua     # LSP 能力配置
│   │   │   └── attach.lua           # LSP 附加逻辑
│   │   └── ui_util/                 # UI 工具和 ASCII 艺术
│   └── test/                        # 测试配置
└── lsp/                              # 额外的 LSP 配置文件
└── ftplugin/                        # 额外的文件类型插件
```

### 配置理念

本配置遵循几个关键原则:

- **模块化**: 配置的每个方面都组织成逻辑模块
- **可维护性**: 清晰的关注点分离使其易于修改和扩展
- **性能**: 懒加载和条件优化确保快速启动
- **灵活性**: 支持完整功能和轻量级模式
- **可扩展性**: 易于添加新语言、插件或功能

## 问题排查

### 常见问题

#### Windows 启动缓慢
- 尝试使用 lite 模式: `nvim --cmd "let g:lite_mode=v:true"`
- 确保杀毒软件没有过度扫描 Neovim 文件
- 考虑使用 WSL2 代替原生 Windows
#### LSP 服务器不启动
- 通过 Mason 安装语言服务器: `:Mason`
- 使用 `:LspInfo` 检查 LSP 状态
- 确保语言服务器在 PATH 中

#### 插件安装问题
- 删除 `pack` 目录并重启 Neovim
- 检查网络连接
- 验证 git 配置正确

### 有用的命令

- `:Lazy` - 插件管理器 UI
- `:Mason` - 安装 LSP 服务器、格式化器、DAP 适配器
- `:LspInfo` - 检查 LSP 服务器状态
- `:TSUpdate` - 更新 Tree-sitter 解析器
- `:checkhealth` - 诊断常见问题
- `:QuickMenu` - 访问常见开发任务
- `<C-x>oo` / `<C-x>or` - Overseer 任务命令

### 获取帮助

- 查看 `lua/` 目录中的配置文件了解具体设置
- 使用 `:checkhealth` 诊断常见问题
- 加入 Neovim 社区获取额外支持
- 查看插件文档解决特定问题