# 开发指南

本文档提供了使用此 Neovim 配置进行开发的全面指南，包括命令、架构、依赖和扩展模式。

## 目录

- [开发命令](#开发命令)
- [架构](#架构)
- [依赖](#依赖)
- [配置哲学](#配置哲学)
- [添加新功能](#添加新功能)
- [键位映射](#键位映射)
- [参见](#参见)

---

## 开发命令

启动、验证和与此 Neovim 配置交互的核心命令。

### 启动 Neovim

以全功能模式或精简模式启动配置：

```bash
nvim                              # 全功能模式（加载所有插件）
nvim --cmd "let g:lite_mode=v:true"  # 精简模式（最小配置，启动更快）
```

### 验证配置

在不打开编辑器的情况下，通过命令行运行 Neovim 内置的健康检查来诊断问题：

```bash
nvim --headless -c "lua vim.health ~= nil and vim.health.check() or vim.cmd('checkhealth')" -c "q" 2>&1
```

### Neovim 内部命令

Neovim 运行后可用的常用命令：

| 命令 | 描述 |
|---------|-------------|
| `:Lazy` | 插件管理器界面 — 管理、更新和同步插件 |
| `:Mason` | 安装 LSP 服务器、格式化器、linter 和 DAP 适配器 |
| `:LspInfo` | 检查已附加的 LSP 服务器状态及其功能 |
| `:TSUpdate` | 将所有 Tree-sitter 解析器更新到最新版本 |
| `:checkhealth` | 运行 Neovim 和插件的全面自诊断 |
| `:ConfigEdit <type>` | 快速编辑配置文件（例如 `:ConfigEdit nvim` 打开 init.lua） |
| `:OverseerRun` | 通过 overseer.nvim 运行预定义的开发任务 |
| `:OverseerToggle` | 切换 Overseer 任务管理面板 |
| `:QuickMenu` | 访问常用开发工作流（搜索、git、调试等） |

---

## 架构

该配置遵循模块化、分层架构设计，旨在提高可维护性和性能。

### 入口点

初始化流程基于全局变量 `g:lite_mode` 进行分支：

| 文件 | 用途 |
|------|---------|
| `init.lua` | 主入口点 — 引导 lazy.nvim，加载环境初始化，选择全功能或精简模式 |
| `lua/full_init.lua` | 全功能模式初始化 — 加载所有插件、LSP、DAP、AI 工具和 UI 增强 |
| `lua/lite_init.lua` | 精简模式初始化 — 仅加载核心插件以实现快速启动 |

### 核心层

每一层都有单一职责，减少配置关注点之间的耦合：

| 层 | 用途 |
|-------|---------|
| `lua/core/` | 核心设置 — LSP 激活、键位映射、自动命令、高亮、主题配置 |
| `lua/options/` | Neovim 选项 — 编辑器行为、外观和运行时设置 |
| `lua/plugin/` | 插件规范（lazy.nvim）和插件加载编排 |
| `lua/global/` | 全局工具 — 共享 LSP 功能、UI 辅助函数和常量 |
| `lua/util/` | 工具函数 — 键位映射助手、模块加载工具、缓冲区操作、快捷菜单 |
| `lsp/` | 每种语言的 LSP 服务器配置（放在 lua/ 外部以保持清晰） |

### 插件加载

插件按类别组织在 `lua/plugin/require/require.lua` 中。每个类别将相关插件分组在一起：

| 类别 | 内容 |
|----------|----------|
| `ui/` | 主题（catppuccin）、状态栏（lualine）、bufferline、edgy 布局、文件树 |
| `tool/` | Telescope（模糊查找器）、Git 集成、overseer（任务）、AI 工具（avante、opencode、claude） |
| `editor/` | Surround、autopairs、trouble（诊断）、which-key、flash（导航） |
| `language/` | LSP 配置、DAP（调试）、补全（blink.cmp）、Tree-sitter、语言特定设置 |

这种分类方式使得按功能领域定位和管理插件变得非常容易。

---

## 依赖

此配置依赖外部工具和语言工具链。仅安装你的工作流所需的内容。

### 必需

这些是配置正常运行所必需的：

| 依赖 | 用途 |
|------------|---------|
| **Neovim 0.9+**（推荐 0.10+） | 编辑器本身 |
| **Git** | 通过 lazy.nvim 进行插件管理、版本控制 |
| **Node.js** | 许多 LSP 服务器（typescript-language-server、eslint 等）和 Tree-sitter 所需 |
| **Python** | 某些语言服务器和工具所需 |

### 推荐

强烈推荐以获得完整体验：

| 依赖 | 用途 |
|------------|---------|
| **LazyGit** | 现代化终端 Git 界面（`<leader>lg`） |
| **Ripgrep** (rg) | 快速正则搜索，Telescope 和全局搜索功能使用 |
| **Tree-sitter CLI** | 用于语法高亮的解析器安装和管理 |

### 构建工具

编译 Tree-sitter 解析器和本地插件依赖所必需：

| 平台 | 工具 |
|----------|-------|
| **Windows** | Clang 或 MSVC Build Tools |
| **Linux** | gcc/clang 和 make |
| **macOS** | Xcode Command Line Tools (`xcode-select --install`) |

### 可选

增强体验但非必需：

| 依赖 | 用途 |
|------------|---------|
| **Neovide** | GPU 加速的 Neovim GUI，带有额外优化 |
| **Nerd Font** | 在 UI 插件中正确显示图标（例如 FiraCode Nerd Font） |
| **Jujutsu** (jj) | 现代 VCS，供 jj 用户使用（与 Git 共存支持） |
| **剪贴板工具** | 系统剪贴板集成 — `xclip`/`xsel`（Linux）、`pbcopy`（macOS）、`win32yank`（Windows） |

### 语言工具链

仅安装你使用的语言对应的工具链：

| 语言 | 工具链 |
|----------|-----------|
| **Rust** | rustup |
| **C/C++** | MSVC / LLVM (clangd) |
| **Haskell** | GHCup + HLS (haskell-language-server) |
| **Python** | pip / conda |
| **C# / .NET** | .NET SDK |
| **TypeScript/JavaScript** | npm / yarn / pnpm |
| **Go** | go toolchain |
| **Java** | JDK + Maven / Gradle |
| **PHP** | Composer + PHP runtime |
| **Lua** | lua-language-server（通过 Mason 包含） |

所有 LSP 服务器都通过 Mason 管理 — 在 Neovim 内部运行 `:Mason` 来安装和更新它们。

---

## 配置哲学

此配置由几个关键原则指导，这些原则塑造了每一个设计决策：

- **模块化**：配置的每个方面都被组织成逻辑上自包含的模块。相关设置放在一起；不相关的设置分开存放。这使得查找、理解和修改配置的任何部分都变得容易。

- **可维护性**：清晰的关注点分离确保一个区域的更改（例如添加插件）不会意外影响另一个区域（例如键位绑定）。每个模块都有单一职责和可预测的接口。

- **性能**：延迟加载和条件初始化在配置功能广泛的同时保持合理的启动时间。精简模式为速度比功能更重要的场景提供了退出路径。

- **灵活性**：双模式系统（全功能 vs 精简）支持不同的工作流和平台。跨平台兼容性内置其中 — Windows、macOS 和 Linux 都是一等公民。

- **可扩展性**：添加新语言、插件或功能遵循既定模式。插件加载系统按领域分类（ui、tool、editor、language），使贡献可预测且一致。

---

## 添加新功能

本节介绍常见的扩展任务并提供实用指导。

### 添加新插件

1. **定义插件规范**：在 `lua/plugin/init.lua` 中定义。使用 lazy.nvim 的规范格式来声明仓库、依赖、延迟加载条件和任何构建步骤。

2. **创建配置文件**：在 `lua/plugin/require/` 下的相应子目录中创建：
   - UI 插件放在 `ui/`
   - 工具和集成放在 `tool/`
   - 编辑器增强放在 `editor/`
   - 语言特定插件放在 `language/`

3. **注册插件**：在 `lua/plugin/require/require.lua` 中对应类别部分添加 `require` 调用。这确保插件初始化时加载配置文件。

> **提示**：如果插件没有自定义配置（默认设置已足够），可以跳过第 2 步，只需在 `init.lua` 中添加规范即可。

### 添加新 LSP 服务器

1. **通过 Mason 安装服务器**：
    ```vim
    :MasonInstall <server-name>
    ```

2. **在 `lua/core/lsp.lua` 中启用服务器**，添加：
    ```lua
    vim.lsp.enable('<server-name>')
    ```

3. **添加自定义设置**（可选）：如果服务器需要特定配置（初始化选项、自定义功能、根目录模式），在 `lsp/setup/<server-name>.lua` 中添加设置文件，并从 `lua/core/lsp.lua` 中 require 它。

> **提示**：使用 `:LspInfo` 验证服务器是否已附加到你的缓冲区，使用 `:checkhealth lspconfig` 排查问题。

### 添加新键位映射

1. **选择正确的文件**：
   - 对于简单的独立键位映射，直接在 `lua/core/keymap/init.lua` 的相应部分添加。
   - 对于与特定插件或功能相关的键位映射，在 `lua/core/keymap/` 中创建新文件（例如 `lua/core/keymap/my_plugin.lua`）并从 `init.lua` 中 require 它。

2. **使用 `vim.keymap.set()` 定义映射**：
    ```lua
    vim.keymap.set('n', '<leader>xx', '<Cmd>MyCommand<CR>', { desc = 'Description', noremap = true, silent = true })
    ```

3. **对于复杂的多键序列**，考虑使用 Hydra：
    ```lua
    Hydra({
      name = 'MyTool',
      body = '<leader>mt',
      heads = {
        { 'a', '<Cmd>ActionA<CR>', { description = 'Action A' } },
        { 'b', '<Cmd>ActionB<CR>', { description = 'Action B' } },
      },
    })
    ```

> **提示**：始终添加 `desc` 字段 — 它可以启用 which-key 集成并使 `<leader>?` 更有用。

---

## 键位映射

所有键位映射都定义在 `lua/core/keymap/` 下。使用 `<leader>?` 可以随时查看缓冲区本地键位映射。

> **注意**：此表涵盖最常用的键位映射。在 Neovim 中使用 `<leader>?` 查看所有缓冲区本地键位映射（which-key 弹出窗口），或查看 `lua/core/keymap/init.lua` 获取完整列表。

### 导航与文件

| 键位 | 操作 |
|-----|--------|
| `<C-x>f` | 选择文件（Pick） |
| `<C-x><C-f>` | 打开文件（mini.files） |
| `<C-f>` | Telescope find_files |
| `<C-p>` | Telescope（通用） |

### LSP 与代码操作

| 键位 | 操作 |
|-----|--------|
| `<C-x>a` | LSP 操作菜单 |
| `<C-]>` | 跳转到定义 |

### 测试与调试

| 键位 | 操作 |
|-----|--------|
| `<C-x>t` | 测试菜单（neotest） |
| `<F6>` | 切换 DAP UI |
| `<F9>` | DAP 继续 |
| `<F10>` | DAP 单步跳过 |
| `<F11>` | DAP 单步进入 |
| `<F12>` | DAP 单步跳出 |
| `<C-b>` | 切换断点 |

### 缓冲区

| 键位 | 操作 |
|-----|--------|
| `<leader>q` | 关闭当前缓冲区 |
| `<leader>t` + j/k | 上一个/下一个缓冲区（Hydra） |
| `<S-h>` / `<S-l>` | 上一个 / 下一个缓冲区 |
| `[b` / `]b` | 循环缓冲区 |
| `[B` / `]B` | 移动缓冲区位置 |

### 窗口与标签页

| 键位 | 操作 |
|-----|--------|
| `<C-w>c` + hjkl | 窗口导航（Hydra） |
| `<C-w>W` + hjkl | 窗口大小调整（Hydra） |

### UI 与工具

| 键位 | 操作 |
|-----|--------|
| `<F3>` | 切换 Outline |
| `<F4>` | 切换 Neotree |
| `<F5>` | QuickMenu |
| `<C-x>q` | QuickMenu |
| `<C-x>u` / `<leader>u` | 切换 undotree |
| `<leader>lg` | 打开 LazyGit |
| `<leader>fs` | Rip substitute（查找和替换） |
| `<leader>xx` | Trouble 诊断 |
| `<leader>?` | Which-key 弹出窗口 |
| `K` | 预览折叠或悬停（UFO / LSP） |

### 编辑与导航

| 键位 | 操作 |
|-----|--------|
| `s` | Flash 跳转 |
| `jj` | 退出插入模式 |
| `zR` / `zM` | UFO 折叠控制（打开/关闭所有） |
| `zr` / `zm` | UFO 折叠控制（打开/关闭除特定类型外） |

### AI 集成

| 键位 | 操作 |
|-----|--------|
| `<C-a>` | 询问 OpenCode AI |
| `<leader>oC` | 切换 OpenCode 面板 |
| `go` | 操作符 — 添加范围到 OpenCode |
| `goo` | 操作符 — 添加行到 OpenCode |
| `<S-C-u>` | 向上滚动 OpenCode |
| `<S-C-d>` | 向下滚动 OpenCode |

### DAP 菜单（Hydra `<leader>dp`）

| 键位 | 操作 |
|-----|--------|
| `c` | 继续 |
| `i` | 单步进入 |
| `o` | 单步跳出 |
| `p` | 单步跳过 |
| `n` | 下一个断点 |
| `s` | 停止 |
| `r` | 重启 |
| `d` | 断开连接 |
| `t` | 切换断点 |
| `u` | 切换 UI |
| `e` | 求值表达式 |

---

## 另请参阅

- [README_zh.md](./README_zh.md) - 安装指南和快速参考
- [FEATURES_zh.md](./FEATURES_zh.md) - 功能列表和语言支持
