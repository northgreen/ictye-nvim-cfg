{1 "retran/meow.yarn.nvim"
 :dependencies ["MunifTanjim/nui.nvim"]
 :config (fn []
           ((. (require :meow.yarn) :setup)
            {;; Your custom configuration goes here.
             })
           nil)}
