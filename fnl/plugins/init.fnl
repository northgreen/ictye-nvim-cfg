; setup lazy
{
  :setup (fn []
    (let [lazy (require :lazy)
          plugin_config (require "plugins.config.init")]
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
                  (require :plugin.require.lite_require) 
                  (vim.list_extend
                    (require :plugin.require.require)
                    (require :plugins.require)))
        :ui  {:border :rounded
              :tittle "Plugin Manager"
              :tittle_pos :center}})))
}
