# 个人 Neovim 配置

```
 /$$$$$$             /$$                       
|_  $$_/            | $$                        
  | $$    /$$$$$$$ /$$$$$$   /$$   /$$  /$$$$$$ 
  | $$   /$$_____/|_  $$_/  | $$  | $$ /$$__  $$
  | $$  | $$        | $$    | $$  | $$| $$$$$$$$
  | $$  | $$        | $$ /$$| $$  | $$| $$_____/ 
 /$$$$$$|  $$$$$$$  |  $$$$/|  $$$$$$$|  $$$$$$$ 
|______/ \_______/   \___/   \____  $$ \_______/  
                             /$$  | $$           
                            |  $$$$$$/           
                             \______/            
```

本仓库包含我的个人 Neovim 配置。

版权所有 (c) 2026 Ictye，保留所有权利

如果你想使用此配置，建议 fork 本仓库或锁定到特定版本。

## 目录
- [已知问题](#已知问题)
- [安装](#安装)
  - [前置条件](#前置条件)
  - [Windows 安装](#windows-安装)
  - [Linux/macOS 安装](#linuxmacos-安装)
- [常用快捷键](#常用快捷键)
- [Lite 模式](#lite-模式)
- [问题排查](#问题排查)
- [另请参阅](#另请参阅)

## 已知问题
- **启动时间较长**: 本配置优先考虑功能完整性而非启动速度，相较于最小化配置会有更长的初始化时间。
- **配置复杂度**: 由于配置内容全面，从基础编辑器迁移过来的用户可能需要一定的学习曲线。

> **平台说明**: Windows 用户由于平台特定的性能限制，可能会经历明显较慢的启动时间。虽然提供了 lite 模式来缓解此问题，但目前最佳性能仍可在 Unix 类系统 (Linux/macOS) 上获得。

## 安装

### 前置条件
- Neovim 0.9+ (推荐 0.10+)
- Git (必需), LazyGit (可选但推荐)
- Ripgrep (rg) 用于搜索
- Tree-sitter 编译器: Windows 安装 Clang 或 MSVC Build Tools; Linux/macOS 安装 gcc/clang 和 make
- Node.js (必需)
- 按需安装语言工具链: Rust 用 rustup, C/C++ 用 MSVC/LLVM, Haskell 用 GHCup + HLS 等

### Windows 安装
1) 备份现有配置 (如有): 将 `%LOCALAPPDATA%\nvim` 移动到备份文件夹。
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
   - `:Mason` 打开 UI 安装语言服务器、格式化器和 DAP 适配器。
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

## 常用快捷键

使用 `\?` 查看所有缓冲区本地快捷键。

| 快捷键 | 描述 |
|--------|------|
| `<C-x>f` | 选择文件 (mini.files) |
| `<C-x><C-f>` | 打开文件 |
| `<C-x>a` | 显示 LSP 操作菜单 |
| `<C-x>t` | 显示测试菜单 |
| `<C-x>q` | 打开 QuickMenu |
| `<F9>` | DAP 继续 |
| `<F10>` | DAP 跳过 |
| `<F11>` | DAP 进入 |
| `<F12>` | DAP 跳出 |
| `<leader>lg` | 打开 LazyGit |
| `s` | Flash 跳转 |
| `jj` | 退出插入模式 |
| `<leader>q` | 关闭当前缓冲区 |
| `<leader>t` + j/k | 上一个/下一个缓冲区 |
| `zR` / `zM` | 打开/关闭所有折叠 |
| `<C-a>` | OpenCode AI 聊天 |
| `<leader>oC` | 切换 OpenCode 面板 |

## Lite 模式

Lite 模式提供启动更快的极简 Neovim 体验:

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

## 另请参阅

- [FEATURES_zh.md](./FEATURES_zh.md) - 详细的功能列表和语言支持
- [DEVELOP_zh.md](./DEVELOP_zh.md) - 开发指南和配置结构
