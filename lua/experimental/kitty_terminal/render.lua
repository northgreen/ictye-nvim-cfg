-- Native terminal presentation. The Lua grid still owns protocol/query state;
-- this channel receives only ordinary text/ANSI, never raw child Kitty packets.
local M = {}
local ESC = '\27'
local Protocol = require('experimental.kitty_terminal.protocol')
local function sgr(term)
  local attr, parts = term.screen.attr, { '0' }
  for flag, code in pairs({ bold = 1, italic = 3, underline = 4, reverse = 7, strikethrough = 9 }) do
    if attr[flag] then parts[#parts + 1] = tostring(code) end
  end
  for key, code in pairs({ fg = 38, bg = 48 }) do
    local color = attr[key]
    if type(color) == 'number' then color = (term.palette or {})[color] or Protocol.color(color) end
    if color then
      local r, g, b = color:match('^#(%x%x)(%x%x)(%x%x)$')
      if r then parts[#parts + 1] = string.format('%d;2;%d;%d;%d', code, tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)) end
    end
  end
  return ESC .. '[' .. table.concat(parts, ';') .. 'm'
end
function M.views(term)
  -- 宿主坐标从 1 开始，剔除 gutter 后才是终端内容原点；只绘制当前 tab 的视图。
  local views = {}
  for _, win in ipairs(vim.fn.win_findbuf(term.buf)) do
    if vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage() then
      local info = vim.fn.getwininfo(win)[1]
      local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
      views[#views + 1] = {
        win = win,
        row = info.winrow,
        col = info.wincol + info.textoff,
        cols = info.width - info.textoff,
        rows = info.height,
        topline = view.topline,
        leftcol = view.leftcol
      }
    end
  end
  return views
end

function M.attach(term)
  -- 只镜像最外层 screen 操作：write 内部调用 control 等方法时不能重复发送 ANSI。
  local depth = 0
  local encoders = {
    write = function(text) return text end,
    control = function(byte) return byte end,
    escape = function(byte) return ESC .. byte end,
    csi = function(body, final)
      -- Internal terminal OSC4 does not reliably update its indexed
      -- palette. Resolve the Lua palette to native truecolor SGR instead.
      if final == 'm' then return sgr(term) end
      -- Modes/queries that Lua owns must not leak back to Nvim's input
      -- protocol. In particular Nvim supplies cell mouse coordinates;
      -- input.lua performs the child's pixel conversion itself.
      if body == '?1016' then return '' end
      if ('ABCDEFGHfJKX@PLMSTrsugIZ`adehlm'):find(final, 1, true) then return ESC .. '[' .. body .. final end
      return ''
    end,
  }
  for name, encode in pairs(encoders) do
    local original = term.screen[name]
    term.screen[name] = function(screen, ...)
      local outer = depth == 0
      depth = depth + 1
      local ok, err = pcall(original, screen, ...)
      depth = depth - 1
      if not ok then error(err) end
      if outer then term:display(encode(...)) end
      -- RIS replaces all instance fields, including these presentation
      -- wrappers. Reinstall them on the fresh Lua screen as well.
      if name == 'escape' and select(1, ...) == 'c' then M.attach(term) end
    end
  end
end

function M.draw(term)
  -- Lua 内容行 ID -> 原生 buffer 行号；发送普通 ANSI 后先让 Nvim 完成文字刷新。
  if term.closed or not vim.api.nvim_buf_is_valid(term.buf) then return end
  local _, _, ids = term.screen:render()
  term.row_ids = ids
  if #term.display_pending > 0 then
    local bytes = table.concat(term.display_pending)
    term.display_pending = {}
    vim.api.nvim_chan_send(term.view_channel, bytes)
  end
  -- Nvim maintains terminal cells, highlights, cursor and scrollback. It also
  -- owns Terminal-mode input and the normal-mode scrollback view.
  vim.cmd('redraw')
  M.paint(term)
  if term.exited and not term.view_closed then
    term.view_closed = true
    pcall(vim.fn.chanclose, term.view_channel)
  end
end

function M.paint(term)
  -- decoration provider 也会调用：只补画宿主图形，不写内部通道、不触发递归 redraw。
  if term.closed or not vim.api.nvim_buf_is_valid(term.buf) then return end
  local ids = term.row_ids
  term.graphics:draw(M.views(term), true)
  for _, overlay in ipairs(term.overlays) do
    local line = ids[overlay.line_id]
    for _, view in ipairs(M.views(term)) do
      if line and line >= view.topline and line < view.topline + view.rows and overlay.col < view.cols then
        local row, col = view.row + line - view.topline, view.col + overlay.col
        term:host_send(ESC .. '7' .. string.format(ESC .. '[%d;%dH', row, col) .. overlay.wire .. ESC .. '8')
      end
    end
  end
end

return M
