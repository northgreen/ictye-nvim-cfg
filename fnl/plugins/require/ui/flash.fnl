;; @return LazyPluginSpec
{1 :folke/flash.nvim
  :event :VeryLazy
  ;; @type Flash.Config
  :opts {}
  ;; Keep key definitions in the central keymap module.
  :keys (. (require :core.keymap) :flash)}
