# 独立插件配置

此目录保留 `configs.*` 模块命名空间，由完整模式的 `lua/configs/init.lua` 在插件初始化后加载；Lite 模式不执行这些初始化。

- `plugin_cfg/`：Firenvim 全局选项与 UI 接口初始化
- `language_cfg/`：按缓冲区触发的语言配置与 DAP 公共初始化
- `language_cfg/toolchain/`：DAP 适配器
- `language_cfg/languages/`：语言调试启动配置

DAP 公共初始化成功后才设置完成标记，每种语言的回调执行一次。变更这一流程时运行 `TEST_FILE=tests/unit/performance.lua make test`。

所有文件通过 `.hotpot.fnl` 和 `make build` 编译到缓存。不得在原 `lua/configs/` 子目录保留同名 Lua 配置，以免遮蔽编译结果。
