--- @return LazyPluginSpec
return {
  'nvim-tree/nvim-tree.lua',
  lazy = true,
  enabled = false,
  version = '*',
  cmd = { 'NvimTreeOpen', 'NvimTreeToggle' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    diagnostics = {
      enable = true,
      show_on_dirs = true,
    }
  },
}
