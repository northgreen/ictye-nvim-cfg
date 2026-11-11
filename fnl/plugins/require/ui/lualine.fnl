;; UI for information display.
(fn f-nav []
  (let [(_fun _cond) (options.ui.bread_nav)]
    {:fun _fun :cond _cond}))

(fn muti-cursor-state []
  (let [mc (require :multicursor-nvim)]
    {:fun (fn []
        (let [num (mc.numCursors)]
          (.. "MultiCursor(" num ")")))
      :cond (fn [] (mc.hasCursors))}))

{1 :nvim-lualine/lualine.nvim
  :event :BufReadPre
  ;; :enabled (and (not vim.g.started_by_firenvim) _G.options.ui.ui_options.noise)
  ;; :enabled false
  :opts {:options {:icons_enabled true
      :component_separators ""
      :section_separators {:left "" :right ""}
      :disabled_filetypes {1 :trouble
        2 :dap-repl
        3 :dapui_watches
        4 :dapui_stacks
        5 :dapui_stacks
        6 :dapui_breakpoints
        7 :dapui_scopes
        8 :dapui_console
        9 :dashboard
        10 :Avante
        11 :AvanteInput
        12 :AvanteSelectedFiles
        13 :AvanteTodos
        14 :AvanteSelectedCode
        15 :opencode_terminal
        16 :TelescopePrompt
        17 :oil_preview
        :statusline [:NvimTree :Outline :neo-tree :neotest-summary :opencode_terminal]
        :winbar [:NvimTree :Outline :trouble :neo-tree :neotest-summary]}}
    :sections {:lualine_a [{1 :mode :separator {:left "" :right ""} :right_padding 2}]
      :lualine_b [{1 :branch :separator {:left "" :right ""} :right_padding 2}
        :diff :diagnostics]
      :lualine_c [:overseer]
      :lualine_x [:encoding :fileformat :filetype]
      :lualine_y [:progress]
      :lualine_z [{1 :location :separator {:right ""} :left_padding 2}]}
    :inactive_sections {:lualine_a [:mode] :lualine_b [] :lualine_c []
      :lualine_x [:location] :lualine_y [] :lualine_z []}
    ;; :winbar {:lualine_a [{1 :mode :separator {:left "" :right ""} :right_padding 2}]
    ;;          :lualine_b [] :lualine_c [:filesize] :lualine_x [] :lualine_y [] :lualine_z []}
    ;; :inactive_winbar {:lualine_a [:filename] :lualine_b [] :lualine_c []
    ;;                   :lualine_x [] :lualine_y [] :lualine_z []}
  }
  :config (fn [_ opts]
    (let [theme ((require :catppuccin.utils.lualine))
        catppuccin ((. (require :catppuccin.palettes) :get_palette))]
      (set opts.options.theme :catppuccin-nvim)
      (set theme.normal.c.bg catppuccin.base)
      (set theme.inactive.a.bg catppuccin.base)
      (set theme.inactive.b.bg catppuccin.base)
      (set theme.inactive.c.bg catppuccin.base)
      (let [(ok noice) (pcall require :noice)]
        (when ok
          ;; Noice status API fields are supplied by the plugin.
          (table.insert opts.sections.lualine_x
            {1 noice.api.status.message.get_hl :cond noice.api.status.message.has})
          (table.insert opts.sections.lualine_c
            {1 noice.api.status.mode.get :cond noice.api.status.mode.has
              :color {:fg "#ef9f76"}})
          (table.insert opts.sections.lualine_c
            {1 noice.api.status.command.get :cond noice.api.status.command.has
              :color {:fg "#ef9f76"}})
          (table.insert opts.sections.lualine_c
            {1 noice.api.status.search.get :cond noice.api.status.search.has
              :color {:fg "#ef9f76"}})))
      (let [(ok opencode) (pcall require :opencode)]
        (when ok
          (table.insert opts.sections.lualine_c [opencode.statusline])))
      ;; Disable breadcrumb navigation.
      (when false
        (set opts.sections.lualine_y
          [{1 (. (f-nav) :fun)
              :cond (. (f-nav) :cond)
              :navic_opts nil
              :separator {:left "" :right ""}
              :right_padding 2}]))
      (table.insert opts.sections.lualine_a
        {1 (. (muti-cursor-state) :fun)
          :cond (. (muti-cursor-state) :cond)})
      ;; Setup is provided by lualine.
      ((. (require :lualine) :setup) opts)
      (values)))}
