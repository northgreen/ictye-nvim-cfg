-- 测试只加载仓库模块与 mini.test，不启动个人配置或触发插件安装/联网。
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local mini = vim.env.MINI_TEST_PATH
if not mini or mini == "" then
  mini = vim.fn.stdpath("data") .. "/lazy/mini.nvim"
end
if vim.fn.filereadable(mini .. "/lua/mini/test.lua") ~= 1 then
  error("找不到 mini.test；请将 MINI_TEST_PATH 设置为 mini.nvim 或独立 mini.test 仓库目录：" .. mini)
end
vim.opt.runtimepath:append(mini)
vim.o.swapfile = false
require("mini.test").setup({
  script_path = "tests/run.lua",
  collect = {
    emulate_busted = false,
    find_files = function()
      if vim.env.TEST_FILE and vim.env.TEST_FILE ~= "" then
        return { vim.env.TEST_FILE }
      end
      local files = {
        "tests/unit/kitty_terminal_screen.lua",
        "tests/unit/kitty_terminal_protocol.lua",
        "tests/unit/kitty_terminal.lua",
        "tests/unit/kitty_passthrough.lua",
        "tests/unit/meow_yarn.lua",
        "tests/unit/performance.lua",
        "tests/unit/file_util.lua",
        "tests/unit/plugin_specs.lua",
        "tests/unit/plugin_disable.lua",
        "tests/unit/plugin_loading.lua",
        "tests/unit/lsp_configs.lua",
        "tests/unit/neoghidra.lua",
        "tests/unit/keymap_export.lua",
        "tests/unit/llm_modules.lua",
        "tests/unit/llm_modules_pi.lua",
      }
      if vim.env.TEST_HOST == "1" then
        files[#files + 1] = "tests/integration/kitty_host.lua"
      end
      return files
    end,
  },
})
