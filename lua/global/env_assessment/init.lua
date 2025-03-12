local ret = {
	os = {
		win = vim.fn.has("win32"),
		linux = vim.fn.has("unix"),
		mac = vim.fn.has("mac"),
	},
	env = {
		software = {

		}
	}
}

return ret
