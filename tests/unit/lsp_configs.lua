-- Immutable pre-migration oracle: generate ONLY from the original Lua directory with
-- LSP_CONFIG_BASELINE=/path/to/original LSP_CONFIG_GENERATE=1 (lua_ls uses its original .fnl).
local MiniTest = require("mini.test")
local T, eq = MiniTest.new_set(), MiniTest.expect.equality
local root = vim.fn.getcwd()
local fixture_path = root .. "/tests/fixtures/lsp_configs.json"
vim.opt.runtimepath:append(vim.env.HOTPOT_PATH or (vim.fn.stdpath("data") .. "/lazy/hotpot.nvim"))
local fennel = require("hotpot.fennel")

-- Preserve numeric keys, nil returns, and vim.NIL independently of JSON null/arrays.
local function normalize(value)
  if value == vim.NIL then
    return { kind = "vim.NIL" }
  end
  local kind = type(value)
  if kind == "nil" or kind == "function" then
    return { kind = kind }
  end
  if kind ~= "table" then
    return value
  end
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
    entries[#entries + 1] = { key, normalize(value[key]) }
  end
  return { entries = entries }
end

local function sandbox(win)
  local calls, queues = {}, { system = {}, schedule = {}, defer = {}, request = {}, exec = {} }
  local state = { filename = "/work/src/main.go", lines = {}, roots = {}, entries = {}, clients = {}, executable = 1 }
  local function record(name, ...)
    calls[#calls + 1] = { name, normalize({ n = select("#", ...), ... }) }
  end
  local function effect(name, result)
    return function(...)
      record(name, ...)
      return result
    end
  end
  local function enqueue(queue, name)
    return function(...)
      local args = { ... }
      record(name, ...)
      queues[queue][#queues[queue] + 1] = args
    end
  end
  local v = {}
  for _, name in ipairs({
    "tbl_extend",
    "tbl_deep_extend",
    "list_extend",
    "tbl_map",
    "tbl_filter",
    "tbl_isempty",
    "startswith",
    "endswith",
    "trim",
    "inspect",
    "split",
    "iter",
    "deepcopy",
  }) do
    v[name] = vim[name]
  end
  v.NIL, v.env, v.log = vim.NIL, {}, { levels = { TRACE = 0, INFO = 2, WARN = 3, ERROR = 4 } }
  v.fn = {
    stdpath = function(kind)
      return "/test/" .. kind
    end,
    has = function(feature)
      return feature == "win32" and win or (feature == "nvim-0.11.3" and state.modern ~= false and 1 or 0)
    end,
    expand = function(path)
      return (path:gsub("~", "/home/test"))
    end,
    getcwd = function()
      return "/cwd"
    end,
    getpid = function()
      return 123
    end,
    executable = function(path)
      record("executable", path)
      return state.executable
    end,
    glob = function(path)
      record("glob", path)
      return state.files and state.files[path] or ""
    end,
    isdirectory = function(path)
      record("isdirectory", path)
      return state.dirs and state.dirs[path] and 1 or 0
    end,
    setqflist = effect("setqflist"),
  }
  v.api = {
    nvim_buf_get_name = function(buf)
      record("buf_name", buf)
      return state.filename
    end,
    nvim_buf_get_lines = function(buf, first, last, strict)
      record("buf_lines", buf, first, last, strict)
      local lines = {}
      for i = first + 1, math.min(last, #state.lines) do
        lines[#lines + 1] = state.lines[i]
      end
      return lines
    end,
    nvim_get_current_buf = function()
      return 7
    end,
    nvim_get_current_win = function()
      return 9
    end,
    nvim_list_runtime_paths = function()
      return { "/test/runtime", "/test/config" }
    end,
    nvim_buf_is_loaded = function(buf)
      record("buf_loaded", buf)
      return buf == 7
    end,
    nvim_buf_create_user_command = function(buf, name, callback, opts)
      record("user_command", buf, name, callback, opts)
      state.commands[name] = callback
    end,
  }
  state.commands = {}
  v.fs = { dirname = vim.fs.dirname, joinpath = vim.fs.joinpath, parents = vim.fs.parents }
  v.fs.root = function(path, markers)
    record("fs.root", path, markers)
    if type(markers) == "function" then
      for _, name in ipairs({ "project.sln", "project.slnx", "project.csproj", "wrong.sln.bak" }) do
        record("root_predicate", name, markers(name, "/work"))
      end
    end
    state.root_index = (state.root_index or 0) + 1
    return state.roots[state.root_index] or nil
  end
  v.fs.dir = function(path)
    record("fs.dir", path)
    local i = 0
    return function()
      i = i + 1
      if state.entries[i] then
        return unpack(state.entries[i])
      end
    end
  end
  v.uv = {
    os_tmpdir = function()
      return "/test/tmp"
    end,
    fs_stat = function(path)
      record("fs_stat", path)
      return state.stats and state.stats[path]
    end,
  }
  v.notify, v.deprecate = effect("notify"), effect("deprecate")
  v.schedule, v.defer_fn, v.system =
    enqueue("schedule", "schedule"), enqueue("defer", "defer_fn"), enqueue("system", "system")
  v.cmd = setmetatable({ edit = effect("edit") }, {
    __call = function(_, ...)
      record("cmd", ...)
    end,
  })
  v.uri_from_fname = function(path)
    return "file://" .. path
  end
  v.uri_to_fname = function(uri)
    return (uri:gsub("^file://", ""))
  end
  v.uri_from_bufnr = function(buf)
    return "file:///buffer/" .. buf
  end
  v.lsp = {
    config = { powershell_es = {}, vue_ls = { cmd = { "vue-original" }, on_init = effect("vue.on_init") } },
    get_clients = function(opts)
      record("get_clients", opts)
      return state.clients[opts.name] or {}
    end,
    get_client_by_id = function(id)
      record("get_client", id)
      return state.client
    end,
    buf = { rename = effect("rename"), code_action = effect("code_action") },
    protocol = { Methods = { textDocument_diagnostic = "textDocument/diagnostic" } },
    rpc = {
      start = effect("rpc.start", { rpc = "started" }),
      connect = function(...)
        record("rpc.connect", ...)
        return effect("rpc.connected", { rpc = "connected" })
      end,
    },
    util = {
      make_text_document_params = function(buf)
        record("document_params", buf)
        return { uri = "file:///buffer/" .. buf }
      end,
      make_position_params = function(winid, encoding)
        record("position_params", winid, encoding)
        return { textDocument = { uri = "file:///source" }, position = { line = 2, character = 3 } }
      end,
      show_document = effect("show_document"),
      apply_workspace_edit = effect("apply_workspace_edit"),
      locations_to_items = effect("locations_to_items", { { text = "reference" } }),
      open_floating_preview = effect("floating_preview"),
    },
  }
  local util = {
    root_pattern = function(...)
      record("root_pattern", ...)
      return function(path)
        record("root_pattern.apply", path)
        state.root_index = (state.root_index or 0) + 1
        return state.roots[state.root_index] or nil
      end
    end,
  }
  local stubs = {
    ["global.language.capabilities"] = function(overrides)
      record("capabilities", overrides)
      return vim.tbl_deep_extend("force", { fixtureCapability = true }, overrides or {})
    end,
      ["blink.cmp"] = {
      get_lsp_capabilities = effect(
        "blink.capabilities",
        { textDocument = { completion = { fixture = true } }, fixtureCapability = true }
      ),
    },
    ["util.lsp"] = util,
  }
  local env = setmetatable({ vim = v, options = { env = { os = { win = win } } } }, { __index = _G })
  env._G = env
  env.os = {
    getenv = function()
      return nil
    end,
  }
  env.require = function(name)
    record("require", name)
    return assert(stubs[name], "unmocked dependency: " .. name)
  end
  local function client(dot_request)
    local c = {
      name = "fixture",
      offset_encoding = "utf-16",
      config = { root_dir = "/work", settings = { python = {} } },
      settings = { python = {} },
      handlers = {},
      attached_buffers = { [7] = true, [8] = true },
      server_capabilities = {
        semanticTokensProvider = { full = true },
        codeActionProvider = { codeActionKinds = { "source.fixAll", "quickfix", "source.organizeImports" } },
      },
    }
    c.notify = function(self, ...)
      assert(self == c, "notify must use colon call")
      record("client.notify", ...)
    end
    c.supports_method = function(self, method)
      assert(self == c)
      record("supports_method", method)
      return state.supported ~= false
    end
    c.request = function(...)
      local args = { ... }
      if not dot_request then
        assert(table.remove(args, 1) == c, "request must use colon call")
      end
      record("client.request", unpack(args, 1, dot_request and select("#", ...) or select("#", ...) - 1))
      queues.request[#queues.request + 1] = args[3]
    end
    c.exec_cmd = function(self, command, context, callback)
      assert(self == c, "exec_cmd must use colon call")
      record("exec_cmd", command, context, callback)
      queues.exec[#queues.exec + 1] = callback
    end
    return c
  end
  state.client = client()
  return { env = env, state = state, calls = calls, queues = queues, record = record, client = client }
end

local function load_config(name, box, baseline)
  local dir, suffix = baseline or (root .. "/lsp"), ".fnl"
  if baseline and name ~= "lua_ls" then
    suffix = ".lua"
  end
  local path = dir .. "/" .. name .. suffix
  assert(vim.fn.filereadable(path) == 1, "missing config: " .. path)
  local source = table.concat(vim.fn.readfile(path), "\n")
  if suffix == ".fnl" then
    source = fennel.compileString(source, { filename = path })
  end
  return setfenv(assert(loadstring(source, "@lsp/" .. name)), box.env)()
end

local function probe_roots(config, b, name)
  if type(config.root_dir) ~= "function" then
    return
  end
  local s, q, record = b.state, b.queues, b.record
  local function run(filename, roots)
    s.filename, s.roots, s.root_index = filename, roots, 0
    record(
      "root.return",
      config.root_dir(7, function(...)
        record("on_dir", ...)
      end)
    )
  end
  run("/work/src/main.go", { "/outer", "/near", "/nearest" })
  run("C:/work/src/main.go", { false, "/near", "/nearest" })
  run("/work/src/main.go", {})
  if name == "gopls" then
    -- No callback is completed implicitly: first roots observe empty caches.
    record("pending.system", #q.system)
    local pending = q.system
    q.system = {}
    for _, args in ipairs(pending) do
      args[3]({ code = 0, stdout = args[1][3] == "GOROOT" and " /go/root\n" or " /go/cache\n", stderr = "" })
    end
    s.clients.gopls = { { config = { root_dir = "/first" } }, { config = { root_dir = "/last" } } }
    run("/go/cache/pkg/file.go", {})
    run("/go/root/src/fmt/print.go", {})
    s.clients.gopls = {}
    run("/go/cache/pkg/file.go", { "/fallback" })
    record("cached.pending.system", #q.system)
  elseif name == "ts_ls" or name == "vtsls" then
    run("/work/a.ts", { "/same", false, "/same" }) -- equal Deno config excludes
    run("/work/a.ts", { false, "/same", "/same" }) -- equal Deno lock does not
    run("/work/a.ts", { "/far", false, "/far/near" })
    run("/work/a.ts", { false, "/far/near", "/far" })
    s.modern = false
    run("/work/a.ts", { false, false, "/legacy" })
  elseif name == "roslyn" then
    run("/tmp/MetadataAsSource/library.cs", { "/must-not-open" })
    run("/work/a.cs", { false, "/project" })
  elseif name == "fsautocomplete" then
    s.files = { ["/work/*.fsproj"] = "/work/project.fsproj" }
    run("/work/src/a.fs", {})
    s.files = { ["/work/*.sln"] = "/work/a.sln" }
    run("/work/src/a.fs", {})
    s.files, s.dirs = {}, { ["/work/.git"] = true }
    run("/work/src/a.fs", {})
  elseif name == "fennel_ls" then
    s.stats = { ["/work/flsproject.fnl"] = { type = "file" } }
    run("/work/src/a.fnl", {})
    s.stats = { ["/work/flsproject.fnl"] = { type = "directory" } }
    run("/work/src/a.fnl", { "/git" })
  else
    run("/work/a.cs", { false, false, "/third" })
  end
end

local function probe_attach(config, b, name)
  if not config.on_attach then
    return
  end
  local s, q, record = b.state, b.queues, b.record
  if name == "pyright" then
    s.client = b.client(true)
  end
  record("attach.return", config.on_attach(s.client, 7))
  record("attached.capabilities", s.client.server_capabilities)
  for _, command in ipairs(vim.fn.sort(vim.tbl_keys(s.commands))) do
    record("invoke.command", command)
    s.clients.pyright = { s.client, b.client(true) }
    s.clients.pyright[2].settings = nil
    record("command.return", s.commands[command]({ args = "/venv/python" }))
  end
  if name == "pyright" then
    for _, c in ipairs(s.clients.pyright) do
      record("python.settings", c.settings, c.config.settings)
    end
  end
  for _, callback in ipairs(q.exec) do
    callback({ message = "failure" }, nil)
    callback(nil, {})
    callback(nil, { { uri = "file:///definition", range = { start = { line = 1 }, ["end"] = { line = 2 } } } })
  end
  for i, callback in ipairs(q.request) do
    if callback then
      if name == "clangd" and i == 2 then
        callback(nil, "file:///source.h")
        callback(nil, nil)
        local ok, err = pcall(callback, "server-error", nil)
        record("switch.error", ok, tostring(err):match("server%-error$") or "unexpected")
      else
        callback({ message = "error" }, {})
        if name == "clangd" then
          callback({ message = "error" }, nil)
          callback(nil, nil)
        end
        callback(nil, {})
        callback(nil, { { name = "symbol", containerName = "namespace" } })
      end
    end
  end
  if name == "clangd" then
    s.supported = false
    for _, command in ipairs(vim.fn.sort(vim.tbl_keys(s.commands))) do
      record("unsupported.return", s.commands[command]())
    end
  end
end

local function probe_init(config, b, name)
  local s, q, record = b.state, b.queues, b.record
  if config.on_init then
    local callbacks = type(config.on_init) == "table" and config.on_init or { config.on_init }
    for _, callback in ipairs(callbacks) do
      for _, entries in ipairs({
        { { "a.slnx", "file" }, { "b.csproj", "file" } },
        { { "folder.sln", "directory" }, { "a.csproj", "file" }, { "b.csproj", "file" } },
        {},
      }) do
        s.entries = entries
        record("init.return", callback(s.client, { offsetEncoding = "utf-8" }))
      end
      record("init.absent_encoding", callback(s.client, {}))
    end
    record("init.encoding", s.client.offset_encoding)
  end
  if name ~= "vue_ls" then
    return
  end
  local handler = assert(s.client.handlers["tsserver/request"])
  local result, context = { { 42, "quickinfo", { file = "a.vue" } } }, { bufnr = 7 }
  handler(nil, result, context)
  record("vue.pending.defer", #q.defer)
  s.clients.vtsls = { b.client() }
  table.remove(q.defer, 1)[1]()
  for _, callback in ipairs(q.exec) do
    callback(nil, { body = { answer = true } })
    callback(nil, nil)
  end
  q.exec = {}
  s.clients.ts_ls, s.clients["typescript-tools"] = { b.client() }, { b.client() }
  handler(nil, result, context)
  s.clients.ts_ls, s.clients.vtsls = {}, {}
  handler(nil, result, context)
end

local function probe_handlers(config, b)
  local record, s = b.record, b.state
  for _, key in ipairs(vim.fn.sort(vim.tbl_keys(config.handlers or {}))) do
    record("handler", key)
    record(
      "handler.return",
      config.handlers[key](
        nil,
        { textDocument = { uri = "file:///rename" }, position = { line = 1, character = 2 } },
        { client_id = 4, bufnr = 7 }
      )
    )
  end
  for _, callback in ipairs(b.queues.request) do
    if callback then
      callback({ message = "restore-error" }, { { message = "restored" } })
      callback(nil, nil)
    end
  end
  for _, key in ipairs(vim.fn.sort(vim.tbl_keys(config.commands or {}))) do
    local range = { start = { line = 1 }, ["end"] = { line = 2 } }
    local args = key:match("roslyn") and { { uri = "file:///edit" }, { newText = "replacement", range = range } }
      or { "file:///references", { line = 1, character = 2 }, { { uri = "file:///reference", range = range } } }
    record("command", key)
    record(
      "configured_command.return",
      config.commands[key]({ title = "References", arguments = args }, { client_id = 4, bufnr = 7 })
    )
    if key:match("roslyn") then
      record("invalid_command.return", config.commands[key]({}, { client_id = 4 }))
    end
  end
end

local function probe_misc(config, b, name)
  local s, record = b.state, b.record
  if type(config.cmd) == "function" then
    record("cmd.return", config.cmd({ on_exit = function() end }, { root_dir = "/project" }))
    s.executable = 0
    record("cmd.fallback", config.cmd({}, { root_dir = "/project" }))
    record("cmd.no_root", config.cmd({}))
  end
  if config.reuse_client then
    for _, input in ipairs({ { "same", "/work" }, { "other", "/work" }, { "same", "/other" } }) do
      local c = { name = input[1], config = { cmd_cwd = input[2] } }
      local target = { name = "same", root_dir = "/work" }
      record("reuse.return", config.reuse_client(c, target))
      record("reuse.config", target)
    end
  end
  if config.get_language_id then
    for _, input in ipairs({
      { "a.exp", {} },
      { "a.expect", {} },
      { "a.tk", {} },
      { "a.tcl", { "#!/usr/bin/expect" } },
      { "a.tcl", { "#!/usr/bin/wish" } },
      { "a.tcl", { "#!/usr/bin/jimsh" } },
      { "a.exp", { "# tcl-dialect: tcl9" } },
      { "a.tcl", {} },
    }) do
      s.filename, s.lines = input[1], input[2]
      record("language_id", config.get_language_id(7, "tcl"))
    end
  end
  if name == "gopls" then
    -- A fresh module leaves both failed caches unset, then retries both commands.
    for _, args in ipairs(b.queues.system) do
      args[3]({ code = 1, stdout = "", stderr = "go missing" })
    end
    for _, args in ipairs(b.queues.schedule) do
      args[1]()
    end
  end
end

local function capture(name, win, baseline)
  local b = sandbox(win)
  local config = load_config(name, b, baseline)
  local result = { config = normalize(config), load = vim.deepcopy(b.calls) }
  probe_roots(config, b, name)
  probe_init(config, b, name)
  probe_handlers(config, b)
  b.queues.request = {}
  probe_attach(config, b, name)
  probe_misc(config, b, name)
  result.trace = b.calls
  if name == "gopls" then
    local failed = sandbox(win)
    local fresh = load_config(name, failed, baseline)
    fresh.root_dir(7, function(...)
      failed.record("on_dir", ...)
    end)
    probe_misc(fresh, failed, name)
    fresh.root_dir(7, function(...)
      failed.record("retry.on_dir", ...)
    end)
    failed.record("retry.pending", #failed.queues.system)
    result.failure_trace = failed.calls
  end
  return result
end

local generating = vim.env.LSP_CONFIG_GENERATE == "1"
local baseline = generating and assert(vim.env.LSP_CONFIG_BASELINE, "generation requires original Lua baseline")
  or vim.env.LSP_CONFIG_VERIFY_BASELINE
local fixture
if generating then
  assert(
    vim.fs.normalize(baseline) ~= vim.fs.normalize(root .. "/lsp"),
    "never generate the oracle from migrated configurations"
  )
  fixture = { provenance = "Original Lua 2026-11-10; lua_ls from original user Fennel", configs = {} }
  for _, path in ipairs(vim.fn.glob(baseline .. "/*.lua", false, true)) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    fixture.configs[name] = {}
    for win = 0, 1 do
      fixture.configs[name][win == 1 and "windows" or "linux"] = capture(name, win, baseline)
    end
  end
  vim.fn.writefile({ vim.json.encode(fixture) }, fixture_path)
else
  fixture = vim.json.decode(table.concat(vim.fn.readfile(fixture_path), "\n"))
end

T["configuration inventory"] = function()
  local names = {}
  for _, path in ipairs(vim.fn.glob((baseline or (root .. "/lsp")) .. (baseline and "/*.lua" or "/*.fnl"), false, true)) do
    names[#names + 1] = vim.fn.fnamemodify(path, ":t:r")
  end
  table.sort(names)
  eq(names, vim.fn.sort(vim.tbl_keys(fixture.configs)))
end

-- These callbacks are invoked for effects; their incidental return values are
-- ignored by the caller. Keep argument arity for actual requests and handlers.
local ignored_returns = {
  ["root.return"] = true, -- These configs deliver the selected root through on_dir.
  ["attach.return"] = true,
  ["command.return"] = true,
  ["unsupported.return"] = true,
  ["init.return"] = true,
  ["init.absent_encoding"] = true,
}

local function observable_contract(snapshot)
  local result = vim.deepcopy(snapshot)
  -- The original Lua oracle used the misspelled module name; retain its
  -- capability expectations while explicitly accounting for this correction.
  for _, calls in ipairs({ result.load or {}, result.trace }) do
    for _, call in ipairs(calls) do
      if call[1] == "require" then
        for _, entry in ipairs(call[2].entries) do
          if entry[1] == 1 and entry[2] == "blink-cmp" then
            entry[2] = "blink.cmp"
          end
        end
      end
    end
  end
  for _, call in ipairs(result.trace) do
    if ignored_returns[call[1]] then
      call[2] = { kind = "ignored-return" }
    end
  end
  return result
end

T["effect callback returns do not change the contract"] = function()
  for label in pairs(ignored_returns) do
    local before = { trace = { { label, normalize({ n = 0 }) } } }
    local after = { trace = { { label, normalize({ n = 1 }) } } }
    eq(observable_contract(before), observable_contract(after))
    eq(before.trace[1][2], normalize({ n = 0 })) -- Projection must not modify the oracle.
  end
end

T["request arguments and meaningful returns remain exact"] = function()
  for _, label in ipairs({ "on_dir", "client.request", "handler.return", "cmd.return", "reuse.return" }) do
    local before = { trace = { { label, normalize({ n = 0 }) } } }
    local after = { trace = { { label, normalize({ n = 1 }) } } }
    eq(vim.deep_equal(observable_contract(before), observable_contract(after)), false)
  end
end

for name, platforms in pairs(fixture.configs) do
  for platform, expected in pairs(platforms) do
    T[name .. "/" .. platform] = function()
      eq(observable_contract(capture(name, platform == "windows" and 1 or 0, baseline)), observable_contract(expected))
    end
  end
end

return T
