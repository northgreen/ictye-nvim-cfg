-- A Lua-owned terminal experiment: raw jobstart PTY -> ANSI parser -> Lua grid
-- -> native nvim_open_term view. Lua owns child protocols; Nvim owns display/input.
-- :KittyLuaTerm [shell command], Ctrl-\ Ctrl-N to release input, i to resume.
-- 两个通道不可混用：job 接收子进程输入/查询应答，view_channel 只接收
-- 显示用 ANSI；host_send 绕过内部终端，把图形命令送给外层 Kitty。
local Screen = require('experimental.kitty_terminal.screen')
local Parser = require('experimental.kitty_terminal.parser')
local Graphics = require('experimental.kitty_terminal.graphics')
local Protocol = require('experimental.kitty_terminal.protocol')
local Render = require('experimental.kitty_terminal.render')
local Input = require('experimental.kitty_terminal.input')
local Tty = require('experimental.kitty_terminal.tty')
local HostInput = require('experimental.kitty_terminal.host_input')
local M, Term = {}, {}
Term.__index = Term
local ESC, ST = '\27', '\27\\'
local sessions, routes = {}, {}
-- sessions 按 buffer 隔离状态；没有图像 ID 的宿主响应按协议族登记候选会话。
local group = vim.api.nvim_create_augroup('kitty_lua_terminal', { clear = true })
local paint_ns = vim.api.nvim_create_namespace('kitty_lua_terminal_paint')
local function route_key(kind, body)
  if kind == 'osc' then return 'osc:' .. (body:match('^(%d+)') or '') end
  return kind .. ':' .. (body:match('^(@kitty[%w%-]*)') or body:sub(1, 2))
end
function Term:host_send(bytes)
  if vim.env.TMUX and vim.env.TMUX ~= '' then bytes = ESC .. 'Ptmux;' .. bytes:gsub(ESC, ESC .. ESC) .. ST end
  self.stats.host_bytes = self.stats.host_bytes + #bytes
  if self.options.host_send then self.options.host_send(bytes) else vim.api.nvim_ui_send(bytes) end
end

function Term:send(bytes)
  if self.job and not self.exited and not self.closed then
    vim.api.nvim_chan_send(self.job, bytes)
    self.stats.input_bytes = self.stats.input_bytes + #bytes
  end
end

function Term:keyboard_request(flags) HostInput.request(self, flags) end
function Term:keyboard_query() HostInput.query(self) end

function Term:display(bytes)
  if bytes ~= '' then self.display_pending[#self.display_pending + 1] = bytes end
end

function Term:sync_cursor()
  -- Lua 保存绝对网格行号，DECOM 开启时 CUP 参数必须相对滚动区域顶部。
  local row = self.screen.row
  if self.screen.modes.origin then row = row - self.screen.top + 1 end
  self:display(string.format(ESC .. '[%d;%dH', row, self.screen.col))
end

function Term:enter()
  if self.closed or self.exited or vim.api.nvim_get_current_buf() ~= self.buf then return end
  vim.cmd('startinsert')
  -- Terminal-mode 内切换到另一个终端缓冲区时，Nvim 不一定再次触发 TermEnter。
  if vim.api.nvim_get_mode().mode == 't' then
    for _, other in pairs(sessions) do
      other.capture = other == self
      HostInput.capture(other)
    end
  end
end

function Term:ready()
  local ok, err = Tty.resize(self.job, self.screen.cols, self.screen.rows, self.cell_width, self.cell_height)
  if not ok then self.pixel_size_error = err end
  self.pty_ready = true
  self:send('ready\n')
end

function Term:host_protocol(kind, body, terminator, overlay)
  local prefix = ({ osc = ESC .. ']', dcs = ESC .. 'P', apc = ESC .. '_' })[kind]
  if not prefix then return end
  local wire = prefix .. body .. (terminator or ST)
  if overlay then
    self.overlays[#self.overlays + 1] = { wire = wire, line_id = self.screen:line_id(), col = self.screen.col - 1 }
    return
  end
  local key = route_key(kind, body)
  routes[key] = routes[key] or {}
  routes[key][self] = vim.uv.hrtime() + 30e9
  self:host_send(wire)
end

function Term:refresh()
  -- 多次 PTY 输出合并为一次显示提交；解析/查询回复仍同步进行，不等这 16ms。
  if self.closed or self.render_pending then return end
  self.render_pending = true
  vim.defer_fn(function()
    self.render_pending = false
    if self.closed then return end
    local ok, err = pcall(Render.draw, self)
    if not ok then self.errors[#self.errors + 1] = 'render: ' .. tostring(err) end
  end, self.options.render_delay or 16)
end

function Term:feed(bytes)
  if self.closed then return end
  self.stats.output_bytes = self.stats.output_bytes + #bytes
  local ok, err = pcall(self.parser.feed, self.parser, bytes)
  if not ok then self.errors[#self.errors + 1] = 'parser: ' .. tostring(err) end
  self:refresh()
end

function Term:resize()
  if self.closed then return end
  local views = Render.views(self)
  local view = views[1]
  -- 一个 PTY 只有一份尺寸：优先当前视图；其他分屏独立裁剪同一份内容。
  for _, v in ipairs(views) do
    if v.win == vim.api.nvim_get_current_win() then
      view = v; break
    end
  end
  if not view then
    self.graphics:draw({}); return
  end
  if view.cols ~= self.screen.cols or view.rows ~= self.screen.rows then
    self.screen:resize(math.max(1, view.cols), math.max(1, view.rows))
    if self.job and not self.exited then
      local ok, err = Tty.resize(self.job, self.screen.cols, self.screen.rows, self.cell_width, self.cell_height)
      if not ok then self.pixel_size_error = err end
    end
  end
  self:refresh()
end

function Term:close()
  if self.closed then return end
  self.closed = true
  HostInput.close(self)
  -- 先标记关闭，使已排队的输入超时与重绘回调失效，再释放宿主资源和通道。
  self.graphics:close()
  for _, owners in pairs(routes) do owners[self] = nil end
  sessions[self.buf] = nil
  if self.job and not self.exited then pcall(vim.fn.jobstop, self.job) end
  if self.view_channel then pcall(vim.fn.chanclose, self.view_channel) end
end

local function palette_defaults()
  local hl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  return string.format('#%06x', hl.fg or 0xeeeeee), string.format('#%06x', hl.bg or 0x111111)
end
local function configure_window(win)
  for key, value in pairs({ number = false, relativenumber = false, signcolumn = 'no',
    foldcolumn = '0', foldenable = false, wrap = false, list = false, cursorline = false,
    scrolloff = 0, sidescrolloff = 0, winfixbuf = false }) do
    vim.api.nvim_set_option_value(key, value, { win = win })
  end
end
function M.open(options)
  options = options or {}
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(buf)
  local win = vim.api.nvim_get_current_win()
  configure_window(win)
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile, vim.bo[buf].filetype = false, 'kitty_lua_terminal'
  local cw, ch, source = Tty.cell_size()
  cw, ch = options.cell_width or cw or 8, options.cell_height or ch or 16
  local foreground, background = palette_defaults()
  local colors = options.colors
  if colors then
    foreground, background = colors.foreground, colors.background
    -- 原生终端在创建时读取 buffer 调色板；之后的 SGR 同样使用这份颜色。
    for index, color in pairs(colors.palette) do
      if index < 16 then vim.b[buf]['terminal_color_' .. index] = color end
    end
  end
  local term = setmetatable({
    buf = buf,
    options = options,
    capture = false,
    display_pending = {},
    cell_width = cw,
    cell_height = ch,
    cell_size_source = source,
    palette = colors and vim.deepcopy(colors.palette) or {},
    row_ids = {},
    overlays = {},
    foreground = foreground,
    background = background,
    cursor_color = colors and colors.cursor or foreground,
    errors = {},
    stats = { input_bytes = 0, output_bytes = 0, host_bytes = 0, graphics_replies = 0 }
  }, Term)
  term.screen = Screen.new(vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win),
    { scrollback = options.scrollback or 2000 })
  term.view_channel = vim.api.nvim_open_term(buf, {
    force_crlf = false,
    on_input = function(_, _, _, bytes)
      -- on_input 已经过 Nvim 的 Terminal-mode/鼠标/粘贴处理；这里只转换
      -- 子程序协商的 Kitty 编码，不接管编辑器全局键盘或 vim.paste。
      if term.closed or term.exited then return end
      term.stats.native_input_calls = (term.stats.native_input_calls or 0) + 1
      term:send(Input.terminal(term, bytes))
      term.input_generation = (term.input_generation or 0) + 1
      local generation = term.input_generation
      -- 新输入到达就淘汰旧定时器，避免把尚在拼接的序列误判成独立 Alt 键。
      local pending = term._terminal_input.pending
      if pending == ESC or pending == ESC .. '[' or pending == ESC .. 'O' then
        vim.defer_fn(function()
          if not term.closed and not term.exited and generation == term.input_generation then
            term:send(Input.terminal(term, ''))
          end
        end, 30)
      end
    end
  })
  assert(term.view_channel > 0, 'KittyLuaTerm: failed to create terminal view')
  if colors then require('experimental.kitty_terminal.colors').apply(win, colors) end
  vim.bo[buf].scrollback = options.scrollback or 2000
  vim.b[buf].kitty_lua_view_channel = term.view_channel
  Render.attach(term)
  term.graphics = Graphics.new(term)
  term.parser = Parser.new(term.screen, {
    -- csi 返回 true 表示 Lua 已消费（通常已应答），false 才交给屏幕更新。
    csi = function(body, final) return Protocol.csi(term, body, final) end,
    string = function(kind, body, terminator) Protocol.string(term, kind, body, terminator) end,
    bell = function() end,
    error = function(err) term.errors[#term.errors + 1] = tostring(err) end,
  })
  sessions[buf] = term
  vim.api.nvim_buf_set_name(buf, 'kitty-lua://' .. buf)
  local command = options.cmd or { vim.o.shell }
  if type(command) == 'string' then command = { vim.o.shell, '-c', command } end
  -- The shell waits until all four kernel winsize fields are populated. icat
  -- reads ioctl immediately on startup, before emitting any query sequence.
  local bootstrap = { '/bin/sh', '-c',
    'stty -echo; printf "\\033P=kitty-lua-ready\\033\\\\"; IFS= read -r ready; stty echo; exec "$@"', 'kitty-lua-pty' }
  vim.list_extend(bootstrap, command)
  local env = vim.tbl_extend('force', {
    TERM = 'xterm-kitty',
    COLORTERM = 'truecolor',
    TERM_PROGRAM = 'kitty-lua',
    -- 不继承外层 Kitty 的远控地址/窗口 ID，让客户端经当前 PTY 协商能力。
    KITTY_LISTEN_ON = '',
    KITTY_WINDOW_ID = ''
  }, options.env or {})
  term.job = vim.fn.jobstart(bootstrap, {
    pty = true,
    width = term.screen.cols,
    height = term.screen.rows,
    cwd = options.cwd,
    env = env,
    on_stdout = function(_, data)
      -- Job callbacks encode NL as list boundaries and NUL inside strings
      -- as NL. Restore NUL first, then join: binary images remain intact.
      local parts = {}
      for i, part in ipairs(data) do parts[i] = part:gsub('\n', '\0') end
      term:feed(table.concat(parts, '\n'))
    end,
    on_exit = function(_, code)
      term.exited, term.exit_code = true, code
      HostInput.close(term)
      term:refresh()
    end,
  })
  if term.job <= 0 then
    term:close(); error('KittyLuaTerm: jobstart failed: ' .. term.job)
  end
  local pixel_ok, pixel_err = Tty.resize(term.job, term.screen.cols, term.screen.rows, cw, ch)
  if not pixel_ok then term.pixel_size_error = pixel_err end
  vim.b[buf].kitty_lua_job = term.job
  term:refresh()
  if options.capture ~= false then vim.schedule(function() term:enter() end) end
  return term
end

function M.current() return sessions[vim.api.nvim_get_current_buf()] end

function M.stop()
  local t = M.current(); if t then t:close() end
end

function M.setup()
  vim.api.nvim_clear_autocmds({ group = group })
  vim.api.nvim_create_autocmd({ 'WinResized', 'VimResized', 'BufWinEnter', 'TabEnter' }, {
    group = group,
    callback = function()
      vim.schedule(function() for _, term in pairs(sessions) do term:resize() end end)
    end
  })
  vim.api.nvim_create_autocmd({ 'WinScrolled', 'WinClosed', 'BufWinLeave' }, {
    group = group,
    callback = function() vim.schedule(function() for _, term in pairs(sessions) do term:refresh() end end) end
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(ev)
      if sessions[ev.buf] then sessions[ev.buf]:close() end
    end
  })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      for _, term in pairs(sessions) do term:close() end
    end
  })
  vim.api.nvim_create_autocmd('TermResponse', {
    group = group,
    callback = function(ev)
      local seq = ev.data.sequence
      if Graphics.response(seq) then return end
      local kind, body = seq:match('^' .. ESC .. '([%]P_])(.*)')
      kind = ({ [']'] = 'osc', P = 'dcs', _ = 'apc' })[kind]
      if not kind then return end
      local owner
      -- 普通字符串响应没有可靠请求 ID；多个候选会话时不猜归属，避免串流。
      for candidate, deadline in pairs(routes[route_key(kind, body)] or {}) do
        if deadline > vim.uv.hrtime() and not candidate.closed and not candidate.exited then
          if owner then return end
          owner = candidate
        end
      end
      if owner then owner:send(seq:sub(-2) == ST and seq or seq .. ST) end
    end
  })
  vim.api.nvim_create_autocmd({ 'TermEnter', 'TermLeave' }, {
    group = group,
    callback = function(ev)
      local term = sessions[ev.buf]
      if term then
        term.capture = ev.event == 'TermEnter'
        HostInput.capture(term)
        term:refresh()
      end
    end
  })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'FocusLost' }, {
    group = group,
    callback = function(ev)
      for _, term in pairs(sessions) do HostInput.focus(term, ev.event == 'FocusGained') end
    end,
  })
  local paint_pending = false
  vim.api.nvim_set_decoration_provider(paint_ns, {
    on_end = function()
      if paint_pending or not next(sessions) then return end
      paint_pending = true
      vim.schedule(function()
        paint_pending = false
        -- Paint after Nvim's own flush, including Terminal-mode cursor and
        -- focus redraws. Do not redraw/write the view again from this hook.
        for _, term in pairs(sessions) do Render.paint(term) end
      end)
    end
  })
  vim.api.nvim_create_user_command('KittyLuaTerm', function(args)
    M.open({ cmd = args.args ~= '' and { vim.o.shell, '-c', args.args } or nil })
  end, { nargs = '*', complete = 'shellcmd', force = true })
  vim.api.nvim_create_user_command('KittyLuaTermStop', M.stop, { force = true })
  vim.api.nvim_create_user_command('KittyLuaTermStatus', function()
    local term = M.current()
    if term then
      vim.print({
        job = term.job,
        exited = term.exited,
        exit_code = term.exit_code,
        cells = { term.screen.cols, term.screen.rows },
        pixels = { term.cell_width, term.cell_height },
        pixel_size_error = term.pixel_size_error,
        color_error = term.color_error,
        keyboard_error = term.keyboard_error,
        keyboard_flags = term.keyboard_flags,
        capture = term.capture,
        errors = term.errors,
        stats = term.stats
      })
    end
  end, { force = true })
  return M
end

M.sessions, M.Term = sessions, Term
return M.setup()
