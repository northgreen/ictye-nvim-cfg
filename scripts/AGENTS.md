# 工具脚本

- `build.lua`：由 `make build` 调用，通过 Hotpot 编译 Fennel 缓存
- `pref2speedscope.py`：性能采样格式转换
- `neoghidra_export.py`：由 Ghidra PyGhidra Headless 作为 post-script 执行，不能用普通 Python 直接分析二进制

NeoGhidra 导出脚本只传输插件视图需要的数据，Java 值需显式转为 Python 值后编码 JSON。导出错误使用带相同标记的错误对象，Neovim 端将其作为失败处理；反编译器必须在 `finally` 中释放。

外部入口列表可能含数据符号；入口选择优先 `processEntry` 调用约定对应的函数，其次使用代码入口或首个函数。入口选择的纯 Python 回归为 `python3 tests/unit/neoghidra_export.py`。
