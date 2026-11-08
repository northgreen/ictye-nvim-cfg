{1 :greggh/claude-code.nvim
 :dependencies [;; Required for git operations
                :nvim-lua/plenary.nvim]
 :config (fn []
           ((. (require :claude-code) :setup)
            {:window {:position :vertical}})
           (values))}
