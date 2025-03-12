--- @return LazyPluginSpec
local opsympal = options.ui.symbal_map
return {
    "hedyhli/outline.nvim",
	cmd = {
		'Outline',
		'OutlineOpen',
		'OutlineClose',
		'OutlineFocus',
		'OutlineFollow',
		'OutlineStatus',
		'OutlineRefresh',
		'OutlineFocusCode',
		'OutlineFocusOutline'
	},
    opts = {
        symbols = {
            icons = {
                File = {icon = opsympal.File, hl = 'Identifier'},
                Module = {icon = opsympal.Module, hl = 'Include'},
                Namespace = {icon = opsympal.Namespace, hl = 'Include'},
                Package = {icon = opsympal.Package, hl = 'Include'},
                Class = {icon = opsympal.Class, hl = 'Type'},
                Method = {icon = opsympal.Method, hl = 'Function'},
                Property = {icon = opsympal.Property, hl = 'Identifier'},
                Field = {icon = opsympal.Field, hl = 'Identifier'},
                Constructor = {icon = opsympal.Constructor, hl = 'Special'},
                Enum = {icon = opsympal.Interface, hl = 'Type'},
                Interface = {icon = opsympal.Interface, hl = 'Type'},
                Function = {icon = opsympal.Function, hl = 'Function'},
                Variable = {icon = opsympal.Variable, hl = 'Constant'},
                Constant = {icon = opsympal.Constant, hl = 'Constant'},
                String = {icon = opsympal.String, hl = 'String'},
                Number = {icon = opsympal.Number, hl = 'Number'},
                Boolean = {icon = opsympal.Boolean, hl = 'Boolean'},
                Array = {icon = opsympal.Array, hl = 'Constant'},
                Object = {icon = opsympal.Object, hl = 'Type'},
                Key = {icon = opsympal.Key, hl = 'Type'},
                Null = {icon = opsympal.Null, hl = 'Type'},
                EnumMember = {icon = opsympal.EnumMember, hl = 'Identifier'},
                Struct = {icon = opsympal.Struct, hl = 'Structure'},
                Event = {icon = opsympal.Event, hl = 'Type'},
                Operator = {icon = opsympal.Operator, hl = 'Identifier'},
                TypeParameter = {icon = opsympal.TypeParameter, hl = 'Identifier'},
                Component = {icon = '󰅴', hl = 'Function'},
                Fragment = {icon = '󰅴', hl = 'Constant'},
                TypeAlias = {icon = ' ', hl = 'Type'},
                Parameter = {icon = opsympal.TypeParameter, hl = 'Identifier'},
                StaticMethod = {icon = ' ', hl = 'Function'},
                Macro = {icon = ' ', hl = 'Function'}
            }
        }
    }
}
