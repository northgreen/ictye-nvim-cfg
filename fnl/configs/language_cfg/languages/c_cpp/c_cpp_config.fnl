(local dap (require :dap))
(set dap.configurations.cpp
     [{:name "Launch file"
       :type :codelldb
       :request :launch
       :program (fn []
                  (vim.fn.input "Path to executable: "
                                (.. (vim.fn.getcwd) "/") "file"))
       :cwd "${workspaceFolder}"
       :stopOnEntry false}])
(set dap.configurations.c dap.configurations.cpp)
nil
