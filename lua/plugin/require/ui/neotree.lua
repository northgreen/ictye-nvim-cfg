return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    -- lazy = false,
    event = 'VeryLazy',
    opts = function(_, opts)
        local function on_move(data)
            Snacks.rename.on_rename_file(data.source, data.destination)
        end
        local events = require("neo-tree.events")
        opts.event_handlers = opts.event_handlers or {}
        vim.list_extend(opts.event_handlers, {
            { event = events.FILE_MOVED,   handler = on_move },
            { event = events.FILE_RENAMED, handler = on_move },
        })

        opts.sources = {
            "filesystem",
            "buffers",
            "git_status",
            "document_symbols"
          }

        opts.document_symbols = {
          follow_cursor = true,
          kinds = {
            "Class",
            "Function",
            "Method",
            "Struct",
            "Interface"
          }
        }
        opts.filesystem = {
                hijack_netrw_behavior = "disabled",
                window = {
                    mappings = {
                        ["R"] = "easy",
                    },
                },
                commands = {
                    ["easy"] = function(state)
                        local node = state.tree:get_node()
                        local path = node.type == "directory" and node.path or vim.fs.dirname(node.path)
                        require("easy-dotnet").create_new_item(path, function()
                            require("neo-tree.sources.manager").refresh(state.name)
                        end)
                    end
                }
            }
    end
}
