{1 :nvim-neo-tree/neo-tree.nvim
 :branch :v3.x
 :dependencies [:nvim-lua/plenary.nvim
                :MunifTanjim/nui.nvim
                :nvim-tree/nvim-web-devicons] ; Optional, but recommended.
 ;; :lazy false
 :event :VeryLazy
 :opts (fn [_ opts]
         (fn on-move [data]
           (_G.Snacks.rename.on_rename_file data.source data.destination)
           (values))
         (let [events (require :neo-tree.events)]
           (set opts.event_handlers (or opts.event_handlers {}))
           (vim.list_extend opts.event_handlers
                            [{:event events.FILE_MOVED :handler on-move}
                             {:event events.FILE_RENAMED :handler on-move}])
           (set opts.sources [:filesystem :buffers :git_status :document_symbols])
           (set opts.document_symbols {:follow_cursor true
                                       :kinds [:Class :Function :Method :Struct :Interface]})
           (set opts.filesystem
                {:hijack_netrw_behavior :disabled
                 :window {:mappings {:R :easy}}
                 :commands {:easy (fn [state]
                                    (let [node (: state.tree :get_node)
                                          path (or (and (= node.type :directory) node.path)
                                                   (vim.fs.dirname node.path))]
                                      ((. (require :easy-dotnet) :create_new_item)
                                       path
                                       (fn []
                                         ((. (require :neo-tree.sources.manager) :refresh) state.name)
                                         (values)))
                                      (values)))}})
           (values)))}
