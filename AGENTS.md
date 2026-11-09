# AGENTS.md
- 本文档记录助手对本 Neovim 配置仓库所做的操作与相关上下文。

禁止在此文件记载项目或者决策历史

## 项目概览

个人 Neovim 配置（约位于 ~/.config/nvim），采用模块化架构，支持：
- **双模式系统**：完整模式（默认）与 Lite 模式（启动更快）
- **AI 集成**：通过 avante.nvim 支持多个提供商（OpenAI、GitHub Models、SiliconFlow）
- **LSP/DAP**：20+ 语言服务器，含调试与测试支持
- **跨平台**：针对 Linux、macOS、Windows 优化

新模块或者补丁偏好使用fennel

测试可以使用mini.test

twc一般是require('util.functions').three_way_compare的缩写而不是一个全局函数

不使用与模块目录同名的lua文件而是使用`init.lua`

## 风格指南

### fennel

- 匿名函数使用`λ`代替`fn`
- 模块的写法往往采用在最后直接表达列表而不是像lua那样先定义M再返回

## 开发命令

### Makefile 入口

`make` 默认显示帮助；`make build` 使用已安装的 Hotpot 和 `.hotpot.fnl` 增量编译缓存，不加载个人配置、不下载依赖。`HOTPOT_PATH` 可覆盖插件目录。`make test` 运行 mini.test，支持 `TEST_FILE`、`MINI_TEST_PATH`；`make test-host` 加入真实 Kitty 集成。`make e2e-setup` 显式安装 E2E 依赖，`make test-e2e` 运行真实配置 E2E。工具路径可通过 `NVIM`、`DENO` 覆盖。无源码目录清理目标，避免删除手写 Lua。

### 启动 Neovim
```bash
nvim                    # 完整模式（全部插件）
nvim --cmd "let g:lite_mode=v:true"  # Lite 模式（最小化）
```

### 校验配置
```bash
nvim --headless -c "lua vim.health ~= nil and vim.health.check() or vim.cmd('checkhealth')" -c "q" 2>&1
```

### 导出运行时键位

`NVIM_KEYMAP_EXPORT=/tmp/nvim-keymaps.csv nvim` 或启动前设置 `g:keymap_export` 为路径，启用 `fnl/util/keymap_export/init.fnl` 的快照 hook。未设置时不加载模块；手动刷新命令 `:KeymapExport` 只在启用时存在。导出全局与现存 buffer-local 映射，不记录删除历史或强制加载插件；CSV 用 RFC 4180 引号转义、同目录临时文件原子替换。`python3 scripts/keymap_viewer.py INPUT.csv OUTPUT.html` 生成离线键盘浏览器。单元回归 `TEST_FILE=tests/unit/keymap_export.lua make test`，网页生成器回归 `python3 tests/unit/keymap_viewer.py`。

### 运行 Lua 单元回归（mini.test）

```bash
nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'                 # 全部
TEST_FILE=tests/unit/meow_yarn.lua nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
TEST_HOST=1 nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'    # 真实 Kitty 集成
```

`tests/minimal_init.lua` 只加载仓库与 `mini.test`，不加载个人配置；mini.nvim 不在默认位置时用 `MINI_TEST_PATH` 指定。测试文件只返回测试集，不再自行 `qa!` 或输出断言计数。

### 端到端测试（真实用户配置）
```bash
./tests/e2e/setup.sh   # 首次运行：把 denops.vim 克隆到 tests/e2e/vendor/
export PATH=$HOME/.deno/bin:$PATH
cd tests/e2e && deno test -A --config deno.jsonc scenarios/
```
框架基于 denops.vim v8 自带的 testutil（`cli.ts` 负责 RPC 转发，Neovim 作为被测宿主），启动加载**真实用户配置**的 Neovim 做断言。共 8 个测试（约 30 秒）：4 个功能场景（启动、键位、LSP、轻量模式）、3 个性能场景（完整/轻量模式启动计时，Lua 和 TypeScript 的 LSP 附加、文档符号、悬停及编辑计时）以及 `lsp_test`。性能场景使用 Neovim 内部的 `hrtime` 进行纳秒级计时，测量值用于发现回归。`lua_ls` 的 `root_markers` 含 `.git`，仓库内测试样例需要 `.luarc.json` 固定工作区根目录，否则 `documentSymbol` 请求可能挂起。详见 `tests/e2e/README.md`。

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
| `fnl/plugins/` | Fennel 插件规格、lazy.nvim 初始化与预加载配置 |
| `fnl/configs/` | Fennel 独立插件配置与语言/DAP 初始化 |
| `lua/global/` | LSP 能力配置、界面工具 |
| `lua/util/` | 共享工具（键位、函数） |
| `lsp/*.lua` | 按语言划分的 LSP 服务器配置 |
| `lua/experimental/` | 手动启用的实验模块，详见该目录的 `AGENTS.md` |
| `tests/e2e/` | 端到端测试框架（denops testutil + 真实用户配置） |

### 插件加载
插件在 `fnl/plugins/require/init.fnl` 中汇总，Lite 模式使用 `fnl/plugins/require/lite_require.fnl`。规格与内嵌回调均使用 Fennel，按类别组织：
- `ui/` - 主题、状态栏、bufferline、edgy
- `tool/` - telescope、git、overseer、AI 工具（avante、opencode、claude）
- `editor/` - surround、pairs、trouble、which-key
- `language/` - LSP、DAP、补全、treesitter、blink.cmp

## 键位映射

所有键位映射定义在 `lua/core/keymap/init.lua`：

## 添加新功能

### 添加新插件
1. 在合适的 `fnl/plugins/require/` 子目录中创建 Fennel 插件规格
2. 在 `fnl/plugins/require/init.fnl` 中添加 require，Lite 专属入口为 `lite_require.fnl`
3. 运行 `make build` 编译并检查 Hotpot 缓存

### 添加新 LSP 服务器
1. 通过 Mason 安装：`:MasonInstall <server>`
2. 在 `lua/core/lsp.lua` 中通过 `vim.lsp.enable('<server>')` 启用
3. 按需添加自定义设置

### 添加新键位映射
1. 编辑 `lua/core/keymap/init.lua`，或在 `lua/core/keymap/` 下新建文件
2. 使用 `vim.keymap.set()`，复杂映射用 Hydra

## 限制

- 依赖外部工具：Neovim 0.9+、Git、Node.js、各语言工具链
- 完整清单见 `DEVELOP.md` 的依赖项章节（原文标题为 `Dependencies`）

## 模式切换

运行时在完整模式与 Lite 模式之间切换：
```lua
-- 切换完整模式（重载配置）
:lua vim.g.lite_mode = not vim.g.lite_mode; source $MYVIMRC
```
