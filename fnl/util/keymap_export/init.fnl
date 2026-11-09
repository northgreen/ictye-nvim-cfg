;; 只在显式启用时安装事件；每次导出都是当前有效映射的快照。
(local uv (or vim.uv vim.loop))
(local modes [:n :x :s :o :i :l :c :t])
(local columns [:mode :lhs :rhs :description :callback :scope :buffer
    :buffer_name :filetype :sid :source :line :expr :noremap
    :silent :nowait :script :leader :localleader])
(var installed false)

(fn csv-cell [value]
  (.. "\"" (: (tostring (or value "")) :gsub "\"" "\"\"") "\""))

(fn encode-row [row]
  (table.concat (icollect [_ value (ipairs row)] (csv-cell value)) ","))

(fn callback-info [mapping scripts]
  (local callback (. mapping :callback))
  (local info (and (= (type callback) :function) (debug.getinfo callback :S)))
  (local source (if info (: info.source :gsub "^@" "")
      (or (. scripts (or mapping.sid 0)) "")))
  (values (if info (.. source ":" info.linedefined) "")
    source (if info (math.max 0 info.linedefined) (or mapping.lnum 0))))

(fn snapshot []
  (local scripts {})
  (each [_ script (ipairs (vim.fn.getscriptinfo))]
    (tset scripts script.sid script.name))
  (local rows [])
  (local leader (or vim.g.mapleader "\\"))
  (local localleader (or vim.g.maplocalleader "\\"))
  (fn append [mode mappings buf]
    (each [_ mapping (ipairs mappings)]
      (local (callback source line) (callback-info mapping scripts))
      (local row [mode mapping.lhs (or mapping.rhs "") (or mapping.desc "")
          callback (if (= buf 0) :global :buffer) buf
          (if (= buf 0) "" (vim.api.nvim_buf_get_name buf))
          (if (= buf 0) "" (. vim.bo buf :filetype))
          (or mapping.sid 0) source line])
      (each [_ flag (ipairs [:expr :noremap :silent :nowait :script])]
        (table.insert row (if (or (= (. mapping flag) 1) (= (. mapping flag) true)) 1 0)))
      (table.insert row leader)
      (table.insert row localleader)
      (table.insert rows (encode-row row))))
  (each [_ mode (ipairs modes)]
    (append mode (vim.api.nvim_get_keymap mode) 0)
    (each [_ buf (ipairs (vim.api.nvim_list_bufs))]
      (when (vim.api.nvim_buf_is_valid buf)
        (append mode (vim.api.nvim_buf_get_keymap buf mode) buf))))
  (table.sort rows)
  (.. (encode-row columns) "\r\n" (table.concat rows "\r\n")
    (if (> (# rows) 0) "\r\n" "")))

(fn write-snapshot [path contents]
  ;; 临时文件与目标在同一目录，避免读取方看见半份 CSV。
  (vim.fn.mkdir (vim.fs.dirname path) :p)
  (local (fd temporary err) (uv.fs_mkstemp (.. path ".XXXXXX")))
  (assert fd (.. "KEYMAP_EXPORT_WRITE: " (tostring (or temporary err))))
  (var opened true)
  (local (ok result) (pcall (λ []
        (local (count write-error) (uv.fs_write fd contents 0))
        (assert (= count (# contents)) (or write-error "short write"))
        (local (closed close-error) (uv.fs_close fd))
        (set opened false)
        (assert closed close-error)
        (local (renamed rename-error) (uv.fs_rename temporary path))
        (assert renamed rename-error))))
  (when opened (uv.fs_close fd))
  (when (not ok)
    (uv.fs_unlink temporary)
    (error (.. "KEYMAP_EXPORT_WRITE: " (tostring result)))))

(fn setup []
  (local path (or vim.g.keymap_export vim.env.NVIM_KEYMAP_EXPORT))
  (if (or (= path nil) (= path "")) false
    (do
      (assert (= (type path) :string) "KEYMAP_EXPORT_PATH: expected a CSV output path")
      (if installed true
        (do
          (set installed true)
              (local destination (vim.fs.normalize (vim.fn.fnamemodify (vim.fn.expand path) ":p")))
          (var previous nil)
          (var previous-error nil)
          (var pending false)
          (var leaving false)
          (fn export []
            (local (ok result) (pcall (λ []
                  (local contents (snapshot))
                  (when (or (not= contents previous)
                      (not (uv.fs_stat destination)))
                    (write-snapshot destination contents)
                    (set previous contents)))))
            (if ok (set previous-error nil)
                    (when (= previous-error nil)
                (set previous-error result)
                (vim.notify (.. "Keymap export: " (tostring result)) vim.log.levels.ERROR))))
          (fn refresh []
            (when (and (not pending) (not leaving))
              (set pending true)
              ;; 合并一次插件加载或 buffer 切换引起的一批事件。
              (vim.defer_fn (λ []
                  (set pending false)
                  (when (not leaving) (export))) 150)))
          (local group (vim.api.nvim_create_augroup :KeymapExport {:clear true}))
              (vim.api.nvim_create_autocmd [:VimEnter :BufEnter :BufDelete :LspAttach]
                                          {:group group :callback refresh})
              ;; SafeState 不排队计时器，避免计时器完成再次触发 SafeState 的空闲循环。
              (vim.api.nvim_create_autocmd :SafeState
                                          {:group group :callback (λ [] (when (not leaving) (export)))})
          (vim.api.nvim_create_autocmd :User
            {:group group :pattern [:LazyLoad :VeryLazy] :callback refresh})
          (vim.api.nvim_create_autocmd :VimLeavePre
            {:group group :callback (λ [] (set leaving true) (export))})
          (vim.api.nvim_create_user_command :KeymapExport export
            {:desc "Refresh the enabled keymap CSV snapshot"})
          (refresh)
          true)))))

{: setup : snapshot}
