{1 "pysan3/fcitx5.nvim"
  :event "UIEnter"
  ; :enabled false
  :config (fn []
    (let [en "keyboard-us"
        ja "rime"]
      ((. (require :fcitx5) :setup)
        {:imname {:norm en :ins ja :cmd en} :remember_prior true})))}
