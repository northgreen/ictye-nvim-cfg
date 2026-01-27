--- Return a quickmenu object

local Menu = require("nui.menu")
local t = require("util.functions").three_way_compare

--- the function to get the lines of the menu
--- @param menu any
--- @return NuiMenu
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

--- Default options
local default_opt = {
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
    },
}

--- Create a quickmenu object
--- @param menu table | nil
--- @param opt table | nil
return function (menu,opt)
    opt = t(opt == nil,default_opt,opt)
    menu = t(menu == nil,{},menu)

    return Menu(opt.style, {
        lines = get_line(menu),
        max_width = 50,
        keymap = opt.keymap,
        on_submit = function(item) item.opt() end
    })
end
