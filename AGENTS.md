# AGENTS.md
目的
- 本文档记录助手对本 Neovim 配置仓库所做的操作与相关上下文。
- 更新策略：只追加的日志，不删除、不改写历史；每条记录包含日期和简明描述。

禁止在此文件记载项目或者决策历史

## 项目概览

个人 Neovim 配置（约位于 ~/.config/nvim），采用模块化架构，支持：
- **双模式系统**：完整模式（默认）与 Lite 模式（启动更快）
- **AI 集成**：通过 avante.nvim 支持多个提供商（OpenAI、GitHub Models、SiliconFlow）
- **LSP/DAP**：20+ 语言服务器，含调试与测试支持
- **跨平台**：针对 Linux、macOS、Windows 优化

新模块或者补丁偏好使用fennel

## 开发命令

### 启动 Neovim
```bash
nvim                    # 完整模式（全部插件）
nvim --cmd "let g:lite_mode=v:true"  # Lite 模式（最小化）
```

### 校验配置
```bash
nvim --headless -c "lua vim.health ~= nil and vim.health.check() or vim.cmd('checkhealth')" -c "q" 2>&1
```

### E2E 测试（真实用户配置）
```bash
./tests/e2e/setup.sh   # 首次运行：把 denops.vim 克隆到 tests/e2e/vendor/
export PATH=$HOME/.deno/bin:$PATH
cd tests/e2e && deno test -A --config deno.jsonc scenarios/
```
框架基于 denops.vim v8 自带 testutil（cli.ts rpc 转发 + Neovim host），启动**真实用户配置**的 nvim 做断言。共 8 个测试（~30s）：4 个功能场景（startup/keymap/lsp/lite）+ 3 个性能场景（perf_startup：full/lite 启动计时；perf_lsp：Lua attach/documentSymbol/hover/编辑；perf_ts：TS 同样四项）+ lsp_test。性能场景用 nvim 内 hrtime 纳秒级计时，测量值即回归信号。坑：lua_ls root_markers 含 .git，仓库内 fixture 需 `.luarc.json` 钉住 workspace 根，否则 documentSymbol 挂起。详见 `tests/e2e/README.md`。

### Neovim 内部命令
| 命令 | 说明 |
|------|------|
| `:Lazy` | 插件管理器界面 |
| `:Mason` | 安装 LSP 服务器、格式化工具、DAP |
| `:LspInfo` | 查看 LSP 服务器状态 |
| `:TSUpdate` | 更新 Tree-sitter 解析器 |
| `:checkhealth` | 诊断问题 |
| `:ConfigEdit <type>` | 编辑配置文件（nvim） |
| `:OverseerRun` | 运行任务 |
| `:OverseerToggle` | 开关任务面板 |

## 架构

### 入口
- `init.lua` - 主入口，引导 lazy.nvim 并选择模式
- `lua/full_init.lua` - 完整模式初始化
- `lua/lite_init.lua` - Lite 模式初始化

### 核心分层
| 层 | 用途 |
|----|------|
| `lua/core/` | 设置、LSP、键位映射、自动命令 |
| `lua/options/` | Neovim 选项配置 |
| `lua/plugin/` | 插件规格（lazy.nvim） |
| `lua/global/` | LSP capabilities、UI 工具 |
| `lua/util/` | 共享工具（键位、函数） |
| `lsp/*.lua` | 按语言划分的 LSP 服务器配置 |
| `tests/e2e/` | E2E 测试框架（denops testutil + 真实用户配置） |

### 插件加载
插件在 `lua/plugin/require/require.lua` 中声明，按类别组织：
- `ui/` - 主题、状态栏、bufferline、edgy
- `tool/` - telescope、git、overseer、AI 工具（avante、opencode、claude）
- `editor/` - surround、pairs、trouble、which-key
- `language/` - LSP、DAP、补全、treesitter、blink.cmp

## 键位映射

所有键位映射定义在 `lua/core/keymap/init.lua`：

## 添加新功能

### 添加新插件
1. 在 `lua/plugin/init.lua` 中添加插件规格
2. 在合适的 `lua/plugin/require/` 子目录中创建配置文件
3. 在 `lua/plugin/require/require.lua` 中添加 require

### 添加新 LSP 服务器
1. 通过 Mason 安装：`:MasonInstall <server>`
2. 在 `lua/core/lsp.lua` 中通过 `vim.lsp.enable('<server>')` 启用
3. 按需添加自定义设置

### 添加新键位映射
1. 编辑 `lua/core/keymap/init.lua`，或在 `lua/core/keymap/` 下新建文件
2. 使用 `vim.keymap.set()`，复杂映射用 Hydra

## 限制

- 依赖外部工具：Neovim 0.9+、Git、Node.js、各语言工具链
- 完整清单见 DEVELOP.md 的 Dependencies 章节

## 模式切换

运行时在完整模式与 Lite 模式之间切换：
```lua
-- 切换完整模式（重载配置）
:lua vim.g.lite_mode = not vim.g.lite_mode; source $MYVIMRC
```
