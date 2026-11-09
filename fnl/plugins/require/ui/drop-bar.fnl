{1 :Bekaboo/dropbar.nvim
  ;; Optional, but required for fuzzy finder support.
  :dependencies {1 :nvim-telescope/telescope-fzf-native.nvim :build :make}
  :config (fn []
    (let [dropbar-api (require :dropbar.api)]
      (vim.keymap.set :n "<Leader>;" dropbar-api.pick {:desc "Pick symbols in winbar"})
      (vim.keymap.set :n "[;" dropbar-api.goto_context_start
        {:desc "Go to start of current context"})
      (vim.keymap.set :n "];" dropbar-api.select_next_context
        {:desc "Select next context"})))}
