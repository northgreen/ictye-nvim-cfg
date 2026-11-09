{1 :folke/edgy.nvim
  :event :VeryLazy
  :opts (fn [_ _opts]
    (local opts {:top []
        :bottom [{:ft :trouble :title :Files}
          {:ft :neotest-output-panel :title "Test Output"}]
        :left [{:ft :neo-tree :title :Tree}
          {:ft :Outline :title :OverView :size {:height 0.4}}]
        :right [{:ft :neotest-summary :size {:width 0.3}}
          {:ft :Avante :size {:width 0.3 :height 0.7}}
          {:ft :AvanteTodos :size {:width 0.3}}
          {:ft :AvanteSelectedFiles :size {:width 0.3}}
          {:ft :AvanteSelectedCode :size {:width 0.3}}
          {:ft :AvanteInput :size {:width 0.3 :height 0.2}}
          {:ft :opencode_terminal :title :OpenCode :size {:width 0.3}}]})
    (each [_ pos (ipairs [:top :bottom :left :right])]
      (tset opts pos (or (. opts pos) {}))
      (table.insert (. opts pos)
        {:ft :snacks_terminal
          :size {:height 0.4}
          :title "%{b:snacks_terminal.id}: %{b:term_title}"
          :filter (fn [_buf win]
            (and (. vim.w win :snacks_win)
              (= (. vim.w win :snacks_win :position) pos)
              (= (. vim.w win :snacks_win :relative) :editor)
              (not (. vim.w win :trouble_preview))))}))
    opts)}
