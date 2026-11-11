-- 验证各规格自身禁用；真实 Lazy 合并器不会启动或安装插件。
local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality
local data = vim.fn.stdpath("data")
vim.opt.runtimepath:append(vim.env.HOTPOT_PATH or (data .. "/lazy/hotpot.nvim"))
vim.opt.runtimepath:append(data .. "/lazy/lazy.nvim")
local fennel = require("hotpot.fennel")
local Spec = require("lazy.core.plugin").Spec
local Config = require("lazy.core.config")
local previous_options
local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      previous_options = Config.options
      Config.options = vim.deepcopy(Config.defaults)
    end,
    post_case = function()
      Config.options = previous_options
    end,
  },
})
local paths = {
  "tool/cppinsights",
  "language/language_tool/tree_sitter_norg",
  "editor/auto_pairs",
  "tool/carbon-now",
  "ui/codewindow",
  "editor/lua_utils",
  "editor/neorg",
  "ui/neoscrool",
  "tool/nvim_rip_substitute",
  "editor/unity",
  "editor/orgmode",
  "editor/pathlib",
  "language/language_tool/tree_sitter_norg_meta",
  "tool/floaterm",
}
local function load_specs()
  local result = {}
  for _, path in ipairs(paths) do
    local file = "fnl/plugins/require/" .. path .. ".fnl"
    local code = fennel.compileString(table.concat(vim.fn.readfile(file), "\n"), { filename = file })
    local env = setmetatable({
      require = function(name)
        eq(name, "core.keymap")
        return { cppinsights = {}, rip_substitute = {} }
      end,
    }, { __index = _G })
    local spec = setfenv(assert(loadstring(code)), env)()
    eq(spec.enabled, false)
    result[#result + 1] = spec
  end
  return result
end
T["all fourteen plugin definitions carry enabled=false"] = function()
  eq(#load_specs(), 14)
end
T["per-plugin disabling overrides dependency inclusion"] = function()
  local specs = load_specs()
  local parent = { "test/retained-plugin", dependencies = {} }
  for _, spec in ipairs(specs) do
    local name = spec.name or Spec.get_name(spec[1])
    parent.dependencies[#parent.dependencies + 1] = "test/" .. name
  end
  local parsed = Spec.new({ parent, specs }, { pkg = false })
  eq(#parsed.notifs, 0)
  eq(parsed.plugins["retained-plugin"] ~= nil, true)
  for _, spec in ipairs(specs) do
    local name = spec.name or Spec.get_name(spec[1])
    eq(parsed.plugins[name], nil)
    eq(parsed.disabled[name] ~= nil, true)
  end
end
return T
