{
  :get_password (λ [path]
    (when vim.system
      (local res (: (vim.system [:pass :show path]) :wait))
      (when (= res.code 0) (global (key num) (res.stdout:gsub "%s+$" ""))
        (lua "return key")))
    nil)
}
