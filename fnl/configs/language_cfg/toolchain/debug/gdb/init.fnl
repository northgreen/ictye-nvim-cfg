(local dap (require :dap))
(set dap.adapters.gdb
     {:type :executable
      :command :gdb
      :args ["--interpreter=dap" "--eval-command" "set print pretty on"]})
nil
