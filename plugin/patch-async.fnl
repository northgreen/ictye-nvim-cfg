(local data (vim.fn.stdpath "data"))
(local paths
  {:async_nvim (.. data "/lazy/async.nvim/lua/async.lua")
   :promise    (.. data "/lazy/promise-async/lua/async.lua")})

(local loaded {})
(fn load [kind]
  (or (. loaded kind)
      (let [mod (dofile (. paths kind))]
        (tset loaded kind mod)
        mod)))

(fn match-kind [src]
  (when src
    (if
      (src:find "refactoring" 1 true)      :async_nvim
      (src:find "nvim-ufo" 1 true)         :promise
      (src:find "fundo" 1 true)            :promise
      (src:find "promise-async" 1 true)    :promise
      :else nil)))

(fn detect-kind []
  (var found nil)
  (for [level 2 16]
    (let [info (debug.getinfo level "S")
          src  (and info info.source)]
      (when (and (not found) src)
        (set found (match-kind src)))))
  found)

(local orig-require _G.require)
(set _G.require
  (fn [modname ...]
    (if (not= modname :async)
        (orig-require modname ...)
        (let [kind (or (detect-kind 2 0) :async_nvim)]
          (load kind)))))

nil
