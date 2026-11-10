-- Kitty image storage belongs to the host; placement/cropping belongs to the
-- Lua terminal's viewport. All host IDs are private to this experiment.
-- 三层身份：子进程 i/I -> 本模块 image.host -> 每个 Nvim 视图的 placement ID。
-- 图片数据可以共享；放置坐标与可见性始终按窗口分别维护。
local M = {}
local ESC, ST = "\27", "\27\\"
local next_id, owners = 1900000000, {}
local function id()
  next_id = next_id + 1
  return next_id
end
local function parse(body)
  local control, data = body:match("^([^;]*);(.*)$")
  control = control or body
  local f = {}
  for key, value in control:gmatch("(%a)=([^,]+)") do
    f[key] = value
  end
  return f, data
end
local function wire(fields, data)
  local keys, parts = {}, {}
  for k in pairs(fields) do
    keys[#keys + 1] = k
  end
  table.sort(keys)
  for _, k in ipairs(keys) do
    parts[#parts + 1] = k .. "=" .. tostring(fields[k])
  end
  return ESC .. "_G" .. table.concat(parts, ",") .. (data ~= nil and ";" .. data or "") .. ST
end
local function number(f, k, default)
  return tonumber(f[k]) or default
end
local function uint32(s, at)
  local a, b, c, d = s:byte(at, at + 3)
  return d and ((a * 256 + b) * 256 + c) * 256 + d or nil
end
local function dimensions(f, data)
  if f.s and f.v then
    return tonumber(f.s), tonumber(f.v)
  end
  if f.f ~= "100" or not data then
    return
  end
  local file_transport = f.t == "f" or f.t == "t" or f.t == "s"
  local ok, decoded = pcall(vim.base64.decode, data:sub(1, file_transport and #data or 128))
  if not ok then
    return
  end
  if f.t == "f" or f.t == "t" or f.t == "s" then
    local path = decoded:gsub("%z.*$", "")
    if f.t == "s" then
      path = "/dev/shm/" .. path:gsub("^/", "")
    end
    -- The child controls this pathname. O_NONBLOCK plus fstat on the opened
    -- descriptor rejects FIFOs/devices without an open/read UI deadlock,
    -- including a path replaced between lookup and open.
    local fd = vim.uv.fs_open(path, 2048, 0) -- O_RDONLY | O_NONBLOCK (Linux)
    if not fd then
      return
    end
    local stat = vim.uv.fs_fstat(fd)
    decoded = stat and stat.type == "file" and (vim.uv.fs_read(fd, 24, 0) or "") or ""
    vim.uv.fs_close(fd)
  end
  if decoded:sub(1, 8) == "\137PNG\r\n\26\n" then
    return uint32(decoded, 17), uint32(decoded, 21)
  end
end

function M.new(term)
  -- upload 是未收齐的分块；uploads 是完整待发送图片；removals 与其同帧提交。
  return setmetatable(
    { term = term, images = {}, placements = {}, host_images = {}, uploads = {}, removals = {}, sequence = 0 },
    { __index = M }
  )
end

function M:retire(bytes)
  self.removals[#self.removals + 1] = bytes
  self.term:refresh()
end

function M:transmit(bytes, image, reply)
  -- Re-uploading an image ID invalidates its old host placements. Keep the
  -- previous visible frame until replacement bytes AND placements are ready.
  self.uploads[#self.uploads + 1] = { bytes = bytes, image = image, reply = reply }
  if reply then
    image.replies = image.replies or {}
    image.replies[#image.replies + 1] = reply
    image.pending_replies = #image.replies
  end
  self.term:refresh()
end

function M:image(f, create)
  local key = f.i and ("i:" .. f.i) or f.I and ("I:" .. f.I) or nil
  if not key and not create then
    return self.last_image
  end
  if not key then
    self.sequence = self.sequence + 1
    key = "anonymous:" .. self.sequence
  end
  local image = self.images[key]
  if not image then
    if not create then
      return nil
    end
    image = { host = id(), child_i = f.i, child_I = f.I, key = key }
    self.images[key], self.host_images[image.host], owners[image.host] = image, image, self
  end
  self.last_image = image
  return image
end

function M:reply_error(f, message)
  if f.q == "2" then
    return
  end
  local fields = { i = f.i, I = f.I, p = f.p }
  self.term:send(wire(fields, "ENOTSUP:" .. message))
  self.term.errors[#self.term.errors + 1] = message
end

function M:place(image, f)
  if f.U == "1" or f.P or f.Q then
    -- TODO: virtual placements need child-ID color/diacritic rewriting.
    -- Placeholder colors encode the child's ID. Keeping a separate host ID
    -- needs color/diacritic rewriting; don't falsely display it as normal.
    self:reply_error(f, "Unicode virtual/relative placements are not implemented")
    return false
  end
  local s = self.term.screen
  local cw, ch = self.term.cell_width, self.term.cell_height
  local source_w = number(f, "w", 0)
  local source_h = number(f, "h", 0)
  if source_w <= 0 then
    source_w = math.max(1, (image.width or cw) - number(f, "x", 0))
  end
  if source_h <= 0 then
    source_h = math.max(1, (image.height or ch) - number(f, "y", 0))
  end
  local width, height = source_w, source_h
  -- 只指定 c/r 之一时，另一轴必须按源图比例推导，不能保持原始像素高度/宽度。
  local has_cols, has_rows = number(f, "c", 0) > 0, number(f, "r", 0) > 0
  if has_cols or has_rows then
    local sx = has_cols and (math.max(1, number(f, "c", 1) * cw - number(f, "X", 0)) / source_w) or math.huge
    local sy = has_rows and (math.max(1, number(f, "r", 1) * ch - number(f, "Y", 0)) / source_h) or math.huge
    local scale = math.min(sx, sy)
    width, height = source_w * scale, source_h * scale
  end
  local cols = math.max(1, math.ceil((width + number(f, "X", 0)) / cw))
  local rows = math.max(1, math.ceil((height + number(f, "Y", 0)) / ch))
  local key = image.key .. ":" .. (f.p or "0")
  local old = self.placements[key]
  -- Replacing an existing placement is an in-place host update. Removing it
  -- first exposes Nvim's background between consecutive browser frames.
  local placement = {
    image = image,
    child_p = f.p,
    fields = vim.deepcopy(f),
    -- line_id 随内容滚入历史而保持不变；col 是从零开始的终端单元格偏移。
    line_id = s:line_id(),
    col = s.col - 1,
    cols = cols,
    rows = rows,
    pixel_width = width,
    pixel_height = height,
    views = old and old.views or {},
  }
  self.placements[key] = placement
  if f.C ~= "1" then
    for _ = 1, rows do
      s:control("\n")
    end
    s.col = math.min(s.cols, s.col + cols)
    if self.term.sync_cursor then
      self.term:sync_cursor()
    end
  end
  self.term:refresh()
  return true
end

function M:hide(p, immediate)
  -- 隐藏只移除放置，保留像素数据；关闭时不再等下一个刷新，立即清理宿主。
  for _, v in pairs(p.views) do
    if v.signature then
      local bytes = wire({ a = "d", d = "i", i = p.image.host, p = v.id, q = 2 })
      if immediate then
        self.term:host_send(bytes)
      else
        self:retire(bytes)
      end
    end
    v.signature = nil
  end
end

function M:delete(f)
  local selector = f.d or "a"
  local target = (f.i or f.I) and self:image(f, false)
  if (f.i or f.I) and not target then
    return
  end
  local cell_x, cell_y = number(f, "x", self.term.screen.col), number(f, "y", self.term.screen.row)
  for key, p in pairs(self.placements) do
    local match = selector:lower() == "a" or target == p.image
    if selector:lower() == "x" then
      match = p.col + 1 <= cell_x and p.col + p.cols >= cell_x
    end
    if selector:lower() == "z" then
      match = number(p.fields, "z", 0) == number(f, "z", 0)
    end
    if selector:lower() == "c" or selector:lower() == "p" or selector:lower() == "y" then
      local line = self.term.row_ids[p.line_id]
      local current = self.term.row_ids[self.term.screen:line_id()]
      local row = line and current and line - current + self.term.screen.row
      match = row and cell_y >= row and cell_y < row + p.rows
      if selector:lower() ~= "y" then
        match = match and cell_x > p.col and cell_x <= p.col + p.cols
      end
    end
    if f.p then
      match = match and p.child_p == f.p
    end
    if match then
      self:hide(p)
      self.placements[key] = nil
    end
  end
  if selector:upper() == selector then
    -- 大写删除允许释放像素数据，但同图仍有其他 placement 时不能销毁图片。
    for key, image in pairs(self.images) do
      local used = false
      for _, p in pairs(self.placements) do
        if p.image == image then
          used = true
          break
        end
      end
      if not used and (not target or target == image) then
        self:retire(wire({ a = "d", d = "I", i = image.host, q = 2 }))
        self.images[key] = nil
        -- 删除像素不能撤销上传应答；客户端仍需收到完成通知才能释放共享内存。
        if (image.pending_replies or 0) == 0 then
          self.host_images[image.host], owners[image.host] = nil, nil
        end
      end
    end
  end
end

function M:request(body)
  local f, data = parse(body)
  local action = f.a or "t"
  if action == "q" then
    -- Local, synchronous capability reply. icat sends DA immediately after
    -- its probes and stops detection at DA; waiting for a host round trip
    -- here would race that fence and falsely report no graphics support.
    local medium, format = f.t or "d", f.f or "32"
    if
      not ({ d = true, f = true, t = true, s = true })[medium]
      or not ({ ["24"] = true, ["32"] = true, ["100"] = true })[format]
    then
      self:reply_error(f, "unsupported graphics transport or format")
      return
    end
    if f.q ~= "1" and f.q ~= "2" then
      self.term:send(wire({ i = f.i, I = f.I, p = f.p }, "OK"))
    end
    self.term.stats.local_graphics_queries = (self.term.stats.local_graphics_queries or 0) + 1
    return
  end
  if action == "d" then
    self:delete(f)
    return
  end
  if (action == "T" or action == "p") and (f.U == "1" or f.P or f.Q) then
    self:reply_error(f, "Unicode virtual/relative placements are not implemented")
    return
  end
  if action == "p" then
    local image = self:image(f, false)
    if not image then
      self:reply_error(f, "unknown image")
      return
    end
    -- q=1 只回复错误；提前返回放置成功会被客户端误作上传完成并释放共享内存。
    if self:place(image, f) and f.q ~= "1" and f.q ~= "2" then
      self.term:send(wire({ i = f.i, I = f.I, p = f.p }, "OK"))
    end
    return
  end
  if self.upload then
    local upload = self.upload
    -- Continuation packets must remain m/q-only (a=f for frame uploads).
    local bytes = wire(f, data)
    upload.size = upload.size + #bytes
    if upload.size > ((self.term.options or {}).max_image_bytes or 64 * 1024 * 1024) then
      self.upload = nil
      self:reply_error(upload.fields, "image exceeds buffered upload limit")
      return
    end
    upload.packets[#upload.packets + 1] = bytes
    if f.m ~= "1" then
      self.upload = nil
      -- One host write per complete upload: anonymous continuation packets
      -- from two simultaneous Lua terminals can never be interleaved.
      if self.images[upload.image.key] ~= upload.image then
        return
      end
      self:transmit(table.concat(upload.packets), upload.image, upload.reply)
      if upload.action == "T" then
        self:place(upload.image, upload.fields)
      end
    end
    return
  end
  local image = self:image(f, action == "t" or action == "T" or action == "q")
  if not image then
    self:reply_error(f, "unknown image")
    return
  end
  local width, height = dimensions(f, data)
  image.width, image.height = width or image.width, height or image.height
  local reply
  if f.q ~= "2" then
    reply = { i = image.child_i, I = image.child_I, p = f.p, quiet = f.q }
  end
  local host = vim.deepcopy(f)
  -- 每次上传独立保留应答元数据；q=1 在宿主也请求完整应答，再按该次请求过滤成功。
  if f.q == "1" then
    host.q = "0"
  end
  host.i, host.I = tostring(image.host), nil
  if action == "T" then
    host.a = "t"
  end
  -- 上传与放置分开：宿主不能按自己的光标执行隐式放置，位置由 draw 计算。
  -- Don't expose the child's p= to another session. Placement acknowledgments
  -- are translated locally; host upload acknowledgment doesn't need p=.
  host.p = nil
  local bytes = wire(host, data)
  if f.m == "1" then
    self.upload = { image = image, fields = f, action = action, packets = { bytes }, size = #bytes, reply = reply }
  else
    self:transmit(bytes, image, reply)
    if action == "T" then
      self:place(image, f)
    end
  end
end

local function clipped(p, view, line, cw, ch)
  -- line/topline 是一基 buffer 行；col/leftcol 是零基单元格列。
  -- 先在视图像素中求交集，再按缩放比例映射到源图的 x/y/w/h 裁剪区域。
  -- 返回 row/col 为宿主 CUP 的一基坐标，X/Y 为目标单元格内像素偏移。
  local source_w = number(p.fields, "w", 0)
  local source_h = number(p.fields, "h", 0)
  if source_w <= 0 then
    source_w = math.max(1, (p.image.width or p.cols * cw) - number(p.fields, "x", 0))
  end
  if source_h <= 0 then
    source_h = math.max(1, (p.image.height or p.rows * ch) - number(p.fields, "y", 0))
  end
  local x = (p.col - view.leftcol) * cw + number(p.fields, "X", 0)
  local y = (line - view.topline) * ch + number(p.fields, "Y", 0)
  local width, height = p.pixel_width or p.cols * cw, p.pixel_height or p.rows * ch
  local left, top = math.max(0, x), math.max(0, y)
  local right, bottom = math.min(view.cols * cw, x + width), math.min(view.rows * ch, y + height)
  if right <= left or bottom <= top then
    return
  end
  local sx = number(p.fields, "x", 0) + math.floor((left - x) * source_w / width)
  local sy = number(p.fields, "y", 0) + math.floor((top - y) * source_h / height)
  local result = {
    row = view.row + math.floor(top / ch),
    col = view.col + math.floor(left / cw),
    X = left % cw,
    Y = top % ch,
    x = sx,
    y = sy,
    w = math.max(1, math.floor((right - left) * source_w / width)),
    h = math.max(1, math.floor((bottom - top) * source_h / height)),
    c = math.ceil((right - left + left % cw) / cw),
    r = math.ceil((bottom - top + top % ch) / ch),
  }
  if left == x and top == y and right == x + width and bottom == y + height then
    -- 完整可见时保留单轴缩放，让宿主自行按像素比例计算另一轴，避免单元格取整拉伸。
    if number(p.fields, "r", 0) <= 0 then
      result.r = nil
    end
    if number(p.fields, "c", 0) <= 0 then
      result.c = nil
    end
  end
  return result
end
function M:draw(views, force)
  -- 顺序必须为删除 -> 完整上传 -> 放置，且属于同一个 2026 同步刷新事务。
  -- force 用于恢复 Nvim 重绘擦掉的图片，不代表需要先删除可见 placement。
  local packets = self.removals
  self.removals = {}
  for _, upload in ipairs(self.uploads) do
    local image = upload.image
    if self.images[image.key] == image then
      packets[#packets + 1] = upload.bytes
    elseif upload.reply then
      -- 不再可见的帧仍完成有应答的上传，随后立即释放，不复活它的放置。
      packets[#packets + 1] = upload.bytes
      packets[#packets + 1] = wire({ a = "d", d = "I", i = image.host, q = 2 })
    end
  end
  local uploaded = #self.uploads > 0
  self.uploads = {}
  local function emit(bytes)
    packets[#packets + 1] = bytes
  end
  for _, p in pairs(self.placements) do
    local present = {}
    local line = self.term.row_ids[p.line_id]
    for _, view in ipairs(views) do
      local geom = line and clipped(p, view, line, self.term.cell_width, self.term.cell_height)
      local v = p.views[view.win] or { id = id() }
      p.views[view.win], present[view.win] = v, true
      local signature = geom and vim.json.encode(geom)
      -- signature 为 nil 表示完全不可见；几何变化直接用相同 p ID 替换。
      if v.signature and not signature then
        emit(wire({ a = "d", d = "i", i = p.image.host, p = v.id, q = 2 }))
        v.signature = nil
      end
      if geom and (signature ~= v.signature or force or uploaded) then
        local fields = vim.deepcopy(geom)
        fields.row, fields.col = nil, nil
        fields.a, fields.i, fields.p, fields.C, fields.q = "p", p.image.host, v.id, 1, 2
        fields.z = p.fields.z
        emit(ESC .. "7" .. string.format(ESC .. "[%d;%dH", geom.row, geom.col) .. wire(fields) .. ESC .. "8")
        v.signature = signature
      end
    end
    for win, v in pairs(p.views) do
      if not present[win] and v.signature then
        emit(wire({ a = "d", d = "i", i = p.image.host, p = v.id, q = 2 }))
        v.signature = nil
      end
    end
  end
  if #packets > 0 then
    -- One synchronized frame for all visible placements and removals. Native
    -- UI flush repaint can safely reissue p= without a preceding deletion.
    self.term:host_send(ESC .. "[?2026h" .. table.concat(packets) .. ESC .. "[?2026l")
  end
end

function M:close()
  if #self.removals > 0 then
    self.term:host_send(table.concat(self.removals))
    self.removals = {}
  end
  for _, p in pairs(self.placements) do
    self:hide(p, true)
  end
  for host in pairs(self.host_images) do
    self.term:host_send(wire({ a = "d", d = "I", i = host, q = 2 }))
    owners[host] = nil
  end
  self.placements, self.images, self.host_images = {}, {}, {}
  self.upload = nil
  self.uploads = {}
end

function M.response(seq)
  -- 宿主只认识私有 image ID；回传 PTY 前恢复子进程的 i/I/p，不能泄漏到别的会话。
  local body = seq:match("^" .. ESC .. "_G(.*)")
  if not body then
    return false
  end
  body = body:gsub(ESC .. "\\$", "")
  local f, message = parse(body)
  local host = tonumber(f.i)
  local owner = owners[host]
  if not owner or owner.term.closed then
    return false
  end
  local image = owner.host_images[host]
  local reply = table.remove(image.replies or {}, 1)
  if reply and (reply.quiet ~= "1" or message ~= "OK") and (reply.i or reply.I) then
    owner.term:send(wire({ i = reply.i, I = reply.I, p = reply.p }, message))
    owner.term.stats.graphics_replies = owner.term.stats.graphics_replies + 1
  end
  image.pending_replies = #(image.replies or {})
  if image.pending_replies == 0 and owner.images[image.key] ~= image then
    owner.host_images[host], owners[host] = nil, nil
  end
  return true
end

M._test = { parse = parse, wire = wire, dimensions = dimensions, clipped = clipped }
return M
