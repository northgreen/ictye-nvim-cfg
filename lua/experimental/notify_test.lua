-- Created by: ictye
-- costome notify fuctioin for neovim,display message in a window with title and level

local vim_level = vim.log.levels

vim.notify = function(msg, level, opt)
	local len = string.len(msg)
	local msg_dic = string.gmatch(msg,'[^\n]+')

	local tittle = 'Notify'
	if level == vim_level.INFO then
		tittle = 'Info'
	elseif level == vim_level.WARN then
		tittle = 'Warning'
	elseif level == vim_level.ERROR then
		tittle = 'Error'
	else
		tittle = 'Notify'
	end

	local whidth = vim.api.nvim_win_get_width(0)
	local height = vim.api.nvim_win_get_height(0)

	local max_line_length = 0
	for _, line in msg_dic do
		if line and #line > max_line_length then
			max_line_length = #line
			end
	end


	local win_width = math.min(#msg + 2, whidth-4)
	local win_height = math.min(max_line_length + 1, height-4)

	local row = height - win_height - 1
	local col = whidth - win_width - 1

    local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {msg})
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'win',
        row = row,
        col = col,
        width = win_width,
        height = win_height,
		border = 'rounded',
		style = 'minimal',
		title = tittle,
		focusable = false,
    })
	vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>q!<CR>', {noremap = true, silent = true})
	vim.defer_fn(function ()
		pcall(vim.api.nvim_win_close, win, true)
	end,math.max(math.min(len*500,2500),8000))
end
