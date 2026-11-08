;; Use nvimdev/dashboard-nvim to create a dashboard with a custom header.
(fn dashboard-header []
  (let [header (. (require :global.ui_util.ascii_arts) :each)]
    (. header (math.random (length header)))))

;; @return LazyPluginSpec
{1 :nvimdev/dashboard-nvim
 :event :VimEnter
 :opts {:theme :hyper
        :shortcut_type :number
        :change_to_vcs_root true
        :config {:header (dashboard-header)
                 :disable_move true
                 :shortcut [{:desc "󰚰 Update" :group "@property" :action "Lazy update" :key :u}
                            {:desc " Lazy" :group "@property" :action :Lazy :key :l}
                            {:desc " Search" :group "@property" :action :Telescope :key :s}]
                 :hide {:tabline true :statusline true :winbar true}}}
 :dependencies [[:nvim-tree/nvim-web-devicons]]}
