{1 "nvim-neorg/neorg"
  :enabled false
  :version "*"
  :config (fn []
    ((. (require :neorg) :setup)
      {:load {:core.defaults {}
          :core.concealer {}
          :core.dirman {:config {:workspaces {:notes "~/notes"}
              :default_workspace "notes"}}}})
    (set vim.wo.foldlevel 99)
    (set vim.wo.conceallevel 2)
    (values))}
