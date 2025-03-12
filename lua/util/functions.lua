local M = {}

---returns a function that calls the given function with the given arguments
---@param func function|table
---@param ... unknown
---@return function
function M.bind(func, ...)
    local arg = {...}
    return function() func(unpack(arg)) end
end

function M.lazy_require(m)
    return setmetatable({}, {
        __index = function(t, k)
            local module = require(m)
            rawset(t, k, module[k])
            return module[k]
        end
    })
end

function M.lazy_call(m, f)
    if type(m) == "string" then
        return function(...) return require(m)[f](...) end
	else
		return function(...) return m[f](...) end
    end
end

return M
