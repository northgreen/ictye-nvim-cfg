-- 原始输出的流式分帧器；一次 feed 不等于一条协议，UTF-8、ESC/ST 和载荷都可能拆包。
-- 普通文本/控制码更新 screen；完整 OSC/APC/DCS 交给回调，终止符与正文分开传递。
local Parser = {}
Parser.__index = Parser
local ESC, BEL = "\27", "\7"
local introductions = { ["]"] = "osc", ["_"] = "apc", ["P"] = "dcs" }
local encoded_c1 = { [0x90] = "P", [0x9b] = "[", [0x9d] = "]", [0x9f] = "_" }
function Parser.new(screen, callbacks)
  callbacks = callbacks or {}
  return setmetatable({
    screen = screen,
    callbacks = callbacks,
    state = "ground",
    utf8 = "",
    limit = callbacks.max_packet or 16 * 1024 * 1024,
    chunks = {},
    size = 0,
  }, Parser)
end
function Parser:_reset()
  self.state = "ground"
  self.chunks = {}
  self.size = 0
  self.kind = nil
  self.body = ""
end
function Parser:_overflow()
  -- 超限后丢弃到本包结束，不把剩余 base64/控制参数当成可见文本显示。
  local kind = self.kind or self.state
  self.chunks = {}
  self.size = 0
  self.body = ""
  self.state = kind == "csi" and "csi_discard" or "discard"
  local message = "terminal " .. kind .. " packet exceeds " .. self.limit .. " bytes"
  if self.callbacks.error then
    self.callbacks.error(message, kind)
  else
    error(message)
  end
end
function Parser:_append(text)
  if self.size + #text > self.limit then
    self:_overflow()
    return
  end
  self.chunks[#self.chunks + 1] = text
  self.size = self.size + #text
end
function Parser:_finish(terminator)
  local kind, body = self.kind, table.concat(self.chunks)
  self:_reset()
  -- 先回到 ground 再调用外部处理，回调不会继承本包的解析状态。
  if self.callbacks.string then
    self.callbacks.string(kind, body, terminator)
  end
end
function Parser:_introduce(byte)
  if byte == "[" then
    self.state = "csi"
    self.body = ""
  elseif introductions[byte] then
    self.state = "string"
    self.kind = introductions[byte]
    self.chunks = {}
    self.size = 0
  elseif byte:byte() >= 0x20 and byte:byte() <= 0x2f then
    self.state = "escape_intermediate"
  else
    self.state = "ground"
    self.screen:escape(byte)
  end
end
function Parser:_control(byte)
  if byte == BEL then
    if self.callbacks.bell then
      self.callbacks.bell()
    end
  else
    self.screen:control(byte)
  end
end
function Parser:_flush_incomplete()
  if self.utf8 == "" then
    return
  end
  self.utf8 = ""
  self.screen:write("�")
end
function Parser:_text(raw)
  -- utf8 只保留末尾不完整码点；非法编码替换为 U+FFFD，不跨控制序列拼接。
  local text = self.utf8 .. raw
  self.utf8 = ""
  local pos, start = 1, 1
  while pos <= #text do
    local lead = text:byte(pos)
    local width = lead < 0x80 and 1
      or lead >= 0xc2 and lead <= 0xdf and 2
      or lead >= 0xe0 and lead <= 0xef and 3
      or lead >= 0xf0 and lead <= 0xf4 and 4
      or 0
    if width > 1 and pos + width - 1 > #text then
      self.screen:write(text:sub(start, pos - 1))
      self.utf8 = text:sub(pos)
      return
    end
    local valid = width > 0
    for index = pos + 1, pos + width - 1 do
      local byte = text:byte(index)
      if byte < 0x80 or byte > 0xbf then
        valid = false
      end
    end
    local second = text:byte(pos + 1)
    if
      (lead == 0xe0 and second < 0xa0)
      or (lead == 0xed and second > 0x9f)
      or (lead == 0xf0 and second < 0x90)
      or (lead == 0xf4 and second > 0x8f)
    then
      valid = false
    end
    local c1 = valid and lead == 0xc2 and second >= 0x80 and second <= 0x9f
    if not valid or c1 then
      self.screen:write(text:sub(start, pos - 1))
      if not valid then
        self.screen:write("�")
        width = 1
      elseif encoded_c1[second] then
        self:_introduce(encoded_c1[second])
      elseif second == 0x84 then
        self.screen:escape("D")
      elseif second == 0x85 then
        self.screen:escape("E")
      elseif second == 0x8d then
        self.screen:escape("M")
      end
      start = pos + width
      -- A C1 introducer changes how the rest of this same packet must be parsed.
      if self.state ~= "ground" then
        self:feed(text:sub(start))
        return
      end
    end
    pos = pos + math.max(width, 1)
  end
  self.screen:write(text:sub(start))
end
function Parser:feed(bytes)
  assert(type(bytes) == "string", "terminal parser feed expects bytes")
  local pos = 1
  while pos <= #bytes do
    local byte, code = bytes:sub(pos, pos), bytes:byte(pos)
    if self.state == "string" or self.state == "discard" then
      -- Append slices, not individual bytes: graphics packets can contain megabytes of base64.
      local pattern = self.kind == "osc" and "[\7\24\26\27]" or "[\24\26\27]"
      local boundary = bytes:find(pattern, pos) or (#bytes + 1)
      if self.state == "string" and boundary > pos then
        self:_append(bytes:sub(pos, boundary - 1))
      end
      pos = boundary
      if pos > #bytes then
        break
      end
      byte = bytes:sub(pos, pos)
      if byte == ESC then
        self.state = self.state == "discard" and "discard_escape" or "string_escape"
      elseif byte == BEL then
        if self.state == "discard" then
          self:_reset()
        else
          self:_finish(BEL)
        end
      else
        self:_reset()
      end
    elseif self.state == "string_escape" or self.state == "discard_escape" then
      if byte == "\\" then
        if self.state == "discard_escape" then
          self:_reset()
        else
          self:_finish(ESC .. "\\")
        end
      elseif byte == ESC then
        -- ESC cancels the old string and begins a new escape sequence.
        self:_reset()
        self.state = "escape"
      else
        self:_reset()
        self.state = "escape"
        self:_introduce(byte)
      end
    elseif byte == "\24" or byte == "\26" then
      self:_flush_incomplete()
      self:_reset()
    elseif byte == ESC then
      self:_flush_incomplete()
      self:_reset()
      self.state = "escape"
    elseif code < 0x20 or code == 0x7f then
      self:_flush_incomplete()
      self:_control(byte)
    elseif self.state == "ground" then
      local boundary = bytes:find("[%z\1-\31\127]", pos) or (#bytes + 1)
      self:_text(bytes:sub(pos, boundary - 1))
      pos = boundary - 1
    elseif self.state == "escape" then
      self:_introduce(byte)
    elseif self.state == "escape_intermediate" then
      if code >= 0x30 and code <= 0x7e then
        self.state = "ground"
      end
    elseif self.state == "csi_discard" then
      if code >= 0x40 and code <= 0x7e then
        self:_reset()
      end
    elseif self.state == "csi" then
      if code >= 0x40 and code <= 0x7e then
        local body = self.body
        self:_reset()
        -- 回调返回 true 即已消费查询/协商，避免内部显示终端再处理并产生重复应答。
        if not (self.callbacks.csi and self.callbacks.csi(body, byte)) then
          self.screen:csi(body, byte)
        end
      elseif code >= 0x20 and code <= 0x3f then
        self.body = self.body .. byte
        if #self.body > math.min(self.limit, 4096) then
          self:_overflow()
        end
      else
        self:_reset()
      end
    end
    pos = pos + 1
  end
end
-- TODO: Raw 8-bit C1 mode and UTF-8 encoded ST inside control strings are not negotiated yet.
return Parser
