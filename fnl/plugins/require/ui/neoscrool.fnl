;; @return LazyPluginSpec
{1 :karb94/neoscroll.nvim
  :event :BufReadPre
  :enabled (not vim.g.neovide)
  :opts {;; Keys mapped to their corresponding default scrolling animation.
    :mappings [:<C-u> :<C-d> :<C-b> :<C-f> :<C-y> :<C-e> :zt :zz :zb]}}
