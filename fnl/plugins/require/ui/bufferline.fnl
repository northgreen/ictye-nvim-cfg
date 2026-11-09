;; Use akinsho/bufferline.nvim to show the bufferline in Neovim.
{1 :akinsho/bufferline.nvim
  :version "*"
  :enabled (not (or _G.options.env_var.firenvim _G.options.env_var.vscode))
  ;; :enabled false
  :event :VeryLazy
  :keys (. (require :core.keymap) :bufferline)
  :dependencies [:catppuccin/nvim :nvim-tree/nvim-web-devicons :catppuccin/nvim]
  :opts {:options {:themeable true
      :numbers (λ [opts]
        (string.format "%s.%s" opts.ordinal (opts.raise opts.id)))
      :offsets [{:filetype :NvimTree :text "󰙅  File Explorer"}
        {:filetype :neo-tree}
        {:filetype :Outline :text "  Outline"}
        {:filetype :Dashboard :text "  Dashboard"}
        {:filetype :opencode_terminal :text :OpenCode}]
      :diagnostics :nvim_lsp
      :indicator {:icon "▎"}
      :color_icons false}}
  :config (λ [_ opts]
    (let [frappe ((. (require :catppuccin.palettes) :get_palette) :frappe)
        highlights ((. (require :catppuccin.special.bufferline) :get_theme)
          {:styles [:boid :italic]
            :custom {:frappe {:fill {:bg frappe.crust}}}})
        bufferline (require :bufferline)]
      (set opts.highlights highlights)
      (bufferline.setup opts)
      (set _G.nvim_bufferline ((require :util.bufferline_render) _G.nvim_bufferline))
      (vim.api.nvim_create_autocmd [:BufAdd :BufDelete]
        {:callback (λ []
            (vim.schedule (λ []
                (pcall _G.nvim_bufferline))))})))}
