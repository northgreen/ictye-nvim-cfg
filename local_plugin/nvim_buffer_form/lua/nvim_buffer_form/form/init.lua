local M = {
	opt = {}
}

function M:new(o,opt)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	o.opt = opt or {}
	return o
end


return function(o)
	return M:new(o)
end
