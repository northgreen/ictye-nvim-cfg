--- @return string
return function (name)
	return vim.fn.stdpath('config') .. "\\local_plugin\\" .. name
end
