;; @return LazyPluginSpec
{1 :sphamba/smear-cursor.nvim
 ;; :enabled (not vim.g.GUI)
 :enabled false
 :opts {}
 :config (fn []
           (set _G.smear_cursor (require :smear_cursor))
           (_G.smear_cursor.setup)
           (values))
 :event :VeryLazy}
