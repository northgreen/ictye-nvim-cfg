-- Translate Nvim input keys into the child PTY's negotiated input protocol.
-- 原生终端入口为 terminal(term, data)，参数是 on_input 字节流，不是 Nvim 内部 keycode。
-- encode/paste 保留为直接编码辅助接口，主控制器不通过它们拦截全局输入。
local M = {}
local ESC = "\27"
local keys = {
  ["<CR>"] = "\r",
  ["<NL>"] = "\n",
  ["<BS>"] = "\127",
  ["<Tab>"] = "\t",
  ["<Esc>"] = ESC,
  ["<Space>"] = " ",
  ["<lt>"] = "<",
  ["<Bslash>"] = "\\",
  ["<Up>"] = ESC .. "[A",
  ["<Down>"] = ESC .. "[B",
  ["<Right>"] = ESC .. "[C",
  ["<Left>"] = ESC .. "[D",
  ["<Home>"] = ESC .. "[H",
  ["<End>"] = ESC .. "[F",
  ["<Insert>"] = ESC .. "[2~",
  ["<Del>"] = ESC .. "[3~",
  ["<PageUp>"] = ESC .. "[5~",
  ["<PageDown>"] = ESC .. "[6~",
  ["<S-Tab>"] = ESC .. "[Z",
  ["<F1>"] = ESC .. "OP",
  ["<F2>"] = ESC .. "OQ",
  ["<F3>"] = ESC .. "OR",
  ["<F4>"] = ESC .. "OS",
  ["<F5>"] = ESC .. "[15~",
  ["<F6>"] = ESC .. "[17~",
  ["<F7>"] = ESC .. "[18~",
  ["<F8>"] = ESC .. "[19~",
  ["<F9>"] = ESC .. "[20~",
  ["<F10>"] = ESC .. "[21~",
  ["<F11>"] = ESC .. "[23~",
  ["<F12>"] = ESC .. "[24~",
}
local mouse = {
  LeftMouse = 0,
  MiddleMouse = 1,
  RightMouse = 2,
  LeftDrag = 32,
  MiddleDrag = 33,
  RightDrag = 34,
  ScrollWheelUp = 64,
  ScrollWheelDown = 65,
}

function M.encode(key, term)
  local name = vim.fn.keytrans(key)
  if name:find("Mouse") or name:find("Drag") or name:find("Release") or name:find("ScrollWheel") then
    local pos = vim.fn.getmousepos()
    if pos.winid == 0 or pos.line == 0 then
      return ""
    end
    local rows = term.screen.alt and 0 or #term.screen.history
    local row = math.max(1, math.min(term.screen.rows, pos.line - rows))
    local col = math.max(1, math.min(term.screen.cols, pos.column))
    if pos.screencol and pos.screencol > 0 and vim.api.nvim_win_is_valid(pos.winid) then
      local info = vim.fn.getwininfo(pos.winid)[1]
      local view = vim.api.nvim_win_call(pos.winid, vim.fn.winsaveview)
      col = math.max(1, math.min(term.screen.cols, pos.screencol - info.wincol - info.textoff + 1 + view.leftcol))
    end
    if term.screen.modes.mouse_pixel then
      col = (col - 1) * term.cell_width + math.max(1, math.floor(term.cell_width / 2))
      row = (row - 1) * term.cell_height + math.max(1, math.floor(term.cell_height / 2))
    end
    local event = name:match("<([^>]+)>")
    local release = event and event:find("Release") ~= nil
    local button = mouse[event] or (release and 0)
    if term.screen.modes.mouse and button then
      return string.format(ESC .. "[<%d;%d;%d%s", button, col, row, release and "m" or "M")
    end
    if event == "ScrollWheelUp" or event == "ScrollWheelDown" then
      vim.cmd("normal! " .. (event == "ScrollWheelUp" and "3\25" or "3\5"))
      term:refresh()
    end
    return ""
  end
  local seq = keys[name]
  if
    term.screen.modes.app_cursor
    and seq
    and ({ ["<Up>"] = true, ["<Down>"] = true, ["<Right>"] = true, ["<Left>"] = true })[name]
  then
    seq = seq:gsub("%[", "O", 1)
  end
  local modifier, plain = name:match("^<([CMSA])%-(.)>$")
  if not seq and modifier then
    if modifier == "C" then
      seq = string.char(plain:upper():byte() % 32)
    elseif modifier == "S" then
      seq = plain:upper()
    else
      seq = ESC .. plain
    end
  end
  if not seq and key:byte(1) ~= 128 then
    seq = key
  end
  local flags = term.keyboard_flags or 0
  if require("bit").band(flags, 8) ~= 0 then
    local code = ({
      ["<CR>"] = 13,
      ["<NL>"] = 10,
      ["<Tab>"] = 9,
      ["<BS>"] = 127,
      ["<Esc>"] = 27,
      ["<Space>"] = 32,
      ["<lt>"] = 60,
    })[name]
    local mods = 1
    if modifier then
      code = vim.fn.char2nr(plain:lower())
      mods = ({ C = 5, M = 3, A = 3, S = 2 })[modifier]
    elseif key:byte(1) ~= 128 and name:sub(1, 1) ~= "<" then
      code = vim.fn.char2nr(key)
    end
    if code then
      local parameters = tostring(code) .. (mods ~= 1 and ";" .. mods or "")
      if require("bit").band(flags, 16) ~= 0 and code >= 32 and code ~= 127 and (mods == 1 or mods == 2) then
        parameters = tostring(code) .. ";" .. (mods ~= 1 and mods or "") .. ";" .. vim.fn.char2nr(plain or key)
      end
      seq = ESC .. "[" .. parameters .. "u"
    end
  elseif flags > 0 and name == "<Esc>" then
    seq = ESC .. "[27u"
  end
  return seq or ""
end

local bit = require("bit")
local paste_start, paste_end = ESC .. "[200~", ESC .. "[201~"

local function kitty_key(code, modifiers, text, flags)
  -- modifiers 是 Kitty 的 1+位掩码；关联文本是 Unicode 码点，不是 UTF-8 字节值。
  local parameters = tostring(code) .. (modifiers ~= 1 and ";" .. modifiers or "")
  if text and bit.band(flags, 16) ~= 0 then
    parameters = code .. ";" .. (modifiers ~= 1 and modifiers or "") .. ";" .. text
  end
  return ESC .. "[" .. parameters .. "u"
end

local function terminal_character(text, flags, alt)
  ---@type integer
  local code = text:byte() < 128 and text:byte() or vim.fn.char2nr(text)
  local modifiers = alt and 3 or 1
  if code == 27 and flags > 0 then
    return kitty_key(code, modifiers, nil, flags)
  end
  if bit.band(flags, 8) == 0 then
    return (alt and ESC or "") .. text
  end
  if code < 32 and code ~= 9 and code ~= 13 then
    code = code == 0 and 32 or code + (code < 27 and 96 or 64)
    modifiers = alt and 7 or 5
  end
  local associated = code >= 32 and code ~= 127 and modifiers == 1 and code or nil
  return kitty_key(code, modifiers, associated, flags)
end

local function terminal_sequence(term, sequence)
  local button, col, row, action = sequence:match("^" .. ESC .. "%[<(%d+);(%d+);(%d+)([Mm])$")
  if button and term.screen.modes.mouse_pixel then
    -- Nvim 已减去分屏原点；只能得到单元格精度，用格心近似子程序要求的像素位置。
    col = (tonumber(col) - 1) * term.cell_width + math.max(1, math.floor(term.cell_width / 2))
    row = (tonumber(row) - 1) * term.cell_height + math.max(1, math.floor(term.cell_height / 2))
    return string.format(ESC .. "[<%s;%d;%d%s", button, col, row, action)
  end
  if (term.keyboard_flags or 0) > 0 and sequence == ESC .. "[Z" then
    return kitty_key(9, 2, nil, term.keyboard_flags)
  end
  if (term.keyboard_flags or 0) > 0 and sequence:sub(2, 2) == "O" and sequence:match("[ABCDHFPQRS]$") then
    return ESC .. "[" .. sequence:sub(3)
  end
  return sequence
end

local function character_size(byte)
  if byte < 192 then
    return 1
  end
  if byte < 224 then
    return 2
  end
  if byte < 240 then
    return 3
  end
  return 4
end

local function terminal_token(data, flags, flush)
  if data:sub(1, 1) ~= ESC then
    local size = character_size(data:byte())
    if #data < size then
      return nil
    end
    return terminal_character(data:sub(1, size), flags), size
  end
  if #data == 1 then
    if flush then
      return terminal_character(ESC, flags), 1
    end
    return nil
  end
  local prefix = data:sub(2, 2)
  if prefix == "[" or prefix == "O" then
    local finish = data:find("[@-~]", 3)
    if not finish and #data == 2 and flush then
      return terminal_character(prefix, flags, true), 2
    end
    if not finish then
      return nil
    end
    return data:sub(1, finish), finish, true
  end
  if prefix == ESC then
    return terminal_character(ESC, flags), 1
  end
  local size = character_size(data:byte(2))
  if #data < size + 1 then
    return nil
  end
  return terminal_character(data:sub(2, size + 1), flags, true), size + 1
end

local function paste_chunk(state)
  -- 粘贴正文必须原样通过，不能变成逐键 CSI u；跨回调保留可能的结束标记前缀。
  local finish = state.pending:find(paste_end, 1, true)
  if finish then
    local last = finish + #paste_end - 1
    local output = state.pending:sub(1, last)
    state.pending, state.paste = state.pending:sub(last + 1), false
    return output
  end
  local keep = math.min(#state.pending, #paste_end - 1)
  while keep > 0 and state.pending:sub(-keep) ~= paste_end:sub(1, keep) do
    keep = keep - 1
  end
  local output = state.pending:sub(1, #state.pending - keep)
  state.pending = state.pending:sub(#state.pending - keep + 1)
  return output
end

-- 空输入表示调用方的歧义超时：刷出独立 ESC/Alt+[/Alt+O，不强行结束 UTF-8 或粘贴。
function M.terminal(term, data)
  local state = term._terminal_input or { pending = "", paste = false }
  term._terminal_input = state
  state.pending = state.pending .. data
  local output = {}
  while #state.pending > 0 do
    if state.paste then
      output[#output + 1] = paste_chunk(state)
      if state.paste then
        break
      end
    else
      local token, size, sequence = terminal_token(state.pending, term.keyboard_flags or 0, data == "")
      if not token then
        break
      end
      state.pending = state.pending:sub(size + 1)
      if token == paste_start then
        state.paste = true
      end
      output[#output + 1] = sequence and terminal_sequence(term, token) or token
    end
  end
  return table.concat(output)
end

function M.paste(term, text, phase)
  phase = phase or -1
  if term.screen.modes.bracketed_paste then
    local start = phase == 1 or phase == -1
    local finish = phase == 3 or phase == -1
    text = (start and ESC .. "[200~" or "") .. text .. (finish and ESC .. "[201~" or "")
  end
  term:send(text)
end

-- 隐藏输入通道已协商完整 CSI-u：保持事件类型与关联文本，不再按普通按键重编码。
function M.raw(term, bytes)
  local state = term._raw_input or { pending = "", pressed = {} }
  term._raw_input = state
  state.pending = state.pending .. bytes
  local output, leave = {}, false
  while #state.pending > 0 do
    if state.paste then
      output[#output + 1] = paste_chunk(state)
      if state.paste then
        break
      end
    else
      local token, size, sequence = terminal_token(state.pending, 0, false)
      if not token then
        break
      end
      state.pending = state.pending:sub(size + 1)
      if token == paste_start then
        state.paste, state.escape = true, false
      end
      local body, final = token:match("^" .. ESC .. "%[(.*)([@-~])$")
      local code, modifiers
      if body then
        code, modifiers = body:match("^([^;]+);?([^;]*)")
      end
      if body == "" and ("ABCDHFPQRS"):find(final, 1, true) then
        code, modifiers = "1", "1"
      end
      if sequence and token ~= paste_start and code and final ~= "I" and final ~= "O" and code:match("^%d") then
        local mods, event = modifiers:match("^(%d*):?(%d*)$")
        mods, event = tonumber(mods) or 1, tonumber(event) or 1
        local control = bit.band(mods - 1, 4) ~= 0
        if event ~= 3 and state.escape and code == "110" and control then
          state.escape, leave = false, true
        else
          if event ~= 3 then
            state.escape = code == "92" and control
          end
          local identity = code .. final
          if event == 3 then
            state.pressed[identity] = nil
          else
            state.pressed[identity] = ESC .. "[" .. code .. ";" .. mods .. ":3" .. final
          end
          output[#output + 1] = token
        end
      else
        output[#output + 1] = token
      end
    end
  end
  return table.concat(output), leave
end

function M.release(term)
  local state = term._raw_input
  if not state then
    return ""
  end
  local output = {}
  for _, identity in ipairs(vim.tbl_keys(state.pressed)) do
    output[#output + 1] = state.pressed[identity]
  end
  term._raw_input = nil
  return table.concat(output)
end

return M
