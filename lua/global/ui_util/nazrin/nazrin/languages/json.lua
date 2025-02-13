--- @param node TSNode
--- @param buf string|integer
--- @return NazrinNodePos
return function(node, buf)
    local color_symbols = require('global.ui_util.nazrin.nazrin').color_icon
    local symbol = require('global.ui_util.nazrin.nazrin').symble_enum
    local get_name =
        require('global.ui_util.nazrin.nazrin.util.tsutil').get_name

    local json_type = {
        number = symbol.numberic,
        string = symbol.str,
        boolean = symbol.boolean,
        null = symbol.variable,
        array = symbol.array,
        object = symbol.namespace
    }

    --- @type NazrinNodePos
    local pos = {}
    --- @type TSNode|nil
    local node_pos_state = node

    while node_pos_state ~= nil do
        local add = nil
        local type = node_pos_state:type()

        if type == 'pair' then
            -- we need depend the type of key to deside the type
            local key = node_pos_state:field('key')[1]
            local value = node_pos_state:field('value')[1]

            --- @type NazrinIconSymble
            local ty

            if value and
                (value:type() == 'string' or value:type() == 'number' or
                    value:type() == 'object' or value:type() == 'array' or
                    value:type() == 'null') then
                ty = json_type[value:type()]
            elseif value and (value:type() == 'true' or value:type() == 'false') then
                ty = json_type['boolean']
            end

            if key and key:type() == 'string' then
                local k = key:child(1)
                if k then
                    add = color_symbols(ty) .. " " .. get_name(k, buf)
                end
            end
        else
            local parent = node_pos_state:parent()
            if parent and parent:type() == 'array' then
                local r = 0
                for i in parent:iter_children() do
                    local t = i:type()
                    if t == 'number' or t == 'string' or t == 'true' or t ==
                        'false' or t == 'null' or t == 'object' or t == 'array' then
                        r = r + 1
                        if i == node_pos_state then
                            local ty
                            if i and
                                (i:type() == 'string' or i:type() ==
                                    'number' or i:type() == 'object' or
                                    i:type() == 'array' or i:type() ==
                                    'null') then
                                ty = json_type[i:type()]
                            elseif i and
                                (i:type() == 'true' or i:type() ==
                                    'false') then
                                ty = json_type['boolean']
                            end

                            add = color_symbols(ty) .. " " .. r
                            break
                        end
                    end
                end
            end
        end

        if add then table.insert(pos, 1, add) end
        node_pos_state = node_pos_state:parent()
    end
    return pos
end

