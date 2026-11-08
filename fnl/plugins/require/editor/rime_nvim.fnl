{1 "Freed-Wu/rime.nvim"
 :enabled false
 :opts {}
 :config (fn [_ opt]
           (let [ui (require :ime.ui)
                 rime (require :rime.nvim)]
             (set rime.rime {:ui (ui.UI {:indices ui.styles.square})})
             (vim.keymap.set "i" "<C-^>" rime.toggle)
             (vim.keymap.set "i" "<C-@>" rime.enable)
             (vim.keymap.set "i" "<C-_>" rime.disable)
             (vim.keymap.set "i" "<C-\\>" (rime.callback "<C-\\>")))
           (values))
 :dependencies [["rimeinn/ime.nvim"]]}
