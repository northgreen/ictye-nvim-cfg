# 插件规格与预加载配置

本目录使用 Fennel 描述 lazy.nvim 插件，包括当前启用和保留但未启用的规格。不要在 `lua/plugin/` 中维护平行实现，也不要在 Fennel 内嵌 Lua 字符串。

## 入口与加载顺序

- `init.fnl`：先调用 `plugins.config.setup`，再按 Full/Lite 模式调用 `lazy.setup`
- `require/init.fnl`：完整模式的有序插件规格列表
- `require/lite_require.fnl`：轻量模式的插件规格列表，保留独立的 Treesitter 选择
- `config/`：需要在 `lazy.setup` 前设置的插件全局选项

规格模块使用 `plugins.require.*` 命名空间。与目录同名的模块使用目录内的 `init.fnl`。插件自己的 Lua 模块名（例如 `require :bufferline`）不受配置文件语言影响。

## 独立配置边界

`fnl/configs/` 保存完整模式在插件初始化后加载的独立配置；`fnl/global/agents/` 保存 ACP 提供商配置。核心键位、通用工具函数、LSP 定义与实验模块保留各自的目录和实现语言。

## 校验

`make build` 使用已安装的 Hotpot 编译到缓存，不将生成的 Lua 写回源码目录。`make test` 运行 mini.test；插件规格专项回归使用 `TEST_FILE=tests/unit/plugin_specs.lua make test`。

保留 `enabled`、`cond`、事件、依赖顺序和初始化时机。Fennel 函数隐式返回末表达式；原本没有返回值的 Lua 回调需要显式以 `nil` 结束。非标准全局通过 `_G` 访问，以通过 Hotpot 严格全局检查。
