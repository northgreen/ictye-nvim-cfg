# 端到端测试框架（基于 denops.vim testutil）

对**真实用户配置**（`~/.config/nvim/init.lua`，本仓库）做端到端测试： 启动真实 Neovim 实例（不使用
`--clean`），通过 MessagePack RPC 检查键位映射、LSP 和启动模式。

## 为什么不是 denops_test / denocy

`denops_test` 使用 `nvim --clean` 启动，不加载用户配置；`denocy` 锁定的 unknownutil/denops_std
版本存在问题。本框架基于 **denops.vim v8 自带的 testutil** 维护本地适配：Neovim 内通过 `jobstart`
启动 `cli.ts`（Deno RPC 转发进程）， 连接外部 `testHost` 的监听器，经 MessagePack RPC 通道与 Neovim
通信，不依赖 denops 服务。

## 前置

- `deno >= 2.x`（`~/.deno/bin/deno` 或 PATH 中）
- 首次运行执行 `./setup.sh`（克隆 denops.vim 到 `vendor/`，git 忽略）

## 运行

`bufferline_test.ts` 验证合并重绘后的缓冲区添加、诊断高亮和删除。Lua 插件级回归统一走
`mini.test`，在仓库根目录运行
`TEST_FILE=tests/unit/performance.lua nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'`，检查单次初始化、重绘合并及到期刷新、返回值保留和幂等安装。

```bash
cd tests/e2e
deno test -A --config deno.jsonc scenarios/          # 全部（串行，~30s）
deno test -A --config deno.jsonc scenarios/lsp_test.ts   # 单个
deno test -A --config deno.jsonc scenarios/perf_lsp_test.ts   # 性能场景
```

## 架构

### C# 诊断回归（可选，2026）

指定已还原依赖、Roslyn 可加载的真实项目源码文件：

```bash
NVIM_ROSLYN_TEST_FILE=/absolute/path/to/Project/File.cs deno test -A --config deno.jsonc scenarios/roslyn_test.ts
```

不设置变量时跳过。测试等待项目初始化，验证退出插入模式不额外发起诊断请求，
并在内存中添加未知类型、确认诊断出现、恢复原内容并确认诊断消失；不保存源码。
这不是大型项目持续负载的性能验收。

```
tests/e2e/
├── setup.sh            # 克隆 denops.vim → vendor/
├── deno.jsonc          # 导入映射：/denops-private/、/denops-testutil/ → vendor/
├── with_config.ts      # 启动加载用户配置的 Neovim 及 RPC 宿主
├── util.ts             # lua()/waitForLua()/waitForPlugins()/waitFor() + 性能测量辅助
├── fixtures/           # 测试用源码文件（lua/、typescript/）
│   └── lua/.luarc.json # 限定 lua_ls 工作区根目录（否则通过 .git 找到仓库根）
└── scenarios/
    ├── startup_test.ts     # 完整模式：配置加载、lazy、配色方案、无致命错误
    ├── keymap_test.ts      # <leader>q、jj、<C-x>f 实际存在
    ├── lsp_test.ts         # 打开 .lua 文件，LSP 附加及 documentSymbol 响应
    ├── lite_test.ts        # --cmd "let g:lite_mode=v:true" 轻量启动
    ├── perf_startup_test.ts # 完整/轻量启动计时（进程创建→RPC = 配置加载 + 框架启动）
    ├── perf_lsp_test.ts    # Lua：LSP 附加、文档符号、悬停和编辑计时
    └── perf_ts_test.ts     # TypeScript（vtsls + typescript-tools）：附加、文档符号和编辑
```

## 性能场景（perf_*）

用 nvim 内 `vim.loop.hrtime()`（纳秒级）+ rpc 侧 `Date.now()` 计时，输出测量值并做
宽松的合理性断言（防回归，不设严格阈值）：

- **perf_startup_test**：`spawn→rpc`（= 配置加载 + cli.ts 启动）与 `rpc→lazy`（lazy 就绪）
  两个时间点；轻量模式必须明显快于完整模式（相对断言）。
- **perf_lsp_test / perf_ts_test**：LSP 附加延迟（`LspAttach` 自动命令 + `hrtime`）、
  `documentSymbol` / `hover` 请求响应（`client:request`，可指定客户端）、逐字符编辑 300 次。

参考基线（2026-07，无界面运行）：完整模式 332ms / 轻量模式 162ms；Lua 附加约 400ms（null-ls
先响应）、 文档符号约 870ms、悬停约 3–9ms、编辑约 14ms/300 字符；TypeScript 附加约
1s（typescript-tools）、 文档符号约 2s、编辑约 28ms/300
字符。此基线用于参考，不代表当前环境实测结果。

### lua_ls 工作区根目录限制（重要）

`lua_ls` 的 `root_markers` 含 `.git`，在配置仓库内打开 Lua 文件时，工作区根目录会成为
**整个仓库**，`documentSymbol` 等请求会挂起（超过 30 秒无响应）。在测试样例目录放置 `.luarc.json`
固定根目录。**日常在仓库内编辑 Lua 文件也可能遇到此问题**： 若文档结构请求卡住，检查 `:LspInfo`
的工作区根目录。

## 关键机制

- **加载用户配置**：`with_config.ts` 去掉 testutil 的 `--clean`；`runtimepath` 保持默认 即加载
  `~/.config/nvim`。
- **轻量模式**：必须用 `--cmd` 设置 `g:lite_mode`（在 vimrc 之前执行）； `-c` 在 vimrc
  之后执行，太晚。
- **Lua 求值**：一律 `luaeval`（`nvim_exec_lua` 不能经 `nvim_call_function` 调）； `luaeval`
  只接受表达式，副作用须包装为立即调用的函数表达式。
- **msgpack nil → deno null**：轮询条件写 Lua 表达式（`vim.g.x ~= nil`）， 不要用 `!== undefined`
  判断。
- **勿阻塞主循环**：LSP 请求用 `vim.lsp.buf_request`（异步）+ 轮询， 不要 `buf_request_sync`（会与
  rpc 通道死锁）。
- **指定客户端的 LSP 请求**：Neovim 0.12 的 `vim.lsp.buf_request` 无 `client_id` 变体 （签名
  `(bufnr, method, params, handler, on_unsupported)`），指定 client 用
  `client:request(method, params, handler, bufnr)`。多客户端时 `buf_request` 发给
  所有声明支持该方法的客户端（null-ls 常声明全部能力，会先响应并覆盖结果）。
- **控制键序列化**：`nvim_get_keymap` 的 lhs 中 `<C-x>f` 序列化为字面量 `<C-X>f`。

## 注意

- 测试会在 nvim 里加载**完整用户配置**（含 AI 插件、网络请求），单测约 4s。
- 不要在轻量模式测试里执行 `:Lazy update`（会用轻量插件规格重写 `lazy-lock.json`）。
- 测试失败时 nvim 可能残留：`pkill -f 'cli.ts'` 前先 `ps` 确认是自己的进程。
