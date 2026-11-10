# 只包装项目现有入口；不下载依赖、不在源码目录生成或删除 Lua。
NVIM ?= nvim
DENO ?= deno
STYLUA ?= stylua
TOPIARY ?= topiary
RUFF ?= ruff
FENNEL_LS ?= fennel-ls
DENO_IGNORE := luvit-meta,.git,.jj,.claude,.opencode,.mcphub,.nvim_proj,tests/e2e/vendor,native_sources,scripts/keymap_viewer_assets/viewer.html
export TEST_FILE MINI_TEST_PATH HOTPOT_PATH

.DEFAULT_GOAL := help
.PHONY: help all build compile check test test-unit test-run test-host test-e2e e2e-setup format lint lint-format lint-fennel lint-python lint-web

help:
	@printf '%s\n' \
	  'Neovim 配置工具入口' \
	  '  make build       Hotpot 增量编译到 .hotpot.fnl 配置的缓存目录' \
	  '  make format      使用 StyLua、Topiary、Ruff、Deno 格式化工作区' \
	  '  make lint        只读格式检查 + fennel-ls、Ruff、Deno lint；不自动修复' \
	  '  make test        mini.test 单元回归（不加载个人配置、不联网）' \
	  '  make test TEST_FILE=tests/unit/kitty_terminal.lua  单文件回归' \
	  '  make test-host   单元回归 + 真实 Kitty 界面集成（需要桌面环境）' \
	  '  make e2e-setup   安装 E2E 的 denops.vim 依赖（需要网络）' \
	  '  make test-e2e    真实用户配置 E2E（需先运行 e2e-setup）' \
	  '覆盖工具路径：NVIM=... DENO=... STYLUA=... TOPIARY=... RUFF=... FENNEL_LS=...' \
	  '覆盖插件路径：MINI_TEST_PATH=... HOTPOT_PATH=...'

all build compile:
	$(NVIM) --headless --noplugin -u NONE -l scripts/build.lua

# 不处理第三方代码、HTML 模板及按内容校验信任的 .hotpot.fnl。
# 当前 Fennel grammar 不支持 patch-async.fnl 中的数值 for，保留该文件原样。
format:
	@for tool in "$(STYLUA)" "$(TOPIARY)" "$(RUFF)" "$(DENO)"; do \
	  command -v "$$tool" >/dev/null || { printf '缺少格式化工具：%s\n' "$$tool" >&2; exit 1; }; \
	done
	$(STYLUA) $(FORMAT_CHECK) --verify --indent-type Spaces --indent-width 2 --line-endings Unix init.lua after ftplugin ftdetect lsp lua plugin scripts tests -g '*.lua' -g '!tests/e2e/vendor/**'
	@set -eu; queries=$$(mktemp -d); trap 'rm -rf "$$queries"' EXIT HUP INT TERM; \
	  ln -s "$(CURDIR)/topiary/queries/fennel/formatting.scm" "$$queries/fennel.scm"; \
	  git ls-files -z --cached --others --exclude-standard -- 'fnl/*.fnl' 'plugin/*.fnl' 'lsp/*.fnl' flsproject.fnl ':!plugin/patch-async.fnl' | \
	  xargs -0 sh -c 'for file do if [ -f "$$file" ]; then printf "%s\0" "$$file"; fi; done' sh | \
	  xargs -0 env TOPIARY_LANGUAGE_DIR="$$queries" "$(TOPIARY)" format $(FORMAT_CHECK) --configuration topiary/languages.ncl
	$(RUFF) format $(FORMAT_CHECK) pref scripts tests --exclude tests/e2e/vendor
	$(DENO) fmt . $(FORMAT_CHECK) --ignore=$(DENO_IGNORE) --line-width=100 --indent-width=2

# 与 format 共用范围和排除项；-k 可在某组失败后继续检查其他语言。
lint: lint-format lint-fennel lint-python lint-web

lint-format: FORMAT_CHECK = --check
lint-format: format

# 语义检查不受 Topiary grammar 的数值 for 限制，也检查宏和 Hotpot 配置。
lint-fennel:
	@git ls-files -z --cached --others --exclude-standard -- '*.fnl' '*.fnlm' \
	  ':!luvit-meta/**' ':!tests/e2e/vendor/**' ':!.claude/**' ':!native_sources/**' | \
	  xargs -0 sh -c 'for file do if [ -f "$$file" ]; then printf "%s\0" "$$file"; fi; done' sh | \
	  xargs -0 "$(FENNEL_LS)" --config flsproject.fnl --lint

lint-python:
	$(RUFF) check pref scripts tests --exclude tests/e2e/vendor

lint-web:
	$(DENO) lint . --ignore=$(DENO_IGNORE)

# 测试直接使用仓库模块
check test test-unit test-run:
	$(NVIM) --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'

test-host:
	TEST_HOST=1 $(NVIM) --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'

e2e-setup:
	bash tests/e2e/setup.sh

test-e2e:
	cd tests/e2e && $(DENO) test -A --config deno.jsonc scenarios/
