local twc = require("util.functions").three_way_compare
return function(cmd, opts)
  cmd = cmd or twc(options.env.os.linux + options.env.os.mac > 0, "zsh", "pwsh")
  opts = opts or {}

  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.6)
  local col = opts.col or math.floor((vim.o.columns - width) / 2)
  local row = opts.row or math.floor((vim.o.lines - height) / 2)

  -- Kitty 终端自行创建缓冲区，先打开浮窗以取得正确的视口尺寸。
  local terminal = require("experimental.kitty_terminal")
  local colors, color_error = require("experimental.kitty_terminal.colors").read()
  local win = vim.api.nvim_open_win(0, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  local ok, term = pcall(terminal.open, { cmd = cmd, colors = colors })
  if not ok then
    pcall(vim.api.nvim_win_close, win, true)
    error(term)
  end
  term.color_error = color_error
  vim.bo[term.buf].bufhidden = "wipe"
  -- 等最终输出刷新完成再关闭浮窗；wipe 同时释放 PTY 和图形资源。
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term.buf,
    once = true,
    callback = function()
      vim.schedule(function()
        pcall(vim.api.nvim_win_close, win, true)
      end)
    end,
  })
end
