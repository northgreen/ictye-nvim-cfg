-- 独立构建入口：不启动个人配置或插件安装，遵循 Hotpot 的缓存与原子写入规则。
local path = vim.env.HOTPOT_PATH
if not path or path == "" then
  path = vim.fn.stdpath("data") .. "/lazy/hotpot.nvim"
end
assert(vim.fn.isdirectory(path) == 1, "找不到 Hotpot；请先安装或设置 HOTPOT_PATH：" .. path)
vim.opt.runtimepath:prepend(path)
require("hotpot")
local context, err = require("hotpot.api").context(vim.fn.getcwd())
assert(context, err)
local ok, report = context.sync({ ["atomic?"] = true, ["verbose?"] = false })
assert(ok, report)
assert(#report.errors == 0, "Hotpot 编译失败；缓存未更新，详见上方错误")
print("Hotpot 缓存：" .. context.locate("destination"))
