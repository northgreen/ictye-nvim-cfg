local MiniTest = require("mini.test")
local T = MiniTest.new_set()
local eq = MiniTest.expect.equality
local data = vim.fn.stdpath("data")
vim.opt.runtimepath:append(vim.env.HOTPOT_PATH or (data .. "/lazy/hotpot.nvim"))
local fennel = require("hotpot.fennel")
local function load_spec(path, dependency)
  local code = fennel.compileString(table.concat(vim.fn.readfile(path), "\n"), { filename = path })
  return setfenv(assert(loadstring(code)), setmetatable({ require = dependency }, { __index = _G }))()
end
T["Blink defers Minuet access until options are evaluated"] = function()
  local calls = 0
  local mapping = { "minuet_complete" }
  local spec = load_spec("fnl/plugins/require/tool/ai/bink-mcp-avante.fnl", function(name)
    eq(name, "minuet")
    calls = calls + 1
    return {
      make_blink_map = function()
        return mapping
      end,
    }
  end)
  eq(calls, 0)
  eq(vim.tbl_contains(spec.dependencies, "milanglacier/minuet-ai.nvim"), true)
  local opts = spec.opts({}, { signature = { enabled = true }, keymap = { preset = "default" } })
  eq(calls, 1)
  eq(opts.keymap["<A-y>"], mapping)
  eq(opts.keymap.preset, "default")
  eq(opts.signature.enabled, true)
  eq(vim.tbl_contains(opts.sources.default, "luasnip"), false)
  eq(vim.tbl_contains(opts.sources.default, "snippets"), true)
end
T["hawtkeys dependencies are a list of repository names"] = function()
  local spec = load_spec("fnl/plugins/require/ui/hawtkeys.fnl", function(name)
    error("spec parsing must not load " .. name)
  end)
  eq(spec.dependencies, { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" })
end
T["Nvlime uses Blink rather than the disabled nvim-cmp integration"] = function()
  local opts = load_spec("fnl/plugins/config/nvlime.fnl", function(name)
    error("configuration must not load " .. name)
  end)
  eq(opts.cmp.enabled, false)
  eq(opts.blink.enabled, true)
  local blink = load_spec("fnl/plugins/require/language/language_tool/bink-cmp.fnl", function(name)
    error("spec parsing must not load " .. name)
  end)
  eq(blink.opts.sources.providers.nvlime.module, "nvlime.blink")
  eq(vim.tbl_contains(blink.opts.sources.default, "nvlime"), true)
end
return T
