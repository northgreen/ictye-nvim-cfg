(local START "__NEOGHIDRA_JSON_START__")
(local END "__NEOGHIDRA_JSON_END__")

(fn decode-output [output]
  (let [framed (.. "\n" output "\n")
      (_ finish) (string.find framed (.. "\n" START "\n") 1 true)
      stop (and finish (string.find framed (.. "\n" END "\n") (+ finish 1) true))]
    (if (not stop)
      (values nil "MissingOutput: Ghidra 没有返回分析 JSON")
      (let [(ok result) (pcall vim.json.decode (string.sub framed (+ finish 1) (- stop 1)))]
        (if (not ok)
          (values nil (.. "InvalidJSON: " (tostring result)))
          (not= (type result) :table)
          (values nil "InvalidResult: Ghidra 返回的不是对象")
          result.error
          (values nil (.. "ExportError: " (or result.message "unknown error")))
          (or (not= (type result.program_name) :string)
            (not= (type result.entry_point) :string)
            (not= (type result.functions) :table)
            (not= (type result.symbols) :table)
            (not= (type result.disassembly) :table))
          (values nil "InvalidResult: Ghidra 返回的分析字段不完整")
          result)))))

(fn analyze-binary [binary-path callback]
  (local config ((. (require :neoghidra.config) :get)))
  (local utils (require :neoghidra.utils))
  (fn fail [message]
    (utils.error message)
    (when callback (callback nil message))
    nil)
  (local launcher (vim.fs.joinpath config.ghidra_path :support :pyghidraRun))
  (local timeout (vim.fn.exepath :timeout))
  (local script (. (vim.api.nvim_get_runtime_file "scripts/neoghidra_export.py" false) 1))
  (if (not= (vim.fn.executable launcher) 1)
    (fail (.. "MissingLauncher: " launcher))
    (= timeout "")
    (fail "MissingTimeout: 需要 GNU coreutils timeout 终止整个分析进程组")
    (not script)
    (fail "MissingScript: scripts/neoghidra_export.py 不在 runtimepath 中")
    (not= (vim.fn.filereadable binary-path) 1)
    (fail (.. "MissingBinary: " binary-path))
    (do
      (local name (.. (vim.fs.basename binary-path) "_"
          (string.sub (vim.fn.sha256 binary-path) 1 8)))
      ;; GNU timeout 对整个进程组发送信号，避免启动器的 Python/JVM 后代遗留。
      (local command [timeout "--kill-after=2s" (tostring config.analysis_timeout)
          launcher "-H" config.project_dir name
          "-import" binary-path "-overwrite"
          "-scriptPath" (vim.fs.dirname script)
          "-postScript" (vim.fs.basename script)
          "-analysisTimeoutPerFile" (tostring config.analysis_timeout)])
      (utils.notify "Analyzing binary with PyGhidra...")
      (local (ok process)
        (pcall vim.system command
          {:text true}
          (vim.schedule_wrap
            (fn [completed]
              (local (result error-message)
                (if (= completed.code 0)
                  (decode-output (or completed.stdout ""))
                  (values nil (.. "ProcessError: PyGhidra exit " completed.code))))
              ;; 官方启动器可能在脚本失败后仍返回 0，必须同时校验导出数据。
              (if error-message
                (let [log (vim.fs.joinpath config.project_dir (.. name ".neoghidra.log"))
                    output (.. (or completed.stdout "") "\n" (or completed.stderr ""))
                    (saved _) (pcall vim.fn.writefile (vim.split output "\n" {:plain true}) log)]
                  (fail (.. error-message (if saved (.. "；日志：" log) (.. "\n" output)))))
                (do
                  (utils.cache_set binary-path result)
                  (utils.notify "Analysis complete!")
                  (when callback (callback result nil))))
              nil))))
      (if ok process (fail (.. "LaunchError: " (tostring process)))))))

{:setup (fn []
    (tset (require :neoghidra.ghidra) :analyze_binary analyze-binary)
    ((. (require :plugins.config.neoghidra.views) :setup))
    nil)}
