# LSP 服务器配置

服务器配置以同名 `.fnl` 文件提供，末尾直接返回 `vim.lsp.Config` 表。使用 `λ`
声明回调，缩进为两空格。

`make build` 通过 Hotpot 编译到缓存运行时的 `lsp/*.lua`；Neovim 原生 LSP 加载器仍读取缓存中的
Lua，不直接读取 Fennel。不要在本目录保留同名手写 Lua 副本，避免两份配置参与合并。

`lua/core/lsp.lua`
管理启用的服务器；这里定义服务器启动命令、工作区发现和设置。迁移时保持异步回调、根目录选择和平台分支的行为，不顺带修改既有配置。

`make format` 包含本目录的 Fennel。修改后运行 `make build` 与 `make test`，并检查原生
`vim.lsp.config` 能发现配置。

`TEST_FILE=tests/unit/lsp_configs.lua make test` 对照迁移前固定快照检查 Linux/Windows
配置值和回调行为。`tests/fixtures/lsp_configs.json` 是原始 Lua
的基线，不要用迁移后的输出重生成来消除失败。

测试按调用方契约比较：`on_init`、`on_attach`、用户命令和异步 `root_dir` 的隐式返回值不参与比较；
根目录回调参数、请求/通知参数及有意义的返回值仍严格检查。Fennel 条件分支不能用空白代替表达式，
仅有副作用的条件执行优先用 `when`，不要为忽略返回值而添加结尾 `(values)`。
