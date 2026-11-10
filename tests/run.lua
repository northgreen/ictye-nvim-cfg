-- 从仓库根目录运行：
-- nvim --headless --noplugin -u tests/minimal_init.lua -c 'lua MiniTest.run()'
local MiniTest = require("mini.test")
local cases = MiniTest.collect()
if #cases == 0 then
  error("未收集到测试，请检查 TEST_FILE 和测试集返回值")
end
-- 标准输出报告器在所有用例结束后，根据成功/失败设置进程退出码。
MiniTest.execute(cases)
