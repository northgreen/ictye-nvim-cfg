--- @param node TSNode
--- @param buf string|integer
--- @return NazrinNodePos
return function(node, buf)
	local color_symbols = require('global.ui_util.nazrin.nazrin').color_icon
	local symbol = require('global.ui_util.nazrin.nazrin').symble_enum
	local get_name = require('global.ui_util.nazrin.nazrin.util.tsutil').get_name

	--- @type NazrinNodePos
    local pos = {}
    --- @type TSNode|nil
    local node_pos_state = node

	--- anaylize field,just it
    --- @param no TSNode
    --- @return string
    local function anaylize_field(no)
        assert(no:type() == 'field')
        local name_node = no:field('name')
        if #name_node < 1 then
            local index = 1
            for i in no:parent():iter_children() do
                if i:type() == 'field' then
                    if i == no then
                        return '[' .. index .. ']'
                    end
                    index = index + 1
                end
            end
            return '[?]'
        end
        return get_name(name_node[1], buf)
    end

    while node_pos_state ~= nil do
        local add = nil
        local type = node_pos_state:type()
        if type == 'assignment_statement' then
            -- anaylize assignment statement,we need the var list
            for i in node_pos_state:iter_children() do
                if i:type() == 'variable_list' then
                    add = color_symbols(symbol.field).. ' ' .. get_name(i, buf)
                    break
                end
            end
        elseif type == 'function_declaration' then
            -- anaylize function declaration,we need the function name,but it may be anonymous
            local name_node = node_pos_state:field('name')
            if #name_node < 1 then
                add = color_symbols(symbol.method).. ' '..'anonymous'
            else
                add = color_symbols(symbol.method).. ' '..get_name(name_node[1], buf)
                if #add < 2 then add = color_symbols(symbol.method).. ' '..'anonymous' end
            end
		elseif type =='function_definition' then
			-- anaylize function definition,we need the function name,but it may be anonymous
			add = color_symbols(symbol.method).. ' '..'<anonymous>'
        elseif type == 'if_statement' then
            -- if it is if statement,we need the if keyword
            add = color_symbols(symbol.key).. ' '.. 'if'
        elseif type == 'table_constructor' then
            -- table constructor,we need the table keyword,maybe also fuction call
            local tmp = node_pos_state:parent()
            if tmp ~= nil and tmp:type() == 'arguments' then
                add = color_symbols(symbol.array).. ' '.. get_name(tmp:parent():field('name')[1], buf)
            end
        elseif type == 'field' then
            -- field,we need the field name,or the index of it,because it is so troubling,I make it a function
			-- not too bad
            add = color_symbols(symbol.array).. ' '.. anaylize_field(node_pos_state)
        elseif type == 'return_statement' then
            -- return statement,we need the return keyword
            add = color_symbols(symbol.key).. ' '.. 'return'
		elseif type == 'identifier' then
			-- identifier,we need display it only if it is a parameters of a function
			local parent = node_pos_state:parent()
			if parent and (parent:type() == 'parameters') then
				add = color_symbols(symbol.consat).. ' '.. get_name(node_pos_state, buf)
			end
		elseif type == 'while_statement' then
			--- while
			add = color_symbols(symbol.key).. ' '.. 'while'
		elseif type == 'for_statement' then
			--- for
			add = color_symbols(symbol.key).. ' '.. 'for'
        end

		-- add the symbol to the pos list(if it is not nil)
        if add then
            table.insert(pos, 1, add)
        end

		-- raise the node to its parent
        node_pos_state = node_pos_state:parent()
    end
    return pos
end

