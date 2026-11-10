local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality
local state
local START, END = "__NEOGHIDRA_JSON_START__", "__NEOGHIDRA_JSON_END__"

local function evaluate(path)
  local hotpot = vim.env.HOTPOT_PATH
  if not hotpot or hotpot == "" then
    hotpot = vim.fn.stdpath("data") .. "/lazy/hotpot.nvim"
  end
  vim.opt.runtimepath:append(hotpot)
  local source = table.concat(vim.fn.readfile(path), "\n")
  local compiled = require("hotpot.fennel")["compile-string"](source, { filename = path })
  return assert(loadstring(compiled, "@" .. path))()
end

local function write(path, contents)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile({ contents or "fixture" }, path)
end

local function result()
  return {
    program_name = "sample binary",
    entry_point = "00401000",
    functions = { { name = "main", address = "00401000" } },
    symbols = {},
    disassembly = {},
  }
end

local function frame(json)
  return START .. "\n" .. json .. "\n" .. END
end

local function analyze()
  return state.ghidra.analyze_binary(state.binary, function(value, err)
    state.callbacks[#state.callbacks + 1] = { value = value, error = err }
  end)
end

local function complete(stdout, stderr, code)
  local count = #state.callbacks
  assert(state.completion, "adapter did not start vim.system")
  state.completion({ code = code or 0, signal = 0, stdout = stdout, stderr = stderr or "" })
  eq(#state.callbacks, count)
  assert(
    vim.wait(1000, function()
      return #state.callbacks > count
    end, 5),
    "scheduled analysis callback did not run"
  )
  vim.wait(10, function()
    return false
  end, 1)
  eq(#state.callbacks, count + 1)
end

local function failure(prefix)
  eq(#state.callbacks, 1)
  eq(state.callbacks[1].value, nil)
  local err = state.callbacks[1].error
  eq(type(err), "string")
  eq(err:sub(1, #prefix), prefix)
  eq(state.errors, { err })
  eq(state.cache_writes, {})
  eq(state.cache, {})
  return err
end

local function log_contents()
  local name = vim.fs.basename(state.binary) .. "_" .. vim.fn.sha256(state.binary):sub(1, 8)
  local path = vim.fs.joinpath(state.config.project_dir, name .. ".neoghidra.log")
  assert(vim.fn.filereadable(path) == 1, "missing diagnostic log: " .. path)
  return table.concat(vim.fn.readfile(path), "\n"), path
end

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      state = {
        original_system = vim.system,
        original_runtime_file = vim.api.nvim_get_runtime_file,
        original_runtimepath = vim.o.runtimepath,
        loaded = {},
        root = vim.fn.tempname() .. " neoghidra tests",
        callbacks = {},
        errors = {},
        cache = {},
        cache_writes = {},
        calls = {},
      }
      for name, module in pairs(package.loaded) do
        state.loaded[name] = module
      end
      state.config = {
        ghidra_path = state.root .. "/ghidra home",
        project_dir = state.root .. "/project directory",
        analysis_timeout = 37,
      }
      state.launcher = state.config.ghidra_path .. "/support/pyghidraRun"
      state.binary = state.root .. "/input directory/sample binary"
      state.script = state.root .. "/script directory/neoghidra_export.py"
      write(state.launcher, "#!/bin/sh")
      assert(vim.fn.setfperm(state.launcher, "rwx------") == 1)
      write(state.binary)
      write(state.script)
      vim.fn.mkdir(state.config.project_dir, "p")
      vim.api.nvim_get_runtime_file = function(path, all)
        if path == "scripts/neoghidra_export.py" then
          return state.script and { state.script } or {}
        end
        return state.original_runtime_file(path, all)
      end
      state.ghidra = { analyze_binary = function() end, untouched = function() end }
      state.untouched = state.ghidra.untouched
      package.loaded["neoghidra.ghidra"] = state.ghidra
      package.loaded["neoghidra.config"] = {
        get = function()
          return state.config
        end,
      }
      package.loaded["neoghidra.utils"] = {
        error = function(message)
          state.errors[#state.errors + 1] = message
        end,
        notify = function() end,
        cache_set = function(path, value)
          state.cache_writes[#state.cache_writes + 1] = { path, value }
          state.cache[path] = value
        end,
      }
      state.buffers, state.views = {}, {}
      for _, name in ipairs({ "decompiler", "disassembly" }) do
        local view = { buffer_binaries = {}, line_to_address = {}, buffer_disasm = {} }
        view.create_buffer = function(path, name)
          local buf = vim.api.nvim_create_buf(false, true)
          state.buffers[#state.buffers + 1] = buf
          view.buffer_binaries[buf] = path
          if name then
            vim.api.nvim_buf_set_name(buf, name)
          end
          vim.bo[buf].modifiable = false
          vim.bo[buf].readonly = true
          return buf
        end
        state.views[name] = view
        package.loaded["neoghidra." .. name] = view
      end
      package.loaded["plugins.config.neoghidra.views"] = evaluate("fnl/plugins/config/neoghidra/views.fnl")
      state.process = { pid = 123 }
      vim.system = function(argv, opts, callback)
        state.calls[#state.calls + 1] = { argv = argv, opts = opts }
        state.completion = callback
        return state.process
      end
      state.adapter = evaluate("fnl/plugins/config/neoghidra/init.fnl")
      state.adapter.setup()
    end,
    post_case = function()
      vim.wait(10, function()
        return false
      end, 1)
      vim.system = state.original_system
      vim.api.nvim_get_runtime_file = state.original_runtime_file
      vim.o.runtimepath = state.original_runtimepath
      for name in pairs(package.loaded) do
        if state.loaded[name] == nil then
          package.loaded[name] = nil
        end
      end
      for name, module in pairs(state.loaded) do
        package.loaded[name] = module
      end
      for _, buf in ipairs(state.buffers) do
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
      vim.fn.delete(state.root, "rf")
    end,
  },
})

T["setup replaces only analyze_binary and is repeatable"] = function()
  local installed = state.ghidra.analyze_binary
  state.adapter.setup()
  eq(state.ghidra.analyze_binary, installed)
  eq(state.ghidra.untouched, state.untouched)
  eq(state.calls, {})
end

for _, name in ipairs({ "decompiler", "disassembly" }) do
  T[name .. " loading writes without W10 and final results remain protected"] = function()
    local view = state.views[name]
    local installed = view.create_buffer
    state.adapter.setup()
    eq(view.create_buffer, installed)
    local buf = view.create_buffer(state.binary, state.root .. "/view")
    eq(vim.bo[buf].modifiable, false)
    eq(vim.bo[buf].readonly, false)
    eq(pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, { "unexpected loading edit" }), false)
    vim.v.errmsg = ""
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Analyzing binary..." })
    vim.bo[buf].modifiable = false
    eq(vim.v.errmsg, "")
    -- Upstream result loaders explicitly unlock, write, then restore both protections.
    vim.bo[buf].modifiable, vim.bo[buf].readonly = true, false
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "analysis result" })
    vim.bo[buf].modifiable, vim.bo[buf].readonly = false, true
    eq(pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, { "unexpected edit" }), false)
    eq(vim.bo[buf].readonly, true)
  end
end

for _, name in ipairs({ "decompiler", "disassembly" }) do
  T[name .. " reuses a live buffer and clears stale address maps"] = function()
    local view = state.views[name]
    local buf = view.create_buffer(state.binary, state.root .. "/view")
    view.line_to_address[buf] = { [8] = "00401000" }
    view.buffer_disasm[buf] = { result = "previous data" }
    eq(view.create_buffer(state.binary, state.root .. "/view"), buf)
    eq(#state.buffers, 1)
    eq(view.line_to_address[buf], nil)
    eq(view.buffer_disasm[buf], nil)
  end
  T[name .. " keeps equal basenames in different paths separate"] = function()
    local view = state.views[name]
    local first = view.create_buffer(state.binary, state.root .. "/view")
    local other = state.root .. "/other/sample binary"
    local second = view.create_buffer(other, state.root .. "/view")
    eq(first ~= second, true)
    eq(vim.api.nvim_buf_get_name(first) ~= vim.api.nvim_buf_get_name(second), true)
    eq(view.buffer_binaries[first], state.binary)
    eq(view.buffer_binaries[second], other)
  end
  T[name .. " replaces a deleted view instead of reusing its stale ID"] = function()
    local view = state.views[name]
    local first = view.create_buffer(state.binary, state.root .. "/view")
    vim.api.nvim_buf_delete(first, { force = true })
    local second = view.create_buffer(state.binary, state.root .. "/view")
    eq(first ~= second, true)
    eq(vim.api.nvim_buf_is_valid(second), true)
  end
end

T["plugin config installs adapter before upstream setup and forwards opts"] = function()
  local order, received = {}, nil
  package.loaded["plugins.config.neoghidra"] = {
    setup = function()
      order[#order + 1] = "adapter"
    end,
  }
  package.loaded.neoghidra = {
    setup = function(opts)
      order[#order + 1] = "upstream"
      received = opts
    end,
  }
  local spec = evaluate("fnl/plugins/require/neoghidra.fnl")
  local opts = { analysis_timeout = 73 }
  spec.config(spec, opts)
  eq(order, { "adapter", "upstream" })
  eq(received == opts, true)
end

for _, chatter in ipairs({ false, true }) do
  T["success decodes immediate marker JSON; chatter=" .. tostring(chatter)] = function()
    local expected = result()
    local stdout = frame(vim.json.encode(expected))
    if chatter then
      stdout = "INFO PyGhidra starting\n" .. stdout .. "\nINFO analysis done"
    end
    eq(analyze(), state.process)
    complete(stdout)
    eq(state.callbacks, { { value = expected } })
    eq(state.errors, {})
    eq(state.cache_writes, { { state.binary, expected } })
    eq(state.cache, { [state.binary] = expected })
    eq(#state.calls, 1)
  end
end

T["argv preserves spaces without shell and applies configured timeout"] = function()
  analyze()
  local name = vim.fs.basename(state.binary) .. "_" .. vim.fn.sha256(state.binary):sub(1, 8)
  eq(state.calls[1], {
    argv = {
      vim.fn.exepath("timeout"),
      "--kill-after=2s",
      "37",
      state.launcher,
      "-H",
      state.config.project_dir,
      name,
      "-import",
      state.binary,
      "-overwrite",
      "-scriptPath",
      vim.fs.dirname(state.script),
      "-postScript",
      "neoghidra_export.py",
      "-analysisTimeoutPerFile",
      "37",
    },
    opts = { text = true },
  })
  complete(frame(vim.json.encode(result())))
end

local invalid_outputs = {
  { name = "exporter error", json = '{"error":true,"message":"Python is not available"}', error = "ExportError:" },
  { name = "missing JSON", stdout = "INFO finished without export", error = "MissingOutput:" },
  { name = "missing end marker", stdout = START .. "{}", error = "MissingOutput:" },
  { name = "bad JSON", json = "{ broken", error = "InvalidJSON:" },
  { name = "empty frame", json = "", error = "InvalidJSON:" },
  { name = "list", json = "[1,2]", error = "InvalidResult:" },
  { name = "null", json = "null", error = "InvalidResult:" },
  { name = "scalar", json = '"text"', error = "InvalidResult:" },
  { name = "empty object", json = "{}", error = "InvalidResult:" },
}
for _, field in ipairs({ "program_name", "entry_point", "functions", "symbols", "disassembly" }) do
  local missing = result()
  missing[field] = nil
  invalid_outputs[#invalid_outputs + 1] = {
    name = "missing " .. field,
    json = vim.json.encode(missing),
    error = "InvalidResult:",
  }
  local wrong = result()
  wrong[field] = 42
  invalid_outputs[#invalid_outputs + 1] = {
    name = "wrong type " .. field,
    json = vim.json.encode(wrong),
    error = "InvalidResult:",
  }
end
for _, case in ipairs(invalid_outputs) do
  T["rejects " .. case.name .. " once without caching"] = function()
    analyze()
    local stdout = case.stdout or frame(case.json)
    complete(stdout, "export diagnostics")
    failure(case.error)
    eq(log_contents(), stdout .. "\nexport diagnostics")
  end
end

T["nonzero exit rejects valid JSON and persists complete stdout and stderr"] = function()
  analyze()
  local stdout = "INFO starting\n" .. frame(vim.json.encode(result())) .. "\nINFO stopped\n"
  local stderr = "Traceback:\n  missing pyghidra\n"
  complete(stdout, stderr, 7)
  local err = failure("ProcessError: PyGhidra exit 7")
  local contents, path = log_contents()
  eq(contents, stdout .. "\n" .. stderr)
  eq(err:find(path, 1, true) ~= nil, true)
end

T["failure preserves a previously successful cache entry"] = function()
  analyze()
  local expected = result()
  complete(frame(vim.json.encode(expected)))
  analyze()
  complete("no export", "failed second run", 1)
  eq(#state.callbacks, 2)
  eq(state.callbacks[2].value, nil)
  eq(#state.errors, 1)
  eq(state.cache_writes, { { state.binary, expected } })
  eq(state.cache, { [state.binary] = expected })
end

for _, missing in ipairs({ "launcher", "binary", "script" }) do
  T["missing " .. missing .. " fails once before spawning"] = function()
    if missing == "script" then
      state.script = nil
    else
      vim.fn.delete(state[missing])
    end
    eq(analyze(), nil)
    failure("Missing" .. missing:sub(1, 1):upper() .. missing:sub(2) .. ":")
    eq(state.calls, {})
  end
end

T["unwritable log directory reports full output without losing callback"] = function()
  state.config.project_dir = state.root .. "/nonexistent/log directory"
  analyze()
  complete("stdout diagnostic", "stderr diagnostic", 1)
  local err = failure("ProcessError:")
  eq(err:find("stdout diagnostic\nstderr diagnostic", 1, true) ~= nil, true)
end

T["launch exception fails once without caching"] = function()
  vim.system = function()
    error("fixture spawn failure")
  end
  eq(analyze(), nil)
  local err = failure("LaunchError:")
  eq(err:find("fixture spawn failure", 1, true) ~= nil, true)
end

T["marker literals inside valid JSON are not frame boundaries"] = function()
  local expected = result()
  expected.program_name = START .. " " .. END
  expected.functions[1].code = 'return "' .. END .. '";'
  analyze()
  complete(frame(vim.json.encode(expected)))
  eq(state.callbacks, { { value = expected } })
  eq(state.errors, {})
end

T["timeout terminates the launcher and its child process"] = function()
  if vim.fn.has("unix") ~= 1 or vim.fn.executable("timeout") ~= 1 then
    MiniTest.skip("GNU timeout process-group check requires Unix")
  end
  local pidfile = state.root .. "/processes"
  vim.fn.writefile({
    "#!/bin/sh",
    [[trap 'wait "$child"; exit 143' TERM]],
    "sleep 60 &",
    "child=$!",
    'printf \'%s %s\\n\' "$$" "$child" > ' .. vim.fn.shellescape(pidfile),
    'wait "$child"',
  }, state.launcher)
  state.config.analysis_timeout = 1
  vim.system = state.original_system
  analyze()
  local finished = vim.wait(6000, function()
    return #state.callbacks > 0
  end, 10)
  local pids = vim.split(vim.fn.readfile(pidfile)[1], " ", { plain = true })
  local survivors = {}
  for _, pid in ipairs(pids) do
    local alive = vim.uv.kill(tonumber(pid), 0)
    if alive then
      survivors[#survivors + 1] = pid
      vim.uv.kill(tonumber(pid), 9)
    end
  end
  assert(finished, "timeout callback was not delivered")
  failure("ProcessError: PyGhidra exit 124")
  eq(survivors, {})
end

T["exporter rejects data entry points and prefers process entry"] = function()
  local python = vim.fn.exepath("python3")
  if python == "" then
    MiniTest.skip("python3 is not available")
  end
  local completed = state.original_system({ python, "tests/unit/neoghidra_export.py" }, { text = true }):wait()
  assert(completed.code == 0, (completed.stdout or "") .. (completed.stderr or ""))
end

return T
