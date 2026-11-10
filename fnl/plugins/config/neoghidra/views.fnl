(local patched {})

(fn prepare-view [view]
  (when (not (. patched view))
    (local create-buffer view.create_buffer)
    (set view.create_buffer
      (fn [binary-path name]
        (var buf nil)
        (each [candidate path (pairs view.buffer_binaries)]
          (when (and (= path binary-path) (vim.api.nvim_buf_is_valid candidate))
            (set buf candidate)))
        (when (not buf)
          ;; 路径摘要区分同名二进制，相同路径则复用原有视图。
          (local title (and name (.. name " (" (string.sub (vim.fn.sha256 binary-path) 1 8) ")")))
          (set buf (create-buffer binary-path title)))
        ;; 清掉旧行映射，加载消息不能沿用上一份结果的地址。
        (when view.line_to_address (tset view.line_to_address buf nil))
        (when view.buffer_disasm (tset view.buffer_disasm buf nil))
        (tset vim.bo buf :modifiable false)
        ;; nomodifiable 已阻止编辑；原结果加载器负责恢复 readonly。
        (tset vim.bo buf :readonly false)
        buf))
    (tset patched view true))
  nil)

{:setup (fn []
    (prepare-view (require :neoghidra.decompiler))
    (prepare-view (require :neoghidra.disassembly))
    nil)}
