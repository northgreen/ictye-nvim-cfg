local function script_path()
    local str = debug.getinfo(1, 'S').source:sub(2)
    return str:match('(.*[/ \\])') -- 删除后面的文件，只保留路径
end

return script_path()

