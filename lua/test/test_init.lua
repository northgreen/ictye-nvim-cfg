-- some test code for fun
-- require 'test.notify_test'

vim.api.nvim_create_user_command('TestFunction',function ()
	vim.notify("Doing some test function")

	local wins = vim.api.nvim_list_wins()
	for _,win in ipairs(wins) do
		-- print the type of win
		local buf = vim.api.nvim_win_get_buf(win)
		print(vim.bo[buf].filetype)
	end
end,{})

require "test.form"

