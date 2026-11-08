(local twc (. (require :util.functions) :three_way_compare))

{1 :yetone/avante.nvim
 :event :VeryLazy
 :version false
 :enabled (= _G.options.llm_config.use_plugin :avnate)
 :opts {;; provider = "opencode"
        :provider :pi
        ;; provider = "deepseek"
        :system_prompt (fn []
                         (let [hub ((. (require :mcphub) :get_hub_instance))]
                           (or (and hub (: hub :get_active_servers_prompt)) "")))
        :custom_tools (fn []
                        [((. (require :mcphub.extensions.avante) :mcp_tool))])
        :web_search_engine {:provider :searchapi}
        :providers ((. (require :global.llm_modules) :get_avnate))
        :acp_providers (. (require :global.agents) :lists)
        :shortcuts [{:name :jci
                     :describe "Commit with jujutsu"
                     :details "commit with jujutsu"
                     :prompt "Use jj diff to view differences and gengrate commit message, then use jj commit to commit changes."}]}
 :build (twc (= _G.options.env.os.win 1)
             "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
             :make)
 :dependencies [{1 :ColinKennedy/mega.cmdparse
                 :dependencies [:ColinKennedy/mega.logging]}
                :stevearc/dressing.nvim
                :nvim-lua/plenary.nvim
                :MunifTanjim/nui.nvim
                :echasnovski/mini.pick
                :nvim-telescope/telescope.nvim
                :ibhagwan/fzf-lua
                :nvim-tree/nvim-web-devicons
                :zbirenbaum/copilot.lua
                {1 :HakonHarnes/img-clip.nvim
                 :event :VeryLazy
                 :opts {:default {:embed_image_as_base64 false
                                  :prompt_for_file_name false
                                  :drag_and_drop {:insert_mode true}
                                  :use_absolute_path true}}}
                {1 :MeanderingProgrammer/render-markdown.nvim
                 :opts {:file_types [:markdown :Avante]}
                 :ft [:markdown :Avante]}]}
