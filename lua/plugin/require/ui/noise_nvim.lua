return {
  enabled = (not vim.g.started_by_firenvim) and options.ui.ui_options.noise,
  -- enabled = false,
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true
      },
      documentation = {
        view = "hover",
        opts = {
          lang = "markdown",
          replace = true,
          render = "plain",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 }
        }
      }
    },
    notify = {
      enabled = true,
    },
    cmdline = {
      view = "cmdline",
    },
    messages = {
      enabled = true,
    },
    presets = {
      bottom_search = false,
      command_palette = false,
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = true
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
      kind_icons = {}
    },
    redirect = { view = "popup", filter = { event = "msg_show" } },
    views = {
      notify = {
        render = 'compact',
        timeout = 500,
        top_down = false,
        stages = "slide",
        animate = false,
      },
      cmdline_popup = {
        position = {
          row = -3,
          col = -1,
        },
      },
    },
    health = {
      checker = false,       -- conflicts with snacks
    },
    commands = {},
    routes = {
      {
        filter = { event = "msg_show", kind = "", find = "written" },
        opts = { skip = true }
      },
      {
        filter = { event = "msg_show", kind = "search_count" },
        opts = { skip = true }
      }
    }
  },
  dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }
}
