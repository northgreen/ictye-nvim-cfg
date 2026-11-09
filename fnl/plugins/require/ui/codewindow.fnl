{1 :gorbit99/codewindow.nvim
  :event :BufReadPre
  :opts {:minimap_width 10}
  :config (λ [_ cfg]
    (let [codewindow (require :codewindow)]
      (codewindow.setup cfg)
      (codewindow.apply_default_keybinds)))}
