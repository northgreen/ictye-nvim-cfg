local twc = require 'util.functions'.three_way_compare
return function(cmd, opts)
  cmd = cmd or twc(options.env.os.linux + options.env.os.mac > 0, 'zsh', 'pwsh')
  opts = opts or {}

  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.6)
  local col = opts.col or math.floor((vim.o.columns - width) / 2)
  local row = opts.row or math.floor((vim.o.lines - height) / 2)

  -- 创建缓冲区
  local buf = vim.api.nvim_create_buf(false, true)
  if buf == 0 then
    error("Failed to create buffer")
  end

  -- 创建悬浮窗口
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
  })

  local ret = vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      pcall(vim.api.nvim_win_close, win, true)
    end
  })

  if ret < 0 then vim.fn.endechoerr("Failed to start job: " .. cmd) end
  vim.cmd("startinsert")
end
