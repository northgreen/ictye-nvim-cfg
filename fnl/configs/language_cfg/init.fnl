(local Autocmd vim.api.nvim_create_autocmd)
(var initd false)
(local p :configs.language_cfg.languages)
(local t :configs.language_cfg.toolchain)

(set vim.opt.completeopt [:noselect :noinsert])
(set vim.opt.complete "")

(local init_table
  {:c (fn [] (require (.. p ".c_cpp.c_cpp_config")) nil)
    :cpp (fn [] (require (.. p ".c_cpp.c_cpp_config")) nil)
    ;; TODO: 对齐 F# filetype，并补齐此分支模块路径的分隔符。
    :fs (fn [] (require (.. p "fsharp.fsharp_config")) nil)
    :php (fn [] (require (.. p ".php")) nil)})

(fn init []
  ((. (require :dapui) :setup))
  (require (.. t ".toolchain_init"))
  (set initd true)
  nil)

(set _G.configured {})

;; 每种语言的初始化仅执行一次；DAP 公共初始化成功后才标记完成。
(Autocmd :BufRead
  {:callback
    (fn [arg]
      (when (not initd) (init))
      (let [ft (. vim.bo arg.buf :filetype)
          initialize (. init_table ft)]
        (when initialize
          (initialize)
          (tset init_table ft nil)))
      nil)})
nil
