(λ join_module [base name]
  (if (= base "") name
    (.. base "." name)))

;; 只遍历真实目录，不跟随符号链接，避免目录循环。
(λ scan [dirname base extension modules]
  (each [name kind (vim.fs.dir dirname)]
    (if (= kind :directory)
      (scan (vim.fs.joinpath dirname name) (join_module base name) extension modules)
      (and (= kind :file) (= (name:sub (- (length extension))) extension))
      (let [module_name (name:sub 1 (- (+ (length extension) 1)))]
        (if (= module_name "init")
          (when (not= base "") (table.insert modules base))
          (table.insert modules (join_module base module_name))))))
  modules)

{:scan_dir_for_module
  (λ [dirname base_name ?extension]
    (let [modules (scan dirname base_name (or ?extension ".lua") [])]
      ;; 文件系统的枚举顺序不固定；调用方获得稳定的模块列表。
      (table.sort modules)
      modules))}
