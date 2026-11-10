-- 协议侧影子屏幕：提供查询坐标、滚动历史和图像锚点；实际显示由原生 terminal 完成。
-- row/col、top/bottom 均从 1 开始；行 id 不随滚屏变化，render 才映射成 buffer 行号。
-- cell.width=0 是宽字符的占位尾格；组合字符附着前一个字符，不另占网格列。
local Screen = {}
Screen.__index = Screen
local function clamp(value, low, high)
  return math.max(low, math.min(high, value))
end
local function copy(value)
  return vim.tbl_extend("force", {}, value)
end
local function dimensions(cols, rows)
  assert(type(cols) == "number" and cols >= 1 and cols % 1 == 0, "screen columns must be a positive integer")
  assert(type(rows) == "number" and rows >= 1 and rows % 1 == 0, "screen rows must be a positive integer")
end
local function blank(attr)
  return { text = " ", width = 1, attr = attr }
end
function Screen:_line()
  self.next_id = self.next_id + 1
  local line = { id = self.next_id }
  for col = 1, self.cols do
    line[col] = blank(self.attr)
  end
  return line
end
function Screen.new(cols, rows, opts)
  dimensions(cols, rows)
  local self = setmetatable({
    cols = cols,
    rows = rows,
    row = 1,
    col = 1,
    grid = {},
    history = {},
    next_id = 0,
    attr = {},
    modes = { wrap = true, cursor_visible = true },
    alt = false,
    scrollback = (opts or {}).scrollback or 1000,
    top = 1,
    bottom = rows,
    tabs = {},
  }, Screen)
  assert(self.scrollback >= 0 and self.scrollback % 1 == 0, "scrollback must be a nonnegative integer")
  for row = 1, rows do
    self.grid[row] = self:_line()
  end
  for col = 9, cols, 8 do
    self.tabs[col] = true
  end
  return self
end
function Screen:line_id()
  return self.grid[self.row].id
end
function Screen:_remember(line)
  if self.alt or self.scrollback == 0 then
    return
  end
  self.history[#self.history + 1] = line
  if #self.history > self.scrollback then
    table.remove(self.history, 1)
  end
end
function Screen:_scroll(count, down, discard)
  count = math.min(count, self.bottom - self.top + 1)
  for _ = 1, count do
    if down then
      table.remove(self.grid, self.bottom)
      table.insert(self.grid, self.top, self:_line())
    else
      local removed = table.remove(self.grid, self.top)
      if not discard and self.top == 1 and self.bottom == self.rows then
        self:_remember(removed)
      end
      table.insert(self.grid, self.bottom, self:_line())
    end
  end
end
function Screen:_index(reverse)
  self.pending_wrap = false
  if reverse then
    if self.row == self.top then
      self:_scroll(1, true)
    else
      self.row = math.max(1, self.row - 1)
    end
  else
    if self.row == self.bottom then
      self:_scroll(1)
    else
      self.row = math.min(self.rows, self.row + 1)
    end
  end
end
function Screen:_clear(line, first, last)
  if first > last then
    return
  end
  while first > 1 and line[first] and line[first].width == 0 do
    first = first - 1
  end
  local lead = last
  while lead > 1 and line[lead] and line[lead].width == 0 do
    lead = lead - 1
  end
  if line[lead] then
    last = math.min(self.cols, math.max(last, lead + line[lead].width - 1))
  end
  for col = first, last do
    line[col] = blank(self.attr)
  end
end
function Screen:_repair(line)
  -- 编辑/缩窄可能截断宽字符，清除孤立尾格或缺少尾格的首格，维持整字占位。
  local continuation = 0
  for col = 1, self.cols do
    local cell = line[col]
    local valid = cell and cell.width > 0 and col + cell.width - 1 <= self.cols
    if valid then
      for offset = 1, cell.width - 1 do
        if not line[col + offset] or line[col + offset].width ~= 0 then
          valid = false
        end
      end
    end
    if continuation > 0 and cell and cell.width == 0 then
      continuation = continuation - 1
    elseif valid then
      continuation = cell.width - 1
    else
      line[col] = blank(self.attr)
      continuation = 0
    end
  end
  for col = #line, self.cols + 1, -1 do
    line[col] = nil
  end
end
function Screen:put(text, width)
  width = width or (vim.fn.strdisplaywidth("a" .. text) - 1)
  assert(type(width) == "number" and width >= 0 and width % 1 == 0, "cell width must be a nonnegative integer")
  if width == 0 then
    local col = self.pending_wrap and self.col or self.col - 1
    local line = self.grid[self.row]
    while col > 0 and line[col].width == 0 do
      col = col - 1
    end
    if col > 0 then
      local cell = line[col]
      line[col] = { text = cell.text .. text, width = cell.width, attr = cell.attr }
    end
    return
  end
  if self.pending_wrap or (width > self.cols - self.col + 1 and self.modes.wrap) then
    if self.modes.wrap then
      self.col = 1
      self:_index()
    end
    self.pending_wrap = false
  end
  if width > self.cols - self.col + 1 then
    return
  end
  if self.modes.insert then
    self:_edit_chars(width, true)
  end
  local line = self.grid[self.row]
  self:_clear(line, self.col, self.col + width - 1)
  line[self.col] = { text = text, width = width, attr = self.attr }
  for offset = 1, width - 1 do
    line[self.col + offset] = { text = "", width = 0, attr = self.attr }
  end
  -- 右边界采用延迟换行：写到最后一格不立刻滚屏，下一次可见字符才触发。
  if self.col + width > self.cols then
    self.col = self.cols
    self.pending_wrap = true
  else
    self.col = self.col + width
  end
end
function Screen:write(text)
  for char in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    local codepoint = vim.fn.char2nr(char)
    -- Neovim displays isolated combining marks with a placeholder; terminal marks attach instead.
    local width = vim.fn.strdisplaywidth("a" .. char) - 1
    if codepoint < 32 or codepoint == 127 then
      self:control(char)
    else
      self:put(char, width)
    end
  end
end
function Screen:control(byte)
  if byte == "\r" then
    self.col = 1
    self.pending_wrap = false
  elseif byte == "\n" or byte == "\11" or byte == "\12" then
    self:_index()
    if self.modes.newline then
      self.col = 1
    end
  elseif byte == "\8" then
    self.col = math.max(1, self.col - 1)
    self.pending_wrap = false
  elseif byte == "\t" then
    local col = self.col + 1
    while col < self.cols and not self.tabs[col] do
      col = col + 1
    end
    self.col = math.min(col, self.cols)
    self.pending_wrap = false
  end
end
function Screen:_save()
  self.saved = {
    row = self.row,
    col = self.col,
    attr = self.attr,
    origin = self.modes.origin,
    wrap = self.modes.wrap,
    pending_wrap = self.pending_wrap,
  }
end
function Screen:_restore()
  if not self.saved then
    return
  end
  self.row = clamp(self.saved.row, 1, self.rows)
  self.col = clamp(self.saved.col, 1, self.cols)
  self.attr = self.saved.attr
  self.modes.origin = self.saved.origin
  self.modes.wrap = self.saved.wrap
  self.pending_wrap = self.saved.pending_wrap
end
function Screen:escape(byte)
  if byte == "7" then
    self:_save()
  elseif byte == "8" then
    self:_restore()
  elseif byte == "D" then
    self:_index()
  elseif byte == "M" then
    self:_index(true)
  elseif byte == "E" then
    self.col = 1
    self:_index()
  elseif byte == "H" then
    self.tabs[self.col] = true
  elseif byte == "c" then
    local fresh = Screen.new(self.cols, self.rows, { scrollback = self.scrollback })
    fresh.next_id = self.next_id
    for row = 1, self.rows do
      fresh.grid[row] = fresh:_line()
    end
    for key in pairs(self) do
      self[key] = nil
    end
    for key, value in pairs(fresh) do
      self[key] = value
    end
  end
end
function Screen:_alternate(enabled, mode)
  -- 备用屏幕不带主屏历史；保留主屏坐标/网格以便 TUI 退出后恢复 shell 内容。
  if enabled == self.alt then
    return
  end
  if enabled then
    self.primary = {
      grid = self.grid,
      row = self.row,
      col = self.col,
      saved = self.saved,
      top = self.top,
      bottom = self.bottom,
      attr = self.attr,
      pending_wrap = self.pending_wrap,
    }
    if self.alternate and mode ~= 1049 then
      self.grid = self.alternate
      for _, line in ipairs(self.grid) do
        self:_repair(line)
      end
      while #self.grid > self.rows do
        table.remove(self.grid)
      end
      while #self.grid < self.rows do
        self.grid[#self.grid + 1] = self:_line()
      end
    else
      self.grid = {}
      for row = 1, self.rows do
        self.grid[row] = self:_line()
      end
    end
    self.row = 1
    self.col = 1
    self.top = 1
    self.bottom = self.rows
    self.saved = nil
    self.pending_wrap = false
  else
    self.alternate = mode ~= 1047 and self.grid or nil
    for key, value in pairs(self.primary) do
      self[key] = value
    end
    self.saved = self.primary.saved
    self.pending_wrap = self.primary.pending_wrap
    self.primary = nil
  end
  self.alt = enabled
end
function Screen:_mode(params, private, enabled)
  local names = {
    [1] = "app_cursor",
    [6] = "origin",
    [7] = "wrap",
    [25] = "cursor_visible",
    [1000] = "mouse_button",
    [1002] = "mouse_drag",
    [1003] = "mouse_motion",
    [1004] = "focus",
    [1006] = "mouse_sgr",
    [1016] = "mouse_pixel",
    [2004] = "bracketed_paste",
  }
  for _, mode in ipairs(params) do
    if private and (mode == 47 or mode == 1047 or mode == 1049) then
      self:_alternate(enabled, mode)
    elseif private and mode == 1048 then
      if enabled then
        self:_save()
      else
        self:_restore()
      end
    elseif private and names[mode] then
      self.modes[names[mode]] = enabled
      if mode == 6 then
        self.row = enabled and self.top or 1
        self.col = 1
        self.pending_wrap = false
      end
    elseif not private and mode == 4 then
      self.modes.insert = enabled
    elseif not private and mode == 20 then
      self.modes.newline = enabled
    end
  end
  self.modes.mouse = self.modes.mouse_motion and 1003
    or self.modes.mouse_drag and 1002
    or self.modes.mouse_button and 1000
    or false
end
function Screen:_sgr(params)
  -- 每次复制属性，已写入单元格持有旧快照；后续 SGR 不能追溯修改过去的文字。
  local attr = copy(self.attr)
  local styles = { [1] = "bold", [3] = "italic", [4] = "underline", [7] = "reverse", [9] = "strikethrough" }
  local resets = { [22] = "bold", [23] = "italic", [24] = "underline", [27] = "reverse", [29] = "strikethrough" }
  local i = 1
  while i <= #params do
    local code = params[i]
    if code == 0 then
      attr = {}
    elseif styles[code] then
      attr[styles[code]] = true
    elseif resets[code] then
      attr[resets[code]] = nil
    elseif code == 39 then
      attr.fg = nil
    elseif code == 49 then
      attr.bg = nil
    elseif code >= 30 and code <= 37 then
      attr.fg = code - 30
    elseif code >= 40 and code <= 47 then
      attr.bg = code - 40
    elseif code >= 90 and code <= 97 then
      attr.fg = code - 90 + 8
    elseif code >= 100 and code <= 107 then
      attr.bg = code - 100 + 8
    elseif code == 38 or code == 48 then
      local key = code == 38 and "fg" or "bg"
      if params[i + 1] == 5 and params[i + 2] then
        attr[key] = clamp(params[i + 2], 0, 255)
        i = i + 2
      elseif params[i + 1] == 2 and params[i + 4] then
        attr[key] = string.format(
          "#%02x%02x%02x",
          clamp(params[i + 2], 0, 255),
          clamp(params[i + 3], 0, 255),
          clamp(params[i + 4], 0, 255)
        )
        i = i + 4
      end
    end
    i = i + 1
  end
  self.attr = attr
end
function Screen:_edit_chars(count, insert)
  local line = self.grid[self.row]
  count = math.min(count, self.cols - self.col + 1)
  for _ = 1, count do
    if insert then
      table.insert(line, self.col, blank(self.attr))
      table.remove(line)
    else
      table.remove(line, self.col)
      line[self.cols] = blank(self.attr)
    end
  end
  self:_repair(line)
end
function Screen:_erase_display(mode)
  if mode == 3 then
    self.history = {}
    return
  end
  if mode == 2 then
    for _, line in ipairs(self.grid) do
      self:_clear(line, 1, self.cols)
    end
    return
  end
  if mode == 0 then
    self:_clear(self.grid[self.row], self.col, self.cols)
    for row = self.row + 1, self.rows do
      self:_clear(self.grid[row], 1, self.cols)
    end
  elseif mode == 1 then
    for row = 1, self.row - 1 do
      self:_clear(self.grid[row], 1, self.cols)
    end
    self:_clear(self.grid[self.row], 1, self.col)
  end
end
function Screen:csi(body, final)
  local private = body:sub(1, 1) == "?"
  if body:find("[<=>]") or body:find("[ !\"#$&'()*+,%-./]") then
    return
  end
  local params = {}
  if final == "m" then
    body = body:gsub("([34]8):2::", "%1:2:"):gsub("([34]8):2:0:", "%1:2:")
  end
  -- Accept both SGR separators; empty/default arguments become zero.
  for value in (body:gsub("^%?", "") .. ";"):gmatch("(.-);") do
    if value:find(":") then
      for part in (value .. ":"):gmatch("(.-):") do
        params[#params + 1] = tonumber(part) or 0
      end
    else
      params[#params + 1] = tonumber(value) or 0
    end
  end
  local n = params[1] == 0 and 1 or params[1]
  local low, high = self.modes.origin and self.top or 1, self.modes.origin and self.bottom or self.rows
  if final == "m" then
    self:_sgr(params)
    return
  end
  if final == "h" or final == "l" then
    self:_mode(params, private, final == "h")
    return
  end
  if private then
    return
  end
  if final == "s" then
    self:_save()
    return
  end
  if final == "u" then
    self:_restore()
    return
  end
  self.pending_wrap = false
  if final == "A" then
    self.row = clamp(self.row - n, low, high)
  elseif final == "B" or final == "e" then
    self.row = clamp(self.row + n, low, high)
  elseif final == "C" or final == "a" then
    self.col = math.min(self.cols, self.col + n)
  elseif final == "D" then
    self.col = math.max(1, self.col - n)
  elseif final == "E" then
    self.row = clamp(self.row + n, low, high)
    self.col = 1
  elseif final == "F" then
    self.row = clamp(self.row - n, low, high)
    self.col = 1
  elseif final == "G" or final == "`" then
    self.col = clamp(n, 1, self.cols)
  elseif final == "d" then
    self.row = clamp(n + low - 1, low, high)
  elseif final == "H" or final == "f" then
    self.row = clamp(n + low - 1, low, high)
    self.col = clamp(math.max(1, params[2] or 1), 1, self.cols)
  elseif final == "J" then
    self:_erase_display(params[1])
  elseif final == "K" then
    local mode = params[1]
    if mode <= 2 then
      self:_clear(self.grid[self.row], mode == 0 and self.col or 1, mode == 1 and self.col or self.cols)
    end
  elseif final == "X" then
    self:_clear(self.grid[self.row], self.col, math.min(self.cols, self.col + n - 1))
  elseif final == "@" or final == "P" then
    self:_edit_chars(n, final == "@")
  elseif final == "S" or final == "T" then
    self:_scroll(n, final == "T")
  elseif final == "L" or final == "M" then
    if self.row < self.top or self.row > self.bottom then
      return
    end
    local top = self.top
    self.top = self.row
    self:_scroll(n, final == "L", true)
    self.top = top
  elseif final == "r" then
    local bottom = params[2] or self.rows
    if bottom == 0 then
      bottom = self.rows
    end
    if n < bottom and bottom <= self.rows then
      self.top = n
      self.bottom = bottom
      self.row = self.modes.origin and n or 1
      self.col = 1
    end
  elseif final == "g" then
    if params[1] == 3 then
      self.tabs = {}
    else
      self.tabs[self.col] = nil
    end
  elseif final == "I" then
    for _ = 1, math.min(n, self.cols) do
      self:control("\t")
    end
  elseif final == "Z" then
    for _ = 1, math.min(n, self.cols) do
      repeat
        self.col = math.max(1, self.col - 1)
      until self.col == 1 or self.tabs[self.col]
    end
  end
end
function Screen:resize(cols, rows)
  -- 按行裁剪/补格，不做段落 reflow；保留存活行 ID，供图像继续跟随原始内容。
  dimensions(cols, rows)
  local old_cols = self.cols
  self.cols = cols
  for _, line in ipairs(self.history) do
    self:_repair(line)
  end
  for _, line in ipairs(self.grid) do
    self:_repair(line)
  end
  while #self.grid > rows do
    if self.row > rows then
      self:_remember(table.remove(self.grid, 1))
      self.row = self.row - 1
    else
      table.remove(self.grid)
    end
  end
  while #self.grid < rows do
    self.grid[#self.grid + 1] = self:_line()
  end
  self.rows = rows
  self.row = clamp(self.row, 1, rows)
  self.col = clamp(self.col, 1, cols)
  self.top = 1
  self.bottom = rows
  self.pending_wrap = false
  for col = old_cols + 1, cols do
    if (col - 1) % 8 == 0 then
      self.tabs[col] = true
    end
  end
  if self.primary then
    local active = { grid = self.grid, row = self.row, col = self.col, attr = self.attr, saved = self.saved }
    local primary = self.primary
    self.primary = nil
    self.alt = false
    for key, value in pairs(primary) do
      self[key] = value
    end
    self:resize(cols, rows)
    primary.grid = self.grid
    primary.row = self.row
    primary.col = self.col
    primary.top = 1
    primary.bottom = rows
    primary.pending_wrap = false
    for key, value in pairs(active) do
      self[key] = value
    end
    self.top = 1
    self.bottom = rows
    self.pending_wrap = false
    self.saved = active.saved
    self.primary = primary
    self.alt = true
  end
end
function Screen:render()
  -- lines 为历史+活动屏幕；spans 用零基字节偏移，row_ids 的目标是一基 buffer 行。
  -- 原生 renderer 只使用 row_ids，文本/spans 仍供独立屏幕测试和状态检查。
  local lines, spans, row_ids = {}, {}, {}
  local function append(line)
    local pieces, offset = {}, 0
    local row = #lines
    row_ids[line.id] = row + 1
    for _, cell in ipairs(line) do
      pieces[#pieces + 1] = cell.text
      if cell.text ~= "" and next(cell.attr) then
        spans[#spans + 1] = { row = row, col = offset, end_col = offset + #cell.text, attr = cell.attr }
      end
      offset = offset + #cell.text
    end
    lines[#lines + 1] = table.concat(pieces)
  end
  if not self.alt then
    for _, line in ipairs(self.history) do
      append(line)
    end
  end
  for _, line in ipairs(self.grid) do
    append(line)
  end
  return lines, spans, row_ids
end
-- TODO: Reflow wrapped paragraphs on resize and implement DEC special-graphics character mapping.
return Screen
