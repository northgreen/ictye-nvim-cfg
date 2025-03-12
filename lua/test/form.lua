local LineInput = {}

function LineInput:new(o,cfg)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

local Form = {
	buf = 0,
	mark_namespace = 0,
	_context = {
		extmarks = {}
	}
}

function Form:new(o,form)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.buf = vim.api.nvim_create_buf(false, true)

    o.mark_namespace = vim.api.nvim_create_namespace("")
    vim.api.nvim_buf_set_lines(o.buf, 0, -1, false, {"", ""})
    return o
end

function Form:show()
    vim.api.nvim_buf_set_extmark(self.buf, self.mark_namespace, 0, 0, {
        end_row = 0,
        end_col = 0,
        virt_text = {{"Form Tittle", "Identifier"}},
        virt_text_pos = "overlay"
    })
    vim.api.nvim_buf_set_extmark(self.buf, self.mark_namespace, 1, 0, {
        end_row = 1,
        end_col = 0,
        virt_lines = {{{"  >" .. "Form Input 1", "Identifier"}}},
        virt_lines_above = true,
        virt_lines_leftcol = true,
        right_gravity = false
    })
    vim.api.nvim_buf_set_extmark(self.buf, self.mark_namespace, 1, 0, {
        end_row = 2,
        end_col = 0,
        virt_text = {{"tip1", "Comment"}},
        virt_text_pos = "overlay"
    })

	local function protect(line,buf)
		if vim.api.nvim_buf_get_lines(buf,line-1,line,false)[1] ~= "" then
			vim.api.nvim_buf_set_lines(buf,line-1,line,false,{""})
		end
	end
	vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"},{
		buffer = self.buf,
		callback = function()
			protect(1,self.buf)
		end
	})
    print("show form")
end

vim.api.nvim_create_user_command('Form', function()
    local f = Form:new()

    local win = vim.api.nvim_open_win(f.buf, true, {split = "right"})

    vim.api.nvim_set_option_value("number", false, {win = win})
    vim.api.nvim_set_option_value("relativenumber", false, {win = win})
    vim.api.nvim_set_option_value("wrap", false, {win = win})
    f:show()
end, {})
