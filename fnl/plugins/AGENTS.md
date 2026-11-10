# 插件规格与预加载配置

本目录使用 Fennel 描述 lazy.nvim 插件，包括当前启用和保留但未启用的规格。不要在 `lua/plugin/`
中维护平行实现，也不要在 Fennel 内嵌 Lua 字符串。

## 入口与加载顺序

- `init.fnl`：先调用 `plugins.config.setup`，再按 Full/Lite 模式调用 `lazy.setup`
- `require/init.fnl`：完整模式的有序插件规格列表
- `require/lite_require.fnl`：轻量模式的插件规格列表，保留独立的 Treesitter 选择
- `config/`：预加载全局选项与规格 `config` 回调调用的本地兼容模块；`config/init.fnl`
  只汇总预加载部分

规格模块使用 `plugins.require.*` 命名空间。与目录同名的模块使用目录内的 `init.fnl`。插件自己的 Lua
模块名（例如 `require :bufferline`）不受配置文件语言影响。

## 独立配置边界

`fnl/configs/` 保存完整模式在插件初始化后加载的独立配置；`fnl/global/agents/` 保存 ACP
提供商配置。核心键位、通用工具函数、LSP 定义与实验模块保留各自的目录和实现语言。

## 校验

`make build` 使用已安装的 Hotpot 编译到缓存，不将生成的 Lua 写回源码目录。`make test` 运行
mini.test；插件规格专项回归使用 `TEST_FILE=tests/unit/plugin_specs.lua make test`。

保留 `enabled`、`cond`、事件、依赖顺序和初始化时机。Fennel 函数隐式返回末表达式；原本没有返回值的
Lua 回调需要显式以 `nil` 结束。非标准全局通过 `_G` 访问，以通过 Hotpot 严格全局检查。

## NeoGhidra

`require/neoghidra.fnl` 通过 `config/neoghidra/init.fnl` 将分析入口接到 Ghidra 官方
`support/pyghidraRun -H`，使用仓库的 `scripts/neoghidra_export.py` 导出视图数据。不修改 lazy
下载目录中的插件实现。

`config/neoghidra/views.fnl` 修正加载阶段的只读状态：加载文字写入前暂时清除 `readonly`，仍由
`nomodifiable`
阻止编辑，结果写入后由原加载器恢复双重保护。同一路径复用有效视图缓冲区，不同路径以摘要后缀区分同名文件；加载时清除旧地址映射，双向切换不重复创建同名缓冲区。

运行环境需要 PyGhidra 与 JPype，使用 Ghidra 自己的虚拟环境。Ghidra 12.1.2_DEV 的 Linux 环境位于
`~/.config/ghidra/ghidra_12.1.2_DEV/venv`；可使用受支持的 Python 3.12 创建该环境，并通过
`uv pip install --python <venv>/bin/python <ghidra_path>/Ghidra/Features/PyGhidra/pypkg/dist/pyghidra-3.1.0-py3-none-any.whl`
安装发行版自带的 PyGhidra 及依赖，不安装到系统 Python。升级 Ghidra
时按对应发行版的用户环境与自带包重新核对。

项目路径不能包含以 `.` 开头的目录，规格使用 `~/GhidraProj`。退出码为 0 仍需验证独占行 JSON
标记和结果字段；失败日志写入项目目录的 `<binary>_<hash>.neoghidra.log`，失败结果不缓存。Linux
环境需要 GNU coreutils 的 `timeout`：`analysis_timeout` 限制分析阶段与整个进程组，超时先发送 TERM，2
秒后仍未退出则发送 KILL，避免遗留 Python/JVM 与项目锁。

专项回归：`TEST_FILE=tests/unit/neoghidra.lua make test`，无需启动 Ghidra。Python
入口选择测试由该套件调用，只依赖标准库。
