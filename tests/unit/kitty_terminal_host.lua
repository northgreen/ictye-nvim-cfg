-- Driven by kitty_terminal_host.py in a real, initialized Kitty/Nvim TUI.
-- Lua parses child protocols; ordinary display/input uses the native terminal.
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local native_inputs, open_term = {}, vim.api.nvim_open_term
vim.api.nvim_open_term = function(buf, opts)
  local on_input = opts.on_input
  opts.on_input = function(event, channel, buffer, bytes)
    native_inputs[buffer] = native_inputs[buffer] or {}
    table.insert(native_inputs[buffer], bytes)
    return on_input(event, channel, buffer, bytes)
  end
  return open_term(buf, opts)
end
local Terminal = require("experimental.kitty_terminal")
local Render = require("experimental.kitty_terminal.render")
local directory = assert(vim.env.KITTY_LUA_TEST_DIR)
local term, phase, done, ticks = nil, "starting", false, 0
local result = { ok = false, stages = {} }
local function write(name, data)
  local path = directory .. "/" .. name
  vim.fn.writefile({ vim.json.encode(data) }, path .. ".tmp")
  assert(vim.uv.fs_rename(path .. ".tmp", path))
end
local function finish(err)
  if done then
    return
  end
  done = true
  result.ok, result.error = err == nil, err and tostring(err) or nil
  if term then
    term:close()
  end
  write("result.json", result)
  vim.cmd("qa!")
end
local function snapshot(name)
  local p = {}
  for key, placement in pairs(term.graphics.placements) do
    local views = vim.empty_dict()
    for win, view in pairs(placement.views) do
      views[tostring(win)] = view
    end
    p[key] = {
      cols = placement.cols,
      rows = placement.rows,
      width = placement.image.width,
      height = placement.image.height,
      col = placement.col,
      line = term.row_ids[placement.line_id],
      views = views,
    }
  end
  local data = {
    stage = name,
    stats = vim.deepcopy(term.stats),
    errors = vim.deepcopy(term.errors),
    keyboard_flags = term.keyboard_flags,
    capture = term.capture,
    modes = vim.deepcopy(term.screen.modes),
    mode = vim.api.nvim_get_mode().mode,
    view_channel = vim.api.nvim_get_chan_info(term.view_channel),
    input_log = term.input_log,
    native_inputs = native_inputs[term.buf],
    host_graphics = vim.deepcopy(term.host_graphics),
    cells = { term.screen.cols, term.screen.rows },
    cell_pixels = { term.cell_width, term.cell_height },
    pixel_source = term.cell_size_source,
    pixel_error = term.pixel_size_error,
    views = Render.views(term),
    placements = p,
    channel_mode = vim.api.nvim_get_chan_info(term.job).mode,
    buffer_type = vim.bo[term.buf].buftype,
    lines = vim.api.nvim_buf_get_lines(term.buf, 0, -1, false),
  }
  result.stages[name] = data
  write("state.json", data)
end
local function action()
  local path = directory .. "/action"
  if vim.fn.filereadable(path) ~= 1 then
    return
  end
  local value = table.concat(vim.fn.readfile(path), "")
  vim.fn.delete(path)
  return value
end
local function open_icat()
  vim.cmd("vsplit")
  local source = vim.api.nvim_get_current_win()
  term = Terminal.open({
    cmd = {
      "/bin/sh",
      "-c",
      'kitten icat "$HOME/.desktop-backgrounds/bk-bk.png"; printf "\\r\\n__ICAT_EXIT:%d__\\r\\n" "$?"; IFS= read -r line; printf "__INPUT:%s__\\r\\n" "$line"; i=0; while [ "$i" -lt 70 ]; do printf "scroll line %d\\r\\n" "$i"; i=$((i+1)); done; sleep 40',
    },
    capture = false,
  })
  term.source_win = source
  vim.api.nvim_win_set_width(source, math.max(24, math.floor(vim.o.columns * 0.65)))
  term:resize()
  vim.cmd("wincmd l")
  vim.cmd("enew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "UNRELATED NVIM SPLIT", "Images must not cover this pane" })
  phase = "wait_icat"
end
local function open_browser()
  term:close()
  vim.api.nvim_set_current_win(term.source_win)
  term = Terminal.open({
    cmd = {
      "terminal-browser",
      'data:text/html,<html><body style="margin:0;background:%232458a0;color:white"><h1>Local%20Lua%20PTY</h1><input autofocus placeholder="type%20here" oninput="document.body.style.background=this.value===String.fromCharCode(104,101,108,108,111,45,108,117,97)?String.fromCharCode(35,48,48,97,97,53,53):String.fromCharCode(35,97,97,48,48,48,48)"><p>Kitty%20graphics%20inside%20Neovim</p><style>@keyframes%20pulse{from{background:rgb(255,0,0)}to{background:rgb(0,0,255)}}%23motion{position:fixed;left:160px;top:150px;width:100px;height:100px;animation:pulse%20.2s%20infinite%20alternate}</style><div id="motion"></div></body></html>',
      "--no-merge",
    },
    capture = false,
  })
  term.source_win = vim.api.nvim_get_current_win()
  term.host_graphics = { deletes = 0, placements = 0, uploads = 0 }
  local host_send = term.host_send
  function term:host_send(bytes)
    for control in bytes:gmatch("\27_G([^;\27]*)") do
      local action = control:match("a=([%a])") or "t"
      if action == "d" then
        self.host_graphics.deletes = self.host_graphics.deletes + 1
      end
      if action == "p" then
        self.host_graphics.placements = self.host_graphics.placements + 1
      end
      if action == "t" then
        self.host_graphics.uploads = self.host_graphics.uploads + 1
      end
    end
    return host_send(self, bytes)
  end
  term.input_log = {}
  local send = term.send
  function term:send(bytes)
    self.input_log[#self.input_log + 1] = bytes
    return send(self, bytes)
  end
  phase = "wait_browser"
end
local function open_shell()
  local win = term.source_win
  term:close()
  vim.api.nvim_set_current_win(win)
  term = Terminal.open({ capture = false })
  term.source_win, term.started_at = win, ticks
  phase = "wait_shell"
end
local function tick()
  if done then
    return
  end
  ticks = ticks + 1
  assert(ticks < 1000, "host experiment timed out at " .. phase)
  if term then
    assert(#term.errors == 0, vim.inspect(term.errors))
  end
  if phase == "starting" then
    open_icat()
  elseif phase == "wait_icat" then
    local lines = table.concat(vim.api.nvim_buf_get_lines(term.buf, 0, -1, false), "\n")
    assert(not lines:find("__ICAT_EXIT:[1-9]"), lines)
    if lines:find("__ICAT_EXIT:0__", 1, true) and not term.render_pending then
      assert(next(term.graphics.placements), "icat produced no image placements")
      assert(
        term.stats.local_graphics_queries and term.stats.local_graphics_queries >= 1,
        "icat did not probe graphics"
      )
      snapshot("icat")
      phase = "icat"
    end
  elseif phase == "icat" and action() == "resize" then
    vim.api.nvim_win_set_width(term.source_win, math.max(20, term.screen.cols - 9))
    term:resize()
    phase = "wait_resize"
  elseif phase == "wait_resize" and not term.render_pending then
    snapshot("resized")
    phase = "resized"
  elseif phase == "resized" and action() == "hide" then
    local blank = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(term.source_win, blank)
    term:refresh()
    phase = "wait_hidden"
  elseif phase == "wait_hidden" and not term.render_pending then
    snapshot("hidden")
    phase = "hidden"
  elseif phase == "hidden" and action() == "restore" then
    vim.api.nvim_win_set_buf(term.source_win, term.buf)
    term:resize()
    phase = "wait_restored"
  elseif phase == "wait_restored" and not term.render_pending then
    snapshot("restored")
    phase = "restored"
  elseif phase == "restored" and action() == "input" then
    vim.api.nvim_set_current_win(term.source_win)
    term:enter()
    snapshot("input_ready")
    phase = "wait_input"
  elseif phase == "wait_input" then
    local lines = table.concat(vim.api.nvim_buf_get_lines(term.buf, 0, -1, false), "\n")
    if
      lines:find("__INPUT:actual-pty-input__", 1, true)
      and lines:find("scroll line 69", 1, true)
      and not term.render_pending
    then
      snapshot("input")
      phase = "input"
    end
  elseif phase == "input" and action() == "scrollback" then
    assert(not term.capture, "Ctrl-\\ Ctrl-N did not release terminal input")
    vim.api.nvim_win_call(term.source_win, function()
      vim.cmd("normal! gg")
    end)
    term:refresh()
    phase = "wait_scrollback"
  elseif phase == "wait_scrollback" and not term.render_pending then
    snapshot("scrollback")
    phase = "scrollback"
  elseif phase == "scrollback" and action() == "browser" then
    open_browser()
  elseif phase == "wait_browser" then
    if term.exited then
      error(
        "terminal-browser exited "
          .. term.exit_code
          .. ": "
          .. table.concat(vim.api.nvim_buf_get_lines(term.buf, 0, -1, false), "\n")
      )
    end
    if next(term.graphics.placements) and not term.render_pending then
      snapshot("browser")
      phase = "browser"
    end
  elseif phase == "browser" and action() == "type" then
    vim.api.nvim_set_current_win(term.source_win)
    term:enter()
    phase = "wait_browser_mode"
  elseif phase == "wait_browser_mode" and vim.api.nvim_get_mode().mode == "t" then
    snapshot("browser_input_ready")
    phase = "wait_typed"
    term.typed_at = ticks
  elseif phase == "wait_typed" and ticks - term.typed_at > 12 then
    snapshot("typed")
    phase = "typed"
  elseif phase == "typed" and action() == "shell" then
    open_shell()
  elseif phase == "wait_shell" and term.pty_ready and ticks - term.started_at > 12 then
    assert(not term.exited, "default interactive shell exited early")
    term:enter()
    snapshot("shell_ready")
    phase = "shell_ready"
  elseif phase == "shell_ready" then
    if action() == "paste_shell" then
      assert(vim.api.nvim_get_mode().mode == "t", "native Terminal-mode not active")
      vim.api.nvim_paste('printf "__SHELL_OK:%s__\\n" "$((19+23))"', false, -1)
      snapshot("shell_pasted")
    end
    local text = table.concat(vim.api.nvim_buf_get_lines(term.buf, 0, -1, false), "\n")
    if text:find("__SHELL_OK:42__", 1, true) then
      snapshot("shell")
      phase = "shell"
    end
  elseif phase == "shell" and action() == "palette" then
    local esc = "\27"
    term:feed(
      esc
        .. "]4;1;#12ab34"
        .. esc
        .. "\\"
        .. esc
        .. "[?6l"
        .. esc
        .. "[r"
        .. esc
        .. "[2J"
        .. esc
        .. "[H"
        .. esc
        .. "[31m"
        .. string.rep("█", 20)
        .. esc
        .. "[0m"
    )
    phase = "wait_palette"
  elseif phase == "wait_palette" and not term.render_pending then
    snapshot("palette")
    phase = "palette"
  elseif phase == "palette" and action() == "exit_shell" then
    phase = "wait_shell_exit"
  elseif phase == "wait_shell_exit" and term.exited then
    assert(term.exit_code == 0, "default shell exit failed: " .. tostring(term.exit_code))
    finish()
    return
  end
  vim.defer_fn(function()
    local ok, err = xpcall(tick, debug.traceback)
    if not ok then
      finish(err)
    end
  end, 100)
end
vim.defer_fn(function()
  local ok, err = xpcall(tick, debug.traceback)
  if not ok then
    finish(err)
  end
end, 100)
