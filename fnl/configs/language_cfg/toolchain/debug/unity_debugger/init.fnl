;; 连接运行中的 Unity Player；调试器使用外部 Mono。
(local dap (require :dap))

(set dap.adapters.unity
     (fn [cb config]
       (vim.ui.input {:prompt "address [127.0.0.1]: " :default "127.0.0.1"}
                     (fn [result] (set config.address result) nil))
       (vim.ui.input {:prompt "port: "}
                     (fn [result] (set config.port (tonumber result)) nil))
       (cb {:type :executable
            :command :mono
            :args ["/home/ictye/.local/bin/unity-dap/unity-debug-adapter.exe"
                   "--log-level=warn"]})
       nil))

;; 保留已有的 C# 调试配置。
(when (= dap.configurations.cs nil)
  (set dap.configurations.cs {}))
(table.insert dap.configurations.cs
              {:name "Unity Editor/Player Instance [Mono]"
               :type :unity
               :request :attach})
nil
