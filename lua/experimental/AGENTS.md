# Lua 实验模块

本目录存放手动启用的实验代码，不是单元测试目录。`init.lua` 当前不自动加载实验；验证脚本位于
`tests/unit/`。

## Kitty 协议桥接

加载 `kitty_test.lua` 会安装幂等的 `TermRequest`/`TermResponse` 处理器，通过 `nvim_ui_send` 桥接
Kitty 字符串协议，包括图形 APC、远程控制 DCS 和部分私有 OSC。可用命令为
`KittyPassthroughStatus`、`KittyPassthroughStop`；调用 `require('experimental.kitty_test').setup()`
可重新启用。

图形使用按缓冲区隔离的宿主图片 ID 和放置
ID。上传与放置分离，防止终端在分块上传期间隐藏后画到其他分屏。放置锚定源缓冲区单元格，单元格列转换为
UTF-8 字节偏移；定位考虑窗口侧栏、隐藏视图、滚动和窗口变化。显式指定 `c/r`
的放置超出分屏边界时隐藏，避免覆盖旁边窗口。停用、终端关闭和缓冲区销毁都会移除所属宿主图片。

此桥接不提供完全透明的终端协议透传。CSI 键盘协商和 OSC52 仍由 Neovim
处理。图片编号寻址（`I=`）、虚拟/相对放置、任意删除几何、自动尺寸图片裁剪、动画感知重绘和 OSC66
单元格预留尚不完整。OSC
通知、剪贴板、颜色和指针效果作用于整个宿主终端，不局限于分屏。部分响应没有唯一关联
ID；跨缓冲区归属不明时丢弃，不广播。不能将本实验视为运行不可信终端程序的沙箱。

## 桥接验证

单元回归使用 `mini.test`，跑全部集合：

```sh
nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
```

只跑一个文件（桥接用例包含真实子 PTY 和注入的宿主响应）：

```sh
TEST_FILE=tests/unit/kitty_passthrough.lua nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
```

真实 Kitty 的终端界面用例位于 `tests/integration/kitty_host.lua`，默认不收集，显式运行：

```sh
TEST_HOST=1 nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
```

该集合自行启动 `kitten @ launch` 的独立窗口，以进程退出码和解析后的结果断言；驱动脚本仍是
`tests/unit/kitty_passthrough_host.lua`（结果写到 `$KITTY_TEST_RESULT` 或
`/tmp/kitty-passthrough-host.json`）和 `tests/unit/kitty_terminal_host.py`（JSON 与截图写到
`/tmp/kitty-lua-terminal-host-*`）。缺少 Kitty 或截图工具时用例失败，不静默跳过。桥接集合验证 Kitty
响应、发出的放置坐标和截图像素；终端界面驱动必须返回主输入循环，阻塞式 `vim.wait()`
会妨碍及时处理宿主响应。

Neovim 0.12 的 `:h TermRequest` 中，`sequence` 不包含单独提供的 `terminator`，也不存在
`data.type`。不要假定载荷末尾含 ST 而直接截去字节。非首个图形分块可能只含 `m`/`q`（动画帧还可含
`a=f`），须保持这些字节不变。2026 年实验参考：https://sw.kovidgoyal.net/kitty/graphics-protocol/

## Lua 自管终端

`kitty_terminal/init.lua` 提供自管终端。`global.ui_util.ui.float_term`
在打开浮窗时加载并使用此模块，命令退出后自动关闭浮窗，手动关闭时释放会话和子进程。也可执行
`:lua require('experimental.kitty_terminal')` 后，使用 `:KittyLuaTerm` 启动交互式 shell，或使用
`:KittyLuaTerm <shell command>` 执行命令。输入使用原生终端模式：`Ctrl-\ Ctrl-N`
返回终端普通模式，`i`/`a` 恢复输入。`:KittyLuaTermStatus`
显示尺寸、任务状态和错误，`:KittyLuaTermStop` 停止当前会话。

原始子进程通过 `jobstart({pty=true})` 的字节模式连接；Lua 流式 ANSI/UTF-8
解析器和网格维护协议状态并回复查询。显示使用 `nvim_open_term` 创建的真正 `terminal`
缓冲区：普通文本和 ANSI 送入内部通道，原始 Kitty 包和本地查询不直接送入。Neovim
提供终端单元格、高亮、`on_input` 原生输入、粘贴、普通模式历史回看，以及
`TermOpen`/`TermEnter`/`TermLeave`/`TermClose` 事件。不安装全局 `vim.on_key` 监听器，也不覆盖
`vim.paste`。

原始 PTY 为 `b:kitty_lua_job`，独立内部显示通道为 `b:kitty_lua_view_channel`，其
`nvim_get_chan_info` 返回 `mode=terminal`、`internal=true`。Neovim 0.12.6 的内部终端缓冲区 `channel`
选项仍为零，不能据此判断它是普通临时缓冲区。

单元格/像素尺寸查询、光标报告、键盘模式栈、调色板和能力响应均以子视口为准。Linux
上通过就绪握手，在执行客户端前设置全部四个 `TIOCSWINSZ` 字段；未修改的 icat
要求内核像素尺寸非零。宿主单元格像素尺寸来自实际 Kitty TTY 的 ioctl。辅助模块位于
`kitty_terminal/`，细节见其 `AGENTS.md`。独立命令需手动加载，浮窗会按需加载；本目录 `init.lua`
不自动加载此模块。

Kitty 像素数据交给宿主，图片 ID
和视口放置在本地管理。完整分块上传在一次宿主写入中提交；图片按源像素裁剪到分屏，稳定行 ID
保证滚动回看时锚点不变。隐藏视图仅移除放置，不丢弃像素数据。默认 OSC52
剪贴板读取返回空值；明确可信的会话可调用
`require('experimental.kitty_terminal').open({allow_clipboard_read=true})` 授权。

## 自管终端验证

在仓库根目录按文件运行（每份文件返回 `mini.test` 测试集，由报告器汇总结果）：

```sh
TEST_FILE=tests/unit/kitty_terminal_screen.lua nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
TEST_FILE=tests/unit/kitty_terminal_protocol.lua nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
TEST_FILE=tests/unit/kitty_terminal.lua nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
TEST_HOST=1 nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
```

`TEST_HOST=1` 依赖支持 `kitten @ screenshot` 的 Kitty
远程控制、ImageMagick、`~/.desktop-backgrounds/bk-bk.png` 和 `terminal-browser`，由
`tests/integration/kitty_host.lua` 调用
`python3 tests/unit/kitty_terminal_host.py`。测试自行创建并关闭 Kitty
系统窗口，仅加载本地内联页面。JSON 和截图保存在新的 `/tmp/kitty-lua-terminal-host-*` 目录。另由
`tests/unit/kitty_keyboard_host.py` 验证 Kitty
编码的按下/重复/松开传输、双会话切换、失焦和隐藏窗口清理，产物位于
`/tmp/kitty-keyboard-host-*`；此回归不抢用户焦点。覆盖真实
icat、图片像素、分屏缩放、隐藏恢复、滚动回看、输入释放、原生 Neovim
鼠标/键盘事件，以及仅收到精确文本 `hello-lua` 才变绿的页面；同时验证默认交互式 shell
执行命令并正常退出。持续动画检查通过 Kitty 自身的帧缓冲截图采样 30
帧，不依赖桌面遮挡状态，确认动画确实变化且稳定页面像素不露出背景。

本实现仍是实验性模拟器，不保证完整 VT/Kitty 一致性：原始 8 位 C1、缩放后的段落重排、DEC
特殊图形字符集、Unicode 虚拟/相对图片放置、替代键信息和任意 OSC66
尺寸尚不完整。按键释放通过按需创建的本地 Kitty 隐藏输入窗口回传，需要远控及
python3；未建立通道时不宣称支持松键事件。Neovim
输入精度为单元格，像素鼠标报告使用格心位置。私有宿主颜色、通知、远控协议可能影响整个终端。PTY 像素
ioctl 仅支持 Linux，不能由两个真实客户端测试推断通用兼容性。
