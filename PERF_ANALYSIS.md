# Neovim 配置性能分析报告

> 日期：2026-07-31 · 环境：Neovim 0.12.4，Linux，headless 实测（每项 3 次取稳定值）

## 一、启动性能

**headless 启动到 NVIM STARTED：224ms**

| 阶段 | 耗时 | 占比 |
|---|---|---|
| init.lua 配置加载（env_init + options + lazy.setup + start 插件） | ~199ms | **89%** |
| Vim runtime（filetype/syntax 等） | ~25ms | 11% |

start 阶段插件（启动时同步加载，非懒加载）：

| 插件 | 耗时 |
|---|---|
| mcphub.nvim | 13.8ms |
| conjure + cmp-conjure | 17.9ms |
| translate.nvim | 5.0ms |
| tree-sitter-manager.nvim | 3.8ms |
| blink.cmp | 2.3ms |
| gitsigns.nvim | 2.1ms |

其余 100+ 插件均为懒加载。注意：224ms 是纯 headless 无文件值；真实带 UI + 打开文件时，懒加载插件在 BufEnter/VimEnter 触发，感知启动约 1 秒（含 LSP 启动）。

## 二、Lite 模式

**修复前无法启动**，根因两个：
1. `lua/lite_init.lua:4` 写的是 `ploadmodule 'plugin'`（单数），实际模块是 `plugins`（复数，`fnl/plugins/init.fnl`）——且该模块返回带 `.setup()` 方法的 table，只 require 不调用则 lazy 从未初始化。
2. 连锁问题：lazy 未 setup → 插件未加载 → `core/vimconfig.lua` 的 `colorscheme catppuccin-nvim` 失败。

**✅ 已修复**（2026-07-31）：`lite_init.lua` 改为 `local plugins = ploadmodule 'plugins'` + `plugins.setup()`。修复后实测启动 **40.4ms**（full 模式 224ms 的 1/5.5），加载 im-select/catppuccin/nvim-treesitter/undotree 四个轻量插件，colorscheme 正常。

## 三、26 种语言/项目类型性能

测试方法：headless 打开各语言最小项目文件，测量 LSP attach 耗时（启动到 server 就绪）、documentSymbol 响应（结构同步负载）、编辑响应（插入 300 字符）。

| 语言 | LSP server | attach | documentSymbol | 编辑300插入 | 评价 |
|---|---|---|---|---|---|
| GDScript | gdscript | **8622ms** ⚠️ | 超时 | 1.2ms | 启动灾难 |
| CMake | cmake | **4730ms** ⚠️ | 超时 | 0.8ms | 启动灾难 |
| PowerShell | powershell_es | **2885ms** ⚠️ | 5ms | 1.4ms | 启动慢 |
| C# | roslyn | **1700ms** ⚠️ | 2ms | 0.9ms | 启动慢 |
| Lua | lua_ls | 1076ms | **202ms** ⚠️ | 1.3ms | 结构响应慢 |
| Bash | bashls | 1033ms | 1ms | 0.5ms | 启动偏慢 |
| Clojure | clojure-lsp | 744ms | 2ms | 1.1ms | 正常 |
| Go | gopls | 364ms | 1ms | 1.1ms | 良好 |
| TypeScript | vtsls | 321ms | **1099ms** ⚠️⚠️ | **3.7ms** ⚠️ | 结构+编辑最差 |
| JSON | jsonls | 258ms | 4ms | 1.1ms | 良好 |
| Rust | rust-analyzer | 243ms | 4ms | 1.3ms | 良好 |
| Fennel | fennel_ls | 115ms | **超时** ⚠️ | 0.8ms | server 不支持 documentSymbol |
| C++ | clangd | 109ms | 1ms | 0.8ms | 优秀 |
| Vue | emmet_ls | 78ms | 异常(n=-1) | 1.3ms | vue_ls 未 attach |
| CSS | emmet_ls | 69ms | 2ms | 0.8ms | 正常 |
| QML | qmlls | 40ms | 3ms | 1.1ms | 优秀 |
| C | clangd | 39ms | 1ms | 1.2ms | 优秀 |
| XML | lemminx | 51ms | 1ms | 1.4ms | 优秀 |
| Python | ruff | 78ms | 23ms | 0.8ms | 快（ruff 极轻量） |

**无 LSP 支持（attach 超时）**：F#（配置 bug，见下）、Ruby（solargraph 未装）、Haskell（HLS 未装）、GLSL（glslls 未装）、AutoHotkey（autohotkey_lsp 未装）、Common Lisp（conjure 走 REPL，无 LSP，属预期）。

**共性结论**：编辑响应全部 ≤1.4ms（TS 3.7ms 除外）——treesitter 同步解析不是瓶颈（SYNTAX_SYNC 全部 0ms）。性能分化完全在 LSP server 本身，与配置关系不大。

## 四、定位到的真实问题

1. **🔴 F# 支持失效（已修复）**：`lsp/fsautocomplete.lua` 的 `root_dir` 用 `vim.fs.find({'*.fsproj','*.sln','.git'}, ...)` 找项目根。但 Neovim 0.12 的 `vim.fs.find` **不支持 glob 通配符**（文档明确：“paths and globs are not supported”），`*.fsproj` 永远匹配不到 → root 退化为 `.` → RootUri 变成 `file://.` → fsautocomplete 抛 `UriFormatException` 初始化崩溃。
   **✅ 已修复**：root_dir 改为手动向上搜索（`vim.fn.glob` 匹配 `*.fsproj`/`*.sln`，`vim.fn.isdirectory` 检查 `.git`）。修复后实测 fsautocomplete 正常 attach（3385ms）。
2. **🟠 Lite 模式损坏（已修复）**（见上）。
3. **🟠 启动时警告**：`[null-ls] failed to load builtin eslint for method diagnostics`——none-ls 的 eslint source 加载失败，TS/JS 的 none-ls 诊断不可用。
4. **🟠 ts_ls 与 vtsls 冲突**：`core/lsp.lua` 同时 Enable 了 `ts_ls` 和 `vtsls`（同一 filetype），实测并发时 ts_ls 稳定不 attach。功能重叠且浪费资源——vtsls 的 tsserver 实测内存占用高达 1.7GB（残留进程实测）。*(已提交修复：禁用 ts_ls)*
5. **🟡 vue_ls/cssls/pyright 偶发不 attach**：批量测试中缺失，单独重测正常——并发启动多个 LSP server 时部分启动失败的偶发问题。
6. **🟡 GDScript/CMake/PowerShell LSP 启动需 3-9 秒**：server 本身慢，打开对应项目会有明显等待。

## 五、优化建议

| 优先级 | 建议 | 预期收益 | 状态 |
|---|---|---|---|
| 1 | 修复 F# root_dir（改 `vim.fn.glob` 或精确文件名向上搜索） | 恢复 F# 支持 | ✅ 已修复 |
| 2 | 修复 lite 模式两个 bug | 恢复 lite 模式 | ✅ 已修复 |
| 3 | `ts_ls`/`vtsls` 二选一（建议 vtsls，功能更全） | 省内存 ~1GB+、消除 attach 竞争 | ✅ 已提交（禁用 ts_ls） |
| 4 | 修 none-ls eslint source（装 eslint 或改配置） | 消除启动警告，恢复 JS/TS 非 LSP 诊断 | 待办 |
| 5 | init.lua 的 199ms 主体是 env_init（含 git clone 检查、lazy-rocks 初始化）+ options 加载 | 约 50-100ms 可优化空间 | 待办 |
| 6 | Vue 场景确认 vue_ls 为何未 attach | 恢复 Vue 完整智能 | 待办 |

## 附：测试脚本

位于 `/tmp/perftest2/`（lang_test.sh 单语言测试 + run_all.sh 批量）。可复跑复现所有数据。
