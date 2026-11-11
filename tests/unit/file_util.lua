local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality
vim.opt.runtimepath:append(vim.env.HOTPOT_PATH or (vim.fn.stdpath("data") .. "/lazy/hotpot.nvim"))
local fennel = require("hotpot.fennel")
local source = table.concat(vim.fn.readfile("fnl/util/file_util.fnl"), "\n")
local scan = fennel.eval(source, { filename = "fnl/util/file_util.fnl" }).scan_dir_for_module
local directory
local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      directory = vim.fn.tempname()
      vim.fn.mkdir(directory .. "/nested/deep", "p")
      for _, name in ipairs({ "init.lua", "z.lua", "nested/init.lua", "nested/a.lua", "nested/deep/b.lua" }) do
        vim.fn.writefile({ "error('scanner must not execute modules')" }, directory .. "/" .. name)
      end
      for _, name in ipairs({ "ignored.fnl", "ignored.lua.bak", "ignored.txt" }) do
        vim.fn.writefile({}, directory .. "/" .. name)
      end
    end,
    post_case = function()
      vim.fn.delete(directory, "rf")
    end,
  },
})
T["nested modules and init use the supplied namespace"] = function()
  eq(
    scan(directory, "configs"),
    { "configs", "configs.nested", "configs.nested.a", "configs.nested.deep.b", "configs.z" }
  )
end
T["empty namespace omits the root init and leading dots"] = function()
  eq(scan(directory, ""), { "nested", "nested.a", "nested.deep.b", "z" })
end
T["empty directories return an empty list"] = function()
  vim.fn.mkdir(directory .. "/empty")
  eq(scan(directory .. "/empty", "configs"), {})
end
T["results are fresh on every invocation"] = function()
  local first = scan(directory, "")
  first[1] = "modified"
  eq(scan(directory, "")[1], "nested")
end
T["directory symlink loops are not followed"] = function()
  if vim.fn.has("win32") == 1 then
    MiniTest.skip("creating symlinks may require Windows privileges")
  end
  assert(vim.uv.fs_symlink(directory, directory .. "/nested/loop", { dir = true }))
  eq(scan(directory, ""), { "nested", "nested.a", "nested.deep.b", "z" })
end

T["explicit Fennel extension ignores Lua and backup files"] = function()
  vim.fn.writefile({}, directory .. "/init.fnl")
  vim.fn.writefile({}, directory .. "/nested/item.fnl")
  vim.fn.writefile({}, directory .. "/nested/item.fnl.bak")
  eq(scan(directory, "specs", ".fnl"), { "specs", "specs.ignored", "specs.nested.item" })
end

local function plugin_module(config_root)
  local code = fennel.compileString(table.concat(vim.fn.readfile("fnl/plugins/init.fnl"), "\n"))
  local env = setmetatable({
    vim = {
      fs = vim.fs,
      fn = {
        stdpath = function(kind)
          eq(kind, "config")
          return config_root
        end,
      },
    },
    require = function(name)
      eq(name, "util.file_util") -- Scanning must not execute plugin specs or Lazy setup.
      return { scan_dir_for_module = scan }
    end,
  }, { __index = _G })
  return setfenv(assert(loadstring(code)), env)()
end

T["plugin imports skip aggregate entrypoints and preserve namespaces"] = function()
  local specs = directory .. "/fnl/plugins/require"
  vim.fn.mkdir(specs .. "/editor", "p")
  for _, name in ipairs({ "init.fnl", "lite_require.fnl", "editor/init.fnl", "editor/pairs.fnl", "theme.fnl" }) do
    vim.fn.writefile({ "(error :must-not-execute)" }, specs .. "/" .. name)
  end
  vim.fn.writefile({}, specs .. "/ignored.lua")
  local get_spec = plugin_module(directory).get_spec
  local expected = {
    { import = "plugins.require.editor" },
    { import = "plugins.require.editor.pairs" },
    { import = "plugins.require.theme" },
  }
  eq(get_spec(), expected)
  eq(get_spec(), expected)
end

T["actual plugin directory produces deferred imports"] = function()
  local specs = plugin_module(vim.fn.getcwd()).get_spec()
  eq(#specs > 0, true)
  for _, spec in ipairs(specs) do
    eq(spec.import:match("^plugins%.require%.") ~= nil, true)
    eq(spec.import == "plugins.require.lite_require", false)
  end
end
return T
