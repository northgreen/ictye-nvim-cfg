local M = {}

--- @enum NazrinSupportedLanguages
M.language = {lua = 'lua', json = 'json'}

M.symble_map = {
    array = '',
    consat = '',
    field = '',
    method = '',
    keyword = '',
    md_symbol = '󱔁',
    boolean = '',
    class = '',
    color = '',
    enum = '',
    event = '',
    file = '',
    interface = '',
    key = '',
    misc = '',
    namespace = '',
    numberic = '',
    operator = '',
    parameter = '',
    property = '',
    ruler = '',
    snippet = '',
    str = '',
    struct = '',
    variable = '',
    enum_member = ''
}

--- @enum NazrinIconSymble
M.symble_enum = {
    array = 'array',
    consat = 'consat',
    field = 'field',
    method = 'method',
    keyword = 'keyword',
    md_symbol = 'md_symbol',
    boolean = 'boolean',
    class = 'class',
    color = 'color',
    enum = 'enum',
    event = 'event',
    file = 'file',
    interface = 'interface',
    key = 'key',
    misc = 'misc',
    namespace = 'namespace',
    numberic = 'numberic',
    operator = 'operator',
    parameter = 'parameter',
    property = 'property',
    ruler = 'ruler',
    snippet = 'snippet',
    str = 'str',
    struct = 'struct',
    variable = 'variable',
    enum_member = 'enum_member'
}

M.color_map = {
    array = '#ffffff',
    consat = '#ffffff',
    field = '#ffffff',
    method = '#ffffff',
    keyword = '#ffffff',
    md_symbol = '#ffffff',
    boolean = '#ffffff',
    class = '#ffffff',
    color = '#ffffff',
    enum = '#ffffff',
    event = '#ffffff',
    file = '#ffffff',
    interface = '#ffffff',
    key = '#ffffff',
    misc = '#ffffff',
    namespace = '#ffffff',
    numberic = '#ffffff',
    operator = '#ffffff',
    parameter = '#ffffff',
    property = '#ffffff',
    ruler = '#ffffff',
    snippet = '#ffffff',
    str = '#ffffff',
    struct = '#ffffff',
    variable = '#ffffff',
    enum_member = '#ffffff'
}

--- @type boolean
M.color_flag = false

--- return the color icon of the given name
--- @param name NazrinIconSymble
--- @return string
function M.color_icon(name)
    if M.color_flag then
        local c_map = M.color_map
        local r = tonumber(c_map[name]:sub(2, 3), 16)
        local g = tonumber(c_map[name]:sub(4, 5), 16)
        local b = tonumber(c_map[name]:sub(6, 7), 16)
        local color = string.format('\27[38;2;%d;%d;%dm', r, g, b)
        local reset = '\27[0m'
        return color .. M.symble_map[name] .. reset
    else
        return M.symble_map[name]
    end

end

--- @param lang NazrinSupportedLanguages|nil
--- @param node TSNode
--- @param buf string|integer
--- @return NazrinNodePos
function M.get_cursor_location(lang, node, buf)
    if lang == M.language.lua then
        return require('global.ui_util.nazrin.nazrin.languages.lua')(node, buf)
    elseif lang == M.language.json then
        return require('global.ui_util.nazrin.nazrin.languages.json')(node, buf)
    end
    return {lang}
end

--- @param location NazrinNodePos
--- @param split_char string
--- @return string
function M.format_location(location, split_char)
    --- @type string
    local formatted_location = ''
    if #location <= 0 then return '...' end
    for i, v in ipairs(location) do
        if i == 1 then
            formatted_location = v
        else
            formatted_location = formatted_location .. split_char .. v
        end
    end
    return formatted_location
end

--- @return NazrinSupportedLanguages|nil
function M.get_file_type()
    local lang = vim.bo.filetype
    if lang == 'lua' then
        return M.language.lua
    elseif lang == 'json' then
        return M.language.json
    else
        return nil
    end
end

M.ui_support = {
    lualine = require 'global.ui_util.nazrin.nazrin.support.lualine'
}

return M
