# 只包装项目现有入口；不下载依赖、不在源码目录生成或删除 Lua。
NVIM ?= nvim
DENO ?= deno
export TEST_FILE MINI_TEST_PATH HOTPOT_PATH

.DEFAULT_GOAL := help
.PHONY: help all build compile check test test-unit test-run test-host test-e2e e2e-setup

help:
	@printf '%s\n' \
	  'Neovim 配置工具入口' \
	  '  make build       Hotpot 增量编译到 .hotpot.fnl 配置的缓存目录' \
	  '  make test        mini.test 单元回归（不加载个人配置、不联网）' \
	  '  make test TEST_FILE=tests/unit/kitty_terminal.lua  单文件回归' \
	  '  make test-host   单元回归 + 真实 Kitty 界面集成（需要桌面环境）' \
	  '  make e2e-setup   安装 E2E 的 denops.vim 依赖（需要网络）' \
	  '  make test-e2e    真实用户配置 E2E（需先运行 e2e-setup）' \
	  '覆盖工具路径：NVIM=... DENO=...' \
	  '覆盖插件路径：MINI_TEST_PATH=... HOTPOT_PATH=...'

all build compile:
	$(NVIM) --headless --noplugin -u NONE -l scripts/build.lua

# 测试直接使用仓库模块，不依赖 Fennel 构建或旧的 nvim-test。
check test test-unit test-run:
	$(NVIM) --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'

test-host:
	TEST_HOST=1 $(NVIM) --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'

e2e-setup:
	bash tests/e2e/setup.sh

test-e2e:
	cd tests/e2e && $(DENO) test -A --config deno.jsonc scenarios/
