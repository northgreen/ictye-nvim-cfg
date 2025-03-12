local M = {}
local Menu = require("nui.menu")

--- @type QuickMenuOpt
local default_opt = {
    opt = {},
    keymap = {
        focus_next = {"j", "<Down>", "<Tab>"},
        focus_prev = {"k", '<Up>', '<S-Tab>'},
        close = {"<Esc>", "<C-c>", '<F5>', "q"},
        submit = {"<CR>", "<Space>"}
    },
    style = {
        relative = 'editor',
        position = "50%",
        size = {width = 40, height = 10},
        border = {
            style = "single",
            text = {top = "[QuickCommond]", top_align = "center"}
        },
		win_options = {winhighlight = "Normal:Normal,FloatBorder:Normal"}
    }
}

M.opt = {}

--- @return NuiTree.Node
local function get_line(menu)
    local lines = {}
    for _, line in ipairs(menu) do
        if type(line) == "string" then
            table.insert(lines, Menu.separator(line, {
                char = "-",
                text_align = "center"
            }))
        elseif type(line) == "table" then
            for key, opt in pairs(line) do
                table.insert(lines, 1, Menu.item(key, {opt = opt}))
            end
        end
    end
    return lines
end

function M.menu()
    local menu = Menu(M.opt.style, {
        lines = get_line(M.opt.opt),
        max_width = 50,
        keymap = M.opt.keymap,
        on_submit = function(item) item.opt() end
    })
    menu:mount()
end

function M.setup(opt)
	M.opt = vim.tbl_deep_extend("force", default_opt, opt or {})

    vim.api.nvim_create_user_command('QuickMenu', function() M.menu() end, {})
end

return M
