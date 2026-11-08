{1 "hrsh7th/nvim-cmp"
  :opts (λ [_ opts]
    (set opts.sources (or opts.sources {}))
    (table.insert opts.sources {:name "lazydev" :group_index 0}))
  :events ["BufReadPre"]
  :enabled false
  :lazy true
  :config (λ []
    (local cmp (require :cmp))
    (local lspkind (require :lspkind))
    (cmp.setup
      {:formatting
        {:expandable_indicator true
          :fields ["abbr" "kind" "menu"]
          :format (fn [entry item]
            (local color_item ((. (require :nvim-highlight-colors) :format)
                entry {:kind item.kind}))
            (var formatted-item item)
            (set formatted-item
              ((lspkind.cmp_format
                  {:mode "symbol_text"
                    :symbol_map _G.options.ui.symbal_map
                    :before (fn [rentry vim_item]
                      (set vim_item.menu
                        (.. "[" (string.upper rentry.source.name) "]"))
                      vim_item)})
                entry formatted-item))
            (when color_item.abbr_hl_group
              (set formatted-item.kind_hl_group color_item.abbr_hl_group)
              (set formatted-item.kind color_item.abbr))
            formatted-item)}
        :snippet {:expand (fn [args]
            ((. vim.fn :vsnip#anonymous) args.body))}
        :window {:completion (cmp.config.window.bordered {:zindex 40})
          :documentation (cmp.config.window.bordered {:zindex 40})}
        :mapping
        (cmp.mapping.preset.insert
          {:<Tab> (cmp.mapping
              (λ [fallback]
                (if (cmp.visible)
                  (do
                    (let [entry (cmp.get_selected_entry)]
                      (when (not entry)
                        (cmp.select_next_item {:behavior cmp.SelectBehavior.Select})))
                    (cmp.confirm))
                  (fallback)))
              ["i" "s" "c"])
            :<C-j> (cmp.mapping.select_next_item ["i" "s" "c"])
            :<C-k> (cmp.mapping.select_prev_item ["i" "s" "c"])})
        :sources (cmp.config.sources
          [{:name "nvim_lsp"} {:name "vsnip"} {:name "path"}
            {:name "eazy-dotnet"} {:name "buffer"}
            {:name "fittencode" :group_index 1} {:name "avante"}
            {:name "sonicpi"}])})
    (cmp.setup.cmdline ["/" "?"]
      {:mapping (cmp.mapping.preset.cmdline)
        :sources [{:name "buffer"}]})
    (cmp.setup.cmdline ":"
      {:mapping (cmp.mapping.preset.cmdline)
        :sources (cmp.config.sources [{:name "path"}]
          [{:name "cmdline"}])
        :matching {:disallow_symbol_nonprefix_matching false}}))
  :dependencies ["onsails/lspkind.nvim" "hrsh7th/cmp-buffer" "hrsh7th/cmp-path"
    "hrsh7th/cmp-nvim-lua"
    {1 "hrsh7th/cmp-nvim-lsp" :events ["BufReadPre"]}
    {1 "hrsh7th/cmp-vsnip"
      :dependencies ["hrsh7th/vim-vsnip-integ" "hrsh7th/vim-vsnip"]}]}
