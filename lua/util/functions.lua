local M = {}

function M.bind(func, ...)
	local arg = {...}
	return function ()
		func(unpack(arg))
	end
end

return M
