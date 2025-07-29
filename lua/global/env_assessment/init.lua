local twc = require 'util.functions'.three_way_compare

local ret = {
	os = {
		win = vim.fn.has("win32"),
		linux = vim.fn.has("unix"),
		mac = vim.fn.has("mac"),
	}
}

ret.required = {
	chack = function (self)
		local r = true
		for _, bin in ipairs(self.required) do
			local n = vim.fn.executable(bin)
			if n == 0 then
				vim.notify("Required binary not found: ".. bin, vim.log.levels.ERROR)
				r = false
			end
		end
		return r
	end,
	required = {
		'git',
        'lazygit',
        'rg',
		twc(ret.os.linux == 0,'make',nil)
	}
}



return ret
