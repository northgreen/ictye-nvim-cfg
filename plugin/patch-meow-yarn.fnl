;; Keep local fixes outside lazy.nvim's managed plugin checkout.
(fn install []
  (let [Hierarchy (require :meow.yarn.hierarchy)]
    (when (not Hierarchy._cfg_tree_patch)
      (let [util (require :meow.yarn.util)
          reserved-by-tree (setmetatable {} {:__mode :k})
          unique-id-for util.unique_id_for
          new Hierarchy.new]
        (set util.unique_id_for
          (fn [tree base-id]
            (if (not tree)
              (unique-id-for tree base-id)
              (let [reserved (or (. reserved-by-tree tree) {})]
                (tset reserved-by-tree tree reserved)
                (var id base-id)
                (var suffix 1)
                ;; Siblings are allocated before set_nodes exposes them to get_node.
                (while (or (. reserved id) (tree:get_node id))
                  (set suffix (+ suffix 1))
                  (set id (.. base-id "#" suffix)))
                (tset reserved id true)
                id))))
        (set Hierarchy.new
          (fn [self ...]
            (let [instance (new self ...)
                get-node instance.tree.get_node]
              (set instance.tree.get_node
                (fn [tree node-id-or-linenr]
                  ;; Scheduled previews can outlive the popup; explicit IDs stay valid.
                  (when (or (not= node-id-or-linenr nil) (instance:is_valid))
                    (get-node tree node-id-or-linenr))))
              instance)))
        (set Hierarchy._cfg_tree_patch true)))))

(local group (vim.api.nvim_create_augroup :ConfigMeowYarnPatch {:clear true}))
(vim.api.nvim_create_autocmd :User
  {:group group
    :pattern :LazyLoad
    :callback (fn [event]
      (when (= event.data :meow.yarn.nvim) (install)))})

;; Startup plugins may already be loaded before plugin/ scripts are sourced.
(when (. package.loaded :meow.yarn) (install))
nil
