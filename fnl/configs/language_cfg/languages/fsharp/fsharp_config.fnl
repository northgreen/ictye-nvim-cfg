;; Godot 项目需要在项目文件中正确引用 GodotSharp。
(local dap (require :dap))
(set dap.configurations.fsharp
  [{:name "Launch file"
      :type :coreclr
      :request :launch
      :preLaunchTask :build
      :program (fn []
        (vim.fn.input "Path to DLL: "
          (.. (vim.fn.getcwd) "/bin/Debug/") "file"))
      :cwd "${workspaceFolder}"
      :stopOnEntry false}])
nil
