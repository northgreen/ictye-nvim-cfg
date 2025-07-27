local M = {}

function M.margetbl(tbl1, tbl2)
    local ret = {unpack(tbl1)}
    for i, v in ipairs(tbl2) do ret[i + #tbl1] = v end
    return ret
end

---returns a function that calls the given function with the given arguments
---@param func function|table
---@param ... unknown
---@return function
function M.bind(func, ...)
    local arg = {...}
    return function(...)
        local arg2 = {...}
        if #arg2 > 0 then arg = M.margetbl(arg, arg2) end
        func(unpack(arg))
    end
end

local c1 = {}
---returns a table that lazily loads the given module and caches the loaded module
---@param m string
---@return table
function M.lazy_require(m)
    if not c1[m] then
        c1[m] = setmetatable({}, {
            __index = function(t, k)
                local module = require(m)
                rawset(t, k, module[k])
                return module[k]
            end
        })
    end
    return c1[m]
end

function M.lazy_call(m, f)
    if type(m) == "string" then
        return function(...) return require(m)[f](...) end
    else
        return function(...) return m[f](...) end
    end
end

local c2 = {}
---garanties that the given function is called only once
---@param module string|table
---@param func_desc string[]
---@return function
function M.lazy_function_call(module, func_desc)
    local twc = M.three_way_compare
    return function(...)
        module = twc(type(module) == "string",
                     function() return require(module --[[@as string]]) end,
                     function() return module end)()
        local signature = tostring(module) .. table.concat(func_desc, "")

        if not c2[signature] then
            local _module = module
            local fun = _module
            for _, v in ipairs(func_desc) do fun = fun[v] end
            c2[signature] = fun
        end

        local args = {...}
        return c2[signature](unpack(args))
    end
end

--- a three way compare function, returns the first argument if it is true
--- @param condation boolean
--- @param positive any
--- @param negative any
--- @return any
function M.three_way_compare(condation, positive, negative)
    if condation then
        return positive
    else
        return negative
    end
end

function M.judge_and_use(condation, negative)
    if condation then return condation end
    return negative
end

return M
