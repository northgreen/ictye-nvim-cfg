# E2E 测试框架（基于 denops.vim testutil）

对**真实用户配置**（`~/.config/nvim/init.lua`，本仓库）做端到端测试：
启动真实 nvim 实例（不 `--clean`），通过 msgpack-rpc 断言 keymap、LSP、启动模式。

## 为什么不是 denops_test / denocy

调研结论（详见会话记录）：`denops_test` 用 `nvim --clean` 启动（不加载用户配置）；
`denocy` 锁定的 unknownutil/denops_std 版本是坏的。本框架 fork 了 **denops.vim v8 自带
testutil**：nvim 内 `jobstart` 一个 `cli.ts`（deno rpc 转发进程）连外部 testHost 的
listener，经 messagepack-rpc channel 与 nvim 通信——不依赖 denops 服务。

## 前置

- `deno >= 2.x`（`~/.deno/bin/deno` 或 PATH 中）
- 首次运行执行 `./setup.sh`（克隆 denops.vim 到 `vendor/`，git 忽略）

## 运行

```bash
cd tests/e2e
deno test -A --config deno.jsonc scenarios/          # 全部（串行，~30s）
deno test -A --config deno.jsonc scenarios/lsp_test.ts   # 单个
deno test -A --config deno.jsonc scenarios/perf_lsp_test.ts   # 性能场景
```

## 架构

```
tests/e2e/
├── setup.sh            # 克隆 denops.vim → vendor/
├── deno.jsonc          # import map：/denops-private/、/denops-testutil/ → vendor/
├── with_config.ts      # 启动「加载用户配置」的 nvim + rpc host
├── util.ts             # lua()/waitForLua()/waitForPlugins()/waitFor() + 性能测量辅助
├── fixtures/           # 测试用源码文件（lua/、typescript/）
│   └── lua/.luarc.json # 限定 lua_ls workspace 根（否则以 .git 向上到仓库根）
└── scenarios/
    ├── startup_test.ts     # full 模式：配置加载、lazy、colorscheme、无致命错误
    ├── keymap_test.ts      # <leader>q、jj、<C-x>f 实际存在
    ├── lsp_test.ts         # 打开 .lua 文件，LSP attach + documentSymbol 响应
    ├── lite_test.ts        # --cmd "let g:lite_mode=v:true" 轻量启动
    ├── perf_startup_test.ts # full/lite 启动计时（spawn→rpc = 配置加载 + 框架启动）
    ├── perf_lsp_test.ts    # Lua：LSP attach / documentSymbol / hover / 编辑计时
    └── perf_ts_test.ts     # TS（vtsls + typescript-tools）：attach / documentSymbol / 编辑
```

## 性能场景（perf_*）

用 nvim 内 `vim.loop.hrtime()`（纳秒级）+ rpc 侧 `Date.now()` 计时，输出测量值并做
宽松 sanity 断言（防回归，不做严格阈值）：

- **perf_startup_test**：`spawn→rpc`（= 配置加载 + cli.ts 启动）与 `rpc→lazy`（lazy 就绪）
  两个时间点；lite 必须明显快于 full（相对断言）。
- **perf_lsp_test / perf_ts_test**：LSP attach 延迟（`LspAttach` autocmd + hrtime）、
  documentSymbol / hover 请求响应（`client:request`，可指定 client）、逐字符编辑 300 次。

已知基线（2026-07，headless）：full 332ms / lite 162ms；Lua attach≈400ms（null-ls 先）、
documentSymbol≈870ms、hover≈3-9ms、编辑≈14ms/300字符；TS attach≈1s（typescript-tools）、
documentSymbol≈2s、编辑≈28ms/300字符（唯一明显慢的编辑）。

### lua_ls workspace 坑（重要）

`lua_ls` 的 root_markers 含 `.git`——在配置仓库内打开 lua 文件时 workspace 根是
**整个仓库**，documentSymbol 等请求会挂起（>30s 无响应）。fixture 目录里放一个
`.luarc.json` 把 root 钉在 fixture 目录。**用户日常在仓库根编辑 lua 文件也会遇到**：
若 lua_ls 文档结构请求卡住，检查 `:LspInfo` 的 workspace 根。

## 关键机制

- **加载用户配置**：`with_config.ts` 去掉 testutil 的 `--clean`；`runtimepath` 保持默认
  即加载 `~/.config/nvim`。
- **lite 模式**：必须用 `--cmd` 设置 `g:lite_mode`（在 vimrc 之前执行）；
  `-c` 在 vimrc 之后执行，太晚。
- **Lua 求值**：一律 `luaeval`（`nvim_exec_lua` 不能经 `nvim_call_function` 调）；
  `luaeval` 只接受表达式，副作用包 IIFE。
- **msgpack nil → deno null**：轮询条件写 Lua 表达式（`vim.g.x ~= nil`），
  不要用 `!== undefined` 判断。
- **勿阻塞主循环**：LSP 请求用 `vim.lsp.buf_request`（异步）+ 轮询，
  不要 `buf_request_sync`（会与 rpc 通道死锁）。
- **指定 client 的 LSP 请求**：nvim 0.12 的 `vim.lsp.buf_request` 无 client_id 变体
  （签名 `(bufnr, method, params, handler, on_unsupported)`），指定 client 用
  `client:request(method, params, handler, bufnr)`。多 client 时 `buf_request` 发给
  所有声明支持该方法的 client（null-ls 常声明全部能力，会先响应并覆盖结果）。
- **控制键序列化**：`nvim_get_keymap` 的 lhs 中 `<C-x>f` 序列化为字面量 `<C-X>f`。

## 注意

- 测试会在 nvim 里加载**完整用户配置**（含 AI 插件、网络请求），单测约 4s。
- 不要在 lite 模式测试里执行 `:Lazy update`（会用 lite spec 重写 lazy-lock.json）。
- 测试失败时 nvim 可能残留：`pkill -f 'cli.ts'` 前先 `ps` 确认是自己的进程。
