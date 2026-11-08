{1 "ThePrimeagen/refactoring.nvim"
 :dependencies ["lewis6991/async.nvim"]
 :keys (. (require :core.keymap) :refactoring)
 :config (fn []
           ((. (require :refactoring) :setup) {})
           (values))}
