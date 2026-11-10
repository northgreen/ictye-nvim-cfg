-- 仅 TEST_HOST=1 或显式选中此文件时运行；依赖真实 Kitty，不以跳过伪装验收。
local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality
local T = MiniTest.new_set()

T["真实 Kitty 的查询回传与分屏位置恢复"] = function()
  local output = vim.fn.tempname() .. ".json"
  MiniTest.finally(function()
    vim.fn.delete(output)
  end)
  local process = vim
    .system({
      "kitten",
      "@",
      "launch",
      "--type=os-window",
      "--keep-focus",
      "--cwd=" .. vim.fn.getcwd(),
      "--title=Kitty bridge mini.test",
      "--env=KITTY_TEST_RESULT=" .. output,
      "--wait-for-child-to-exit",
      "--response-timeout=30",
      "nvim",
      "-u",
      "NONE",
      "-c",
      'autocmd VimEnter * ++once lua vim.defer_fn(function() dofile("tests/unit/kitty_passthrough_host.lua") end, 300)',
    }, { text = true })
    :wait(35000)
  eq(process.code, 0, { context = process.stderr })
  local result = vim.json.decode(table.concat(vim.fn.readfile(output), "\n"))
  eq(result.ok, true, { context = result.error })
  eq(result.replies, { "\27_Gi=31;OK\27\\", "\27_Gi=41,p=2;OK\27\\" })
  eq(result.warnings, {})
  eq(result.before.col ~= result.after.col, true)
end

T["真实 icat、浏览器动画像素、原生输入及 shell 退出"] = function()
  local process = vim
    .system({ "python3", "-u", "-B", "tests/unit/kitty_terminal_host.py" }, { text = true })
    :wait(180000)
  MiniTest.add_note((process.stdout or "") .. (process.stderr or ""))
  eq(process.code, 0, { context = (process.stdout or "") .. (process.stderr or "") })
  local artifacts = (process.stdout or ""):match("Artifacts: ([^\r\n]+)")
  eq(type(artifacts), "string")
  local result = vim.json.decode(table.concat(vim.fn.readfile(artifacts .. "/result.json"), "\n"))
  eq(result.ok, true, { context = result.error })
  for _, stage in ipairs({
    "icat",
    "resized",
    "hidden",
    "restored",
    "scrollback",
    "typed",
    "shell_pasted",
    "shell",
    "palette",
  }) do
    eq(type(result.stages[stage]), "table", { context = stage })
  end
  local samples = vim.json.decode(table.concat(vim.fn.readfile(artifacts .. "/animation-samples.json"), "\n"))
  eq(#samples, 30)
  eq(result.stages.typed.host_graphics.deletes, 0)
end

T["真实 Kitty 松键编码、双会话切换及隐藏输入窗口清理"] = function()
  local process = vim
    .system({ "python3", "-u", "-B", "tests/unit/kitty_keyboard_host.py" }, { text = true })
    :wait(60000)
  MiniTest.add_note((process.stdout or "") .. (process.stderr or ""))
  eq(process.code, 0, { context = (process.stdout or "") .. (process.stderr or "") })
end

return T
