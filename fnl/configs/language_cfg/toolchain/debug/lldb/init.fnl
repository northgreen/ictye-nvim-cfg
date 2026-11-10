(local dap (require :dap))
(set dap.adapters.lldb {
    :type :executable
    :command :lldb-dap
    :name :lldb})
nil
