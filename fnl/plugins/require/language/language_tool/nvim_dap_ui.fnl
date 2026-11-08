{1 "rcarriga/nvim-dap-ui"
  :lazy true
  :cmd ["DapNew"]
  :opts {}
  :config (fn [_ opts]
    (local dapui (require :dapui))
    (local dap (require :dap))
    (dapui.setup opts)
    (when _G.options.ui.dapui.autoopen
      (set dap.listeners.before.attach.dapui_config
        (λ [] (dapui.open)))
      (set dap.listeners.before.launch.dapui_config
        (λ [] (dapui.open))))
    (when _G.options.ui.dapui.autoclose
      (set dap.listeners.before.event_terminated.dapui_config
        (λ [] (dapui.close)))
      (set dap.listeners.before.event_exited.dapui_config
        (λ [] (dapui.close)))))
  :dependencies ["mfussenegger/nvim-dap" "nvim-neotest/nvim-nio"]}
