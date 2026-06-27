#!/usr/bin/env -S nvim -l

local ffi = require("ffi")

local is_stdin_tty = nil

if ffi.os == "Windows" then
    ffi.cdef [[
    int _isatty(int fd);
  ]]
    is_stdin_tty = function()
		return ffi.C._isatty(0) == 0
	end
else
    ffi.cdef [[
    int isatty(int fd);
  ]]
    is_stdin_tty = function() return ffi.C.isatty(0) == 0 end
end

local function execstr(str)
    local fn, err = loadstring(str)
    if fn then
        local result = fn()
        if result then print(result) end
        return result
    elseif err then
        io.stderr:write(err)
    end
end

local i = 1
while i <= #arg do
    local value = arg[i]
    if value == "-e" then
        execstr(arg[i + 1])
        i = i + 2
    else
        local fn, err = loadfile(value)
        if fn then
            local result = fn()
            if result then print(result) end
        elseif err then
            io.stderr:write(err)
        end
        i = i + 1
    end
end



