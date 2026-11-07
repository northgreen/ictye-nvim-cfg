return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")

    local TOPIARY_CONFIG = vim.fn.stdpath("config") .. "/topiary/languages.ncl"
    local TOPIARY_QUERIES = vim.fn.stdpath("config") .. "/topiary/queries"

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.completion.spell,
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.diagnostics.codespell,
        null_ls.builtins.diagnostics.actionlint,
        null_ls.builtins.formatting.topiary.with({
          filetypes = { "ncl", "nickel", "fennel" }, -- 保留默认，额外加入 fennel

          generator_opts = {
            command = "topiary",
            args = { "format", "$FILENAME" }, -- 与内置源保持一致
            to_temp_file = true,        -- null-ls 使用临时文件传递内容
            env = {                     -- 关键：告诉 Topiary 去哪里找配置和查询
              TOPIARY_CONFIG_FILE = TOPIARY_CONFIG,
              TOPIARY_LANGUAGE_DIR = TOPIARY_QUERIES,
            },
          },
        }),
      },
    })
  end,
}
