(λ get_spec []
  (let [scan (. (require :util.file_util) :scan_dir_for_module)
      directory (vim.fs.joinpath (vim.fn.stdpath :config) "fnl" "plugins" "require")]
    (icollect [_ module (ipairs (scan directory "plugins.require" ".fnl"))]
      (when (and (not= module "plugins.require")
          (not= module "plugins.require.lite_require"))
        {:import module}))))
; setup lazy
{:setup (λ []
    (let [lazy (require :lazy)
        plugin_config (require "plugins.config.init")
        api (require :hotpot.api)
        context (assert (api.context (vim.fn.stdpath :config)))]
      (plugin_config.setup)
      (lazy.setup
        {:dev {:path "~/Projects"}
          :git {:url_format (if options.git.use_ssh
              "git@github.com:%s.git"
              "https://github.com/%s.git")}
          :install {:colorscheme [:catppuccin]}
          :rocks {:enabled true
            :hererocks nil
            :root (.. (vim.fn.stdpath :data)
              :/lazy-rocks)
            :server "https://lumen-oss.github.io/rocks-binaries/"}
          :spec (if vim.g.lite_mode
            ; (require :plugins.require)
            {:import :plugins.require}
            (get_spec))
          :performance {:rtp {:paths [(context.locate :destination)]}}
          :ui {:border :rounded
            :title "Plugin Manager"
            :tittle_pos :center}})))
  :get_spec get_spec}
