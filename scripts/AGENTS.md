# 工具脚本

- `build.lua`：由 `make build` 调用，通过 Hotpot 编译 Fennel 缓存
- `pref2speedscope.py`：性能采样格式转换
- `keymap_viewer.py`：将 `NVIM_KEYMAP_EXPORT` 导出的 CSV 转为离线单文件 HTML；资源位于 `keymap_viewer_assets/`，生成时内联，不依赖网络或服务器。CSV 列契约与 `fnl/util/keymap_export/init.fnl` 同步；回归入口 `python3 tests/unit/keymap_viewer.py`
- `neoghidra_export.py`：由 Ghidra PyGhidra Headless 作为 post-script 执行，不能用普通 Python 直接分析二进制

网页浏览器回归用 `KEYMAP_VIEWER_BROWSER=1 python3 tests/unit/keymap_viewer.py`，需要已安装 Python Playwright 与 `/usr/bin/chromium`；默认回归仅使用 Python 标准库，不下载浏览器。映射数据经 JSON HTML 定界符转义嵌入，页面使用 `textContent`，不要将 CSV 字段拼接为 HTML。

NeoGhidra 导出脚本只传输插件视图需要的数据，Java 值需显式转为 Python 值后编码 JSON。导出错误使用带相同标记的错误对象，Neovim 端将其作为失败处理；反编译器必须在 `finally` 中释放。

外部入口列表可能含数据符号；入口选择优先 `processEntry` 调用约定对应的函数，其次使用代码入口或首个函数。入口选择的纯 Python 回归为 `python3 tests/unit/neoghidra_export.py`。
