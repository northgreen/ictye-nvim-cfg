{1 "nvim-neotest/neotest"
 :dependencies ["nvim-neotest/nvim-nio" "nvim-lua/plenary.nvim" "nsidorenco/neotest-vstest"]
 :enable false
 :config (fn [_ _]
           ((. (require :neotest) :setup)
            {:adapters [(require :rustaceanvim.neotest) (require :neotest-vstest)]
             :consumers {:overseer (require :neotest.consumers.overseer)}})
           (values))
 :event "VeryLazy"}
