return {
  "pmizio/typescript-tools.nvim",
  ft = {'typescript','javascript'},
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {
      settings = {
        code_lens = "all"
      }
  },
}
