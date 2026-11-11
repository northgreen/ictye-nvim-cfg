{1 "stevearc/oil.nvim"
  ;; Module oil; opts: oil.SetupOpts.
  :opts {:columns ["icon" "size" "mtime" "permissions"]
    :constrain_cursor "name"
    :watch_for_changes true
    :lsp_file_method {:enabled true}
    :view_options {:is_hidden_file
      (fn [name bufnr]
        ;; Ignore rubbish files for godot as well as dotfiles.
        (or (not= (: name :match "^%.") nil)
          (not= (: name :match "(%.uid)$") nil)
          (not= (: name :match "(%.import)$") nil)))}
    :keymaps {options.keymaps.exit {1 "actions.close" :mode "n"}}}
  ;; Optional alternative: :dependencies [{1 "echasnovski/mini.icons" :opts {}}]
  ;; Use this dependency if you prefer nvim-web-devicons.
  :dependencies ["nvim-tree/nvim-web-devicons"]
  ;; Lazy loading is not recommended: correct behavior in all situations is tricky.
  :lazy false}
