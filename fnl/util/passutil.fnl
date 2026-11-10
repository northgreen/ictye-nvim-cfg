{:get_password (λ [path]
    (when vim.system
      (let [res (: (vim.system [:pass :show path]) :wait)]
        (when (= res.code 0)
          (let [(key _) (res.stdout:gsub "%s+$" "")]
            key)))))}
