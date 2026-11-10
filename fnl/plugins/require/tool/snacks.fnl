;; Returns LazyPluginSpec.
{1 "folke/snacks.nvim"
  :opts {:profiler {:enabled true :keymaps {:toggle "<leader>pp"}}
    :big_file {:enabled true}
    :dim {:enabled true}
    :image {:enabled true
      :inline true
      :doc {:enabled true
        :inline true
        :float true
        :max_width 80
        :max_height 40
        :conceal (fn [lang type]
          ;; Only conceal math expressions.
          (= type "math"))}
      :resolve (fn [path src]
        (if ((. (require :obsidian.api) :path_is_note) path)
          ((. (require :obsidian.api) :resolve_image_path) src)
          path))}
    :gh {:enabled true}
    :zen {:enter true
      :fixbuf false
      :minimal false
      :width 120
      :height 0
      :backdrop {:transparent true :blend 40}
      :keys {:q false}
      :zindex 40
      :wo {:winhighlight "NormalFloat:Normal"}
      :w {:snacks_main true}}
    :picker {}
    :indent {:enabled true :char "┆"}
    :scope {;; Enable highlighting the current scope.
      :enabled true
      :priority 200
      :char "┆"
      ;; Underline the start of the scope.
      :underline true
      ;; Only show scope in the current window.
      :only_current false
      ;; string|string[]: highlight group for scopes.
      :hl "SnacksIndentScope"}}
  :keys (. (require :core.keymap) :snacks)}
