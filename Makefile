FENNEL := /usr/bin/fennel

# Test dependencies
DEPDIR ?= .test-deps
CURL ?= curl -sL --create-dirs

# Platform detection
ifeq ($(shell uname -s),Darwin)
    ARCH ?= macos-arm64
else
    ARCH ?= linux-x86_64
endif

# Optional: Download nvim binary (only when NVIM_VERSION is explicitly set)
ifdef NVIM_VERSION
NVIM := $(DEPDIR)/nvim-$(ARCH)
NVIM_BIN := $(NVIM)/bin/nvim
else
NVIM_BIN ?= $(shell which nvim)
endif

# nvim-test framework
NVIM_TEST := $(DEPDIR)/nvim-test

# Source files: fnl/ all .fnl, excluding *macros.fnl
FNLS := $(shell find fnl -name '*.fnl' ! -name '*macros.fnl' -type f)
# Source files: after/ all .fnl
FNLS_AFTER := $(shell find after -name '*.fnl' -type f)

# Targets: fnl/xxx.fnl -> lua/xxx.lua
LUAS := $(FNLS:fnl/%.fnl=lua/%.lua)
# after/xxx.fnl -> after/xxx.lua (in-place)
LUAS_AFTER := $(FNLS_AFTER:.fnl=.lua)

.DEFAULT_GOAL := all

.PHONY: all clean clean-deps check watch status compile help
.PHONY: test test-check test-run
.PHONY: nvim nvim-test-dep

# ============================================================================
# Compilation
# ============================================================================

all: $(LUAS) $(LUAS_AFTER)

# fnl/ -> lua/ (create dir + compile)
lua/%.lua: fnl/%.fnl
	@mkdir -p $(dir $@)
	$(FENNEL) --compile $< > $@

# after/ -> after/ (atomic write)
after/%.lua: after/%.fnl
	$(FENNEL) --compile $< > $@.tmp && mv $@.tmp $@

# ============================================================================
# Dependency downloads
# ============================================================================

nvim: $(NVIM)

$(NVIM):
	mkdir -p $(DEPDIR)
	$(CURL) https://github.com/neovim/neovim/releases/download/$(NVIM_VERSION)/nvim-$(ARCH).tar.gz | \
		tar -xz -C $(DEPDIR) && mv $(DEPDIR)/nvim-* $(NVIM)

nvim-test-dep: $(NVIM_TEST)

$(NVIM_TEST):
	git clone --depth 1 --branch v1.2.0 \
		https://github.com/lewis6991/nvim-test $@

# ============================================================================
# Tests
# ============================================================================

test-check: all
	@echo "Checking Lua syntax..."
	@fail=0; \
	for f in $(LUAS) $(LUAS_AFTER); do \
		if ! luac -p "$$f" 2>/dev/null; then \
			echo "  [FAIL] $$f"; fail=1; \
		fi; \
	done; \
	if [ $$fail -eq 0 ]; then \
		echo "All $$(( $(words $(LUAS)) + $(words $(LUAS_AFTER)) )) Lua files syntax OK"; \
	else \
		exit 1; \
	fi

test-run: $(NVIM_TEST) all
	@PARSLEY_PATH="$(CURDIR)/.test-deps/parsley/lua/?.lua;$(CURDIR)/.test-deps/parsley/lua/?/init.lua"; \
	$(NVIM_TEST)/bin/nvim-test tests \
		--lpath="$(CURDIR)/lua/?.lua;$$PARSLEY_PATH" \
		--verbose

test: test-check test-run
	@echo "All tests passed"

# ============================================================================
# Utility targets
# ============================================================================

clean:
	rm -f $(LUAS) $(LUAS_AFTER)

clean-deps:
	rm -rf $(DEPDIR)

check:
	@missing=""; \
	for f in $(FNLS) $(FNLS_AFTER); do \
		lua="$$(echo $$f | sed 's|^fnl/|lua/|;s|\.fnl$$|.lua|')"; \
		[ ! -f "$$lua" ] && missing="$$missing $$f"; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "Missing compiled outputs:"; \
		for m in $$missing; do echo "  $$m"; done; \
		exit 1; \
	else \
		echo "All $$(( $(words $(FNLS)) + $(words $(FNLS_AFTER)) )) files compiled"; \
	fi

watch:
	@which inotifywait >/dev/null 2>&1 || { echo "Error: inotifywait not found. Install: sudo apt install inotify-tools"; exit 1; }
	@echo "Watching for changes... (Ctrl+C to stop)"
	inotifywait -m -r -e modify,create,delete --format '%w%f' fnl/ after/ 2>/dev/null | \
	while read -r file; do \
		case "$$file" in \
			*.fnl) \
				echo "$$file" | grep -q 'macros\.fnl$$' && continue; \
				if [ -f "$$file" ]; then \
					echo "[compile] $$file"; \
					$(MAKE) compile FILE="$$file" 2>&1 || echo "[error] Failed to compile $$file"; \
				fi; \
			;; \
		esac; \
	done

status:
	@total=$$(($(words $(FNLS)) + $(words $(FNLS_AFTER)))); \
	compiled=0; \
	for f in $(FNLS) $(FNLS_AFTER); do \
		lua="$$(echo $$f | sed 's|^fnl/|lua/|;s|\.fnl$$|.lua|')"; \
		[ -f "$$lua" ] && compiled=$$((compiled + 1)); \
	done; \
	echo "Fennel files: $$total | Compiled: $$compiled | Not compiled: $$((total - compiled))"

compile:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile FILE=fnl/foo.fnl"; exit 1; fi
	@if [ ! -f "$(FILE)" ]; then echo "File not found: $(FILE)"; exit 1; fi
	@luapath="$$(echo "$(FILE)" | sed 's|^fnl/|lua/|;s|\.fnl$$|.lua|')"; \
	echo "$(FILE)" | grep -q '^after/' && luapath="$$(echo "$(FILE)" | sed 's|\.fnl$$|.lua|')"; \
	mkdir -p $$(dirname "$$luapath"); \
	$(FENNEL) --compile $(FILE) > "$$luapath" 2>&1 && echo "[ok] $(FILE) → $$luapath" || { rm -f "$$luapath" && exit 1; }

help:
	@echo "NVLIME Fennel Build"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Compile all Fennel files (default)"
	@echo "  clean      - Remove all compiled .lua files"
	@echo "  check      - Verify all .fnl files have corresponding .lua"
	@echo "  status     - Show compilation statistics"
	@echo "  watch      - Watch for changes and auto-compile (requires inotify-tools)"
	@echo "  compile    - Compile a single file (e.g. make compile FILE=fnl/foo.fnl)"
	@echo "  test       - Run all tests (luac syntax check + nvim-test)"
	@echo "  test-check - Check Lua syntax of all compiled files"
	@echo "  test-run   - Run nvim-test functional tests in tests/"
	@echo "  clean-deps - Remove downloaded dependencies (.test-deps/)"
	@echo "  help       - Show this help"
