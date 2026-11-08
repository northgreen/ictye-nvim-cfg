(local dap (require :dap))
(set dap.adapters.coreclr
     {:type :executable :command :netcoredbg :arg ["--interpreter=vscode"]})
(set dap.adapters.godot_mono
     {:type :executable :command :netcoredbg :arg ["--interpreter=vscode"]})
nil
