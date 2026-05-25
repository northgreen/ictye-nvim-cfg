return {
  "northgreen/project_toolchain.nvim",
  -- enabled = false,
  opts = {
    log_level = "warn",
    manual_mode = false,
  },
  -- dev = true,
  lazy = true,
  event = "BufRead",
  dependencies = { 'MunifTanjim/nui.nvim' }
}
