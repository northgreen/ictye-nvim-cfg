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
                  (fn [] (dapui.open) (values)))
             (set dap.listeners.before.launch.dapui_config
                  (fn [] (dapui.open) (values))))
           (when _G.options.ui.dapui.autoclose
             (set dap.listeners.before.event_terminated.dapui_config
                  (fn [] (dapui.close) (values)))
             (set dap.listeners.before.event_exited.dapui_config
                  (fn [] (dapui.close) (values))))
           (values))
 :dependencies ["mfussenegger/nvim-dap" "nvim-neotest/nvim-nio"]}
