---@diagnostic disable-next-line duplicate-field
function vim.ui.select(items, opts, on_choice)
    opts = opts or {}

    --process the opt
    local prompt = vim.F.if_nil(opts.prompt, "Select one of")
    if prompt:sub(-1, -1) == ":" then prompt = prompt:sub(1, -2) end
    opts.format_item = vim.F.if_nil(opts.format_item, function(e) return tostring(e) end)
    on_choice = vim.schedule_wrap(on_choice)

    local Menu = require("nui.menu")

    local line = {}
    for _, value in ipairs(items) do
        local it = opts.format_item(value)
        table.insert(line, Menu.item(it, { v = value }))
    end

    --dynamicaly calculate the height of the popup window
    local win_h = vim.api.nvim_win_get_height(0)
    ---@type integer|string
    local h = '50%'
    if #line < win_h / 2 then
        h = #line
    end

    local popup_options = {
        relative = "editor",
        position = { row = "50%", col = "50%" },
        size = { width = '50%', height = h },
        border = {
            style = "rounded",
            text = { top = prompt, top_align = "center" }
        },
        win_options = { winhighlight = "Normal:Normal" }
    }

    local menu = Menu(popup_options, {
        lines = line,
        max_width = 20,
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>", "q" },
            submit = { "<CR>", "<Space>" }
        },
        on_close = function() on_choice(nil) end,
        on_submit = function(item) on_choice(item.v) end
    })

    menu:mount()
end
