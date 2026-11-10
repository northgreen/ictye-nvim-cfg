{1 "B00TK1D/neoghidra"
  :config (fn [_ opts]
    ((. (require :plugins.config.neoghidra) :setup))
    ((. (require :neoghidra) :setup) opts)
    nil)
  :opts {
    :ghidra_path "/opt/ghidra"
    :auto_analyze true
    :default_view "decompiler"
    :project_dir (.. (vim.uv.os_homedir) "/GhidraProj")
    :keymaps {
      :toggle_view "<leader>gt"
      :goto_definition "gd"
      :rename_symbol "<leader>gr"
      :jump_to_offset "<leader>go"
      :list_functions "<leader>gF"}}}
