-- 固定迁移前快照；只模拟外部边界，不启动插件或执行安装命令。
local MiniTest = require("mini.test")
local T = MiniTest.new_set()
local eq = MiniTest.expect.equality
local root = vim.fn.getcwd()
local fixture = root .. "/tests/fixtures/plugin_specs.json"
local hotpot = vim.env.HOTPOT_PATH
if not hotpot or hotpot == "" then
  hotpot = vim.fn.stdpath("data") .. "/lazy/hotpot.nvim"
end
vim.opt.runtimepath:append(hotpot)
local fennel = require("hotpot.fennel")
local scenarios = {
  { name = "linux", win = 0, term = "KITTY", llm = "avnate" },
  { name = "windows", win = 1, term = "WINTERM", llm = "opencode" },
  { name = "embedded", win = 0, term = "KITTY", embedded = true, llm = "none" },
  { name = "gui-lite", win = 0, term = "KITTY", gui = true, lite = true, llm = "avnate" },
}

local function module_name(name)
  return (name:gsub("^plugin%.require", "plugins.require"))
end

-- 编号键和字符串键分别保存，避免 JSON 对混合 Lua 表的有损编码。
local function normalize(value, seen)
  local kind = type(value)
  if kind == "nil" then
    return { kind = "nil" }
  end
  if kind == "function" then
    return { kind = "function" }
  end
  if kind == "string" then
    return module_name(value)
  end
  if kind ~= "table" then
    return value
  end
  local meta = getmetatable(value)
  if meta and meta.mock_path then
    return { mock = meta.mock_path }
  end
  seen = seen or {}
  assert(not seen[value], "快照遇到循环表")
  seen[value] = true
  local keys, entries = {}, {}
  for key in pairs(value) do
    keys[#keys + 1] = key
  end
  table.sort(keys, function(a, b)
    if type(a) == type(b) then
      return a < b
    end
    return type(a) < type(b)
  end)
  for _, key in ipairs(keys) do
    entries[#entries + 1] = { key, normalize(value[key], seen) }
  end
  seen[value] = nil
  return { entries = entries }
end

local function sandbox(scenario, migrated)
  local calls, proxies = {}, {}
  local function record(name, ...)
    calls[#calls + 1] = { name, normalize({ n = select("#", ...), ... }) }
  end
  local function proxy(path)
    if proxies[path] then
      return proxies[path]
    end
    local object = setmetatable({}, {
      mock_path = path,
      __index = function(_, key)
        return proxy(path .. "." .. tostring(key))
      end,
      __newindex = function(self, key, value)
        record(path .. "." .. tostring(key) .. "=", value)
        rawset(self, key, value)
      end,
      __call = function(_, ...)
        record(path, ...)
        return proxy(path .. "()")
      end,
      __tostring = function()
        return path
      end,
      __concat = function(a, b)
        return tostring(a) .. tostring(b)
      end,
    })
    proxies[path] = object
    return object
  end
  local env = setmetatable({}, { __index = _G })
  env._G = env
  env.options = {
    env = { os = { win = scenario.win }, term = scenario.term },
    env_var = { firenvim = scenario.embedded or false, vscode = scenario.embedded or false },
    llm_config = { use_plugin = scenario.llm },
    keymaps = { exit = "<Esc>" },
    ui = {
      symbal_map = { Function = "F", Class = "C" },
      indent = "indent-blankline",
      nav_option = { sparator = " / " },
      dapui = { autoopen = not scenario.lite, autoclose = not scenario.lite },
    },
  }
  env.vim = {
    g = {
      started_by_firenvim = scenario.embedded,
      neovide = scenario.gui,
      GUI = scenario.gui,
      lite_mode = scenario.lite,
    },
    env = { TERM = scenario.term == "KITTY" and "xterm-kitty" or "xterm", HOME = "/home/test" },
    fn = proxy("vim.fn"),
    api = proxy("vim.api"),
    keymap = proxy("vim.keymap"),
    bo = proxy("vim.bo"),
    wo = proxy("vim.wo"),
    o = proxy("vim.o"),
    opt = proxy("vim.opt"),
    w = proxy("vim.w"),
    b = proxy("vim.b"),
    lsp = proxy("vim.lsp"),
    treesitter = proxy("vim.treesitter"),
    diagnostic = proxy("vim.diagnostic"),
    log = { levels = { INFO = 2, WARN = 3, ERROR = 4 } },
    schedule = function(callback)
      record("vim.schedule", callback)
    end,
    defer_fn = function(callback, delay)
      record("vim.defer_fn", callback, delay)
    end,
    list_extend = vim.list_extend,
    tbl_extend = vim.tbl_extend,
    tbl_deep_extend = vim.tbl_deep_extend,
    deepcopy = vim.deepcopy,
    split = vim.split,
    trim = vim.trim,
    inspect = vim.inspect,
    fs = { dirname = vim.fs.dirname, joinpath = vim.fs.joinpath },
    cmd = proxy("vim.cmd"),
    notify = proxy("vim.notify"),
    ui = proxy("vim.ui"),
  }
  rawset(env.vim.fn, "stdpath", function(kind)
    return "/test/" .. kind
  end)
  rawset(env.vim.fn, "has", function(feature)
    return feature == "win32" and scenario.win or 0
  end)
  rawset(env.vim.fn, "executable", function()
    return 1
  end)
  env.print = function(...)
    record("print", ...)
  end
  env.os = {
    getenv = function(name)
      return name == "HOME" and "/home/test" or nil
    end,
  }
  local stubs = {
    ["util.functions"] = {
      three_way_compare = function(test, yes, no)
        if test then
          return yes
        else
          return no
        end
      end,
    },
    ["global.ui_util.ascii_arts"] = { each = { { "fixture header" } } },
    ["colorful-menu"] = {
      blink_highlights = function(ctx)
        record("colorful-menu.blink_highlights", ctx)
        if scenario.lite then
          return nil
        end
        return { label = "highlighted", highlights = { { 0, 1, group = "Kind" } } }
      end,
    },
    ["obsidian.api"] = {
      path_is_note = function(path)
        record("obsidian.path_is_note", path)
        return not scenario.lite
      end,
      resolve_image_path = function(src)
        record("obsidian.resolve_image_path", src)
        return "/vault/" .. src
      end,
    },
  }
  local multicursor = proxy("require:multicursor-nvim")
  rawset(multicursor, "cursorsEnabled", function()
    return not scenario.lite
  end)
  rawset(multicursor, "addKeymapLayer", function(callback)
    record("multicursor.addKeymapLayer", callback)
    callback(function(modes, key, action)
      record("multicursor.layerSet", modes, key, action)
      if key == "<esc>" then
        action()
      end
    end)
  end)
  stubs["multicursor-nvim"] = multicursor
  local dap = proxy("require:dap")
  rawset(dap, "adapters", {})
  rawset(dap, "configurations", scenario.lite and { cs = { { name = "existing configuration" } } } or {})
  stubs.dap = dap
  env._test_dap = dap
  env._test_autocmds = {}
  rawset(env.vim.api, "nvim_create_autocmd", function(events, opts)
    record("vim.api.nvim_create_autocmd", events, opts)
    env._test_autocmds[#env._test_autocmds + 1] = opts.callback
    return #env._test_autocmds
  end)
  rawset(env.vim.ui, "input", function(opts, callback)
    record("vim.ui.input", opts, callback)
    callback(opts.default or "4242")
  end)
  env.require = function(name)
    assert(not migrated or not name:match("^plugin%.require"), "迁移后仍引用旧模块：" .. name)
    name = module_name(name)
    record("require", name)
    return stubs[name] or proxy("require:" .. name)
  end
  return env, calls
end

local function read_source(path)
  assert(vim.fn.filereadable(path) == 1, "缺少迁移模块：" .. path)
  return table.concat(vim.fn.readfile(path), "\n")
end

local probes = {
  ["require/ui/bufferline.fnl"] = function(spec)
    return {
      {
        spec.opts.options.numbers,
        {
          ordinal = 3,
          id = 7,
          raise = function(id)
            return "^" .. id
          end,
        },
      },
    }
  end,
  ["require/ui/nvim_navic.fnl"] = function(spec)
    return { { spec.opts.format_text, "symbol text" } }
  end,
  ["require/ui/dressing_nvim.fnl"] = function(spec)
    return { { spec.opts.input.override, { width = 42 } }, { spec.opts.select.builtin.override, { height = 12 } } }
  end,
  ["require/tool/snacks.fnl"] = function(spec)
    local conceal = spec.opts.image.doc.conceal
    return {
      { conceal, "latex", "math" },
      { conceal, "markdown", "text" },
      { spec.opts.image.resolve, "/note.md", "image.png" },
    }
  end,
  ["require/language/language_tool/bink-cmp.fnl"] = function(spec)
    local label = spec.opts.completion.menu.draw.components.label
    return {
      { label.text, { label = "hello", label_matched_indices = { 0, 2 } } },
      { label.highlight, { label = "hello", label_matched_indices = { 0, 2 } } },
    }
  end,
  ["require/tool/ai/opencode.fnl"] = function(spec, env)
    spec.config()
    return { { env.vim.g.opencode_opts.server.start } }
  end,
  ["language_cfg/languages/c_cpp/c_cpp_config.fnl"] = function(_, env)
    return { { env._test_dap.configurations.cpp[1].program } }
  end,
  ["language_cfg/languages/fsharp/fsharp_config.fnl"] = function(_, env)
    return { { env._test_dap.configurations.fsharp[1].program } }
  end,
  ["language_cfg/toolchain/debug/unity_debugger/init.fnl"] = function(_, env)
    return {
      {
        function()
          local adapter, config = nil, {}
          env._test_dap.adapters.unity(function(value)
            adapter = value
          end, config)
          return { adapter = adapter, config = config }
        end,
      },
    }
  end,
  ["language_cfg/init.fnl"] = function(_, env)
    return {
      {
        function()
          for _, ft in ipairs({ "c", "cpp", "c", "fs", "php", "text" }) do
            rawset(env.vim.bo, 1, { filetype = ft })
            env._test_autocmds[1]({ buf = 1 })
          end
        end,
      },
    }
  end,
}

local function evaluate(path, scenario, migrated)
  local source = read_source(path)
  if migrated then
    source = fennel["compile-string"](source, { filename = path })
  end
  local chunk = assert(loadstring(source, "@" .. path))
  local env, calls = sandbox(scenario, migrated)
  setfenv(chunk, env)
  local result = chunk()
  return result, env, calls
end

local function globals(env)
  return normalize({
    vim = env.vim.g,
    nvim_bufferline = rawget(env, "nvim_bufferline"),
    smear_cursor = rawget(env, "smear_cursor"),
    configured = rawget(env, "configured"),
    dap = { adapters = env._test_dap.adapters, configurations = env._test_dap.configurations },
  })
end

local function snapshot(path, scenario, migrated, target)
  local result, env, calls = evaluate(path, scenario, migrated)
  local snapshot = { value = normalize(result), calls = calls, globals = globals(env) }
  snapshot.callbacks = {}
  for _, key in ipairs(type(result) == "table" and { "opts", "init", "config", "build" } or {}) do
    if type(result[key]) == "function" then
      local spec, callback_env, callback_calls = evaluate(path, scenario, migrated)
      local opts = type(spec.opts) == "table" and vim.deepcopy(spec.opts) or { event_handlers = {} }
      local returned = spec[key](spec, opts)
      -- Lazy 只消费 opts 的返回值；config/init/build 的末表达式返回值没有行为含义。
      snapshot.callbacks[key] = {
        value = key == "opts" and normalize(returned) or false,
        opts = normalize(opts),
        calls = callback_calls,
        globals = globals(callback_env),
      }
    end
  end
  for suffix, make_probes in pairs(probes) do
    if (target or path):gsub("%.lua$", ".fnl"):sub(-#suffix) == suffix then
      local spec, probe_env, probe_calls = evaluate(path, scenario, migrated)
      local outputs = {}
      for _, probe in ipairs(make_probes(spec, probe_env)) do
        outputs[#outputs + 1] = normalize(probe[1](unpack(probe, 2)))
      end
      snapshot.probes = { outputs = outputs, calls = probe_calls }
    end
  end
  return snapshot
end

local baseline = vim.json.decode(table.concat(vim.fn.readfile(fixture), "\n"))
assert(baseline.version == 1, "不支持的 plugin_specs 快照版本")
for _, item in ipairs(baseline.modules) do
  for _, scenario in ipairs(scenarios) do
    T[item.path .. " [" .. scenario.name .. "]"] = function()
      eq(snapshot(root .. "/" .. item.path, scenario, true), item.scenarios[scenario.name])
    end
  end
end

T["所有 plugins Fennel 文件均能编译，原 Lua 模块没有残留"] = function()
  for _, directory in ipairs({ "plugins", "configs/plugin_cfg", "configs/language_cfg", "global/agents" }) do
    for _, path in ipairs(vim.fn.glob(root .. "/fnl/" .. directory .. "/**/*.fnl", false, true)) do
      fennel["compile-string"](read_source(path), { filename = path })
    end
  end
  for _, directory in ipairs({ "plugin", "configs/plugin_cfg", "configs/language_cfg", "global/agents" }) do
    eq(vim.fn.glob(root .. "/lua/" .. directory .. "/**/*.lua", false, true), {})
  end
end

return T
