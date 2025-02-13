local M = {}
local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local trouble = require("trouble")
local bind = require 'util.functions'.bind

--- @return NuiTree.Node
local function get_line(menu)
    local lines = {}
    for _,line in ipairs(menu) do
        if type(line) == "string" then
            table.insert(lines, Menu.separator(line, {
                char = "-",
                text_align = "center"
            }))
		elseif type(line) == "table" then
			for key,opt in pairs(line) do
				table.insert(lines,1, Menu.item(key,{opt = opt}))
			end
        end
    end
    return lines
end

local menu_opts = {
	{
		["Search"] = require 'telescope.builtin'.builtin,
		["Questions"] = bind(trouble.open, "questions"),
		["Find and Replace"] = bind(vim.cmd, "GrugFar"),
		["Find in Files"] = bind(vim.cmd, "RipSubstitute"),
		["Terminal"] = bind(vim.cmd, "FloatermNew powershell"),
		["Git"] = bind(vim.cmd, "LazyGit"),
		["Debug"] = bind(vim.cmd, "DapNew"),
	}
}



local l = get_line(menu_opts)
local menu = Menu({
    position = "50%",
    size = {width = 25, height = 5},
    border = {
        style = "single",
        text = {top = "[QuickCommond]", top_align = "center"}
    },
    win_options = {winhighlight = "Normal:Normal,FloatBorder:Normal"}
}, {
    lines = l,
    max_width = 50,
    keymap = {
        focus_next = {"j", "<Down>", "<Tab>"},
        focus_prev = {"k", '<Up>', '<S-Tab>'},
        close = {"<Esc>", "<C-c>",'<F5>', "q"},
        submit = {"<CR>", "<Space>"}
    },
    on_submit = function(item) item.opt() end
})

function M.menu() menu:mount() end

return M
