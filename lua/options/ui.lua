local bread_nav_options = require 'options.option_util.bread_nev_options'

--- @class IcyueUIOptions
return {
    types = {bread_nav_options = bread_nav_options},
	--- bread navigation option,will used to show symbols in statusline
    --- @type function
    bread_nav = bread_nav_options.navic,
    nav_option = {sparator = ' < '},
	dapui = {
		autoclose = false,
		autoopen = true,
	},
    symbal_map = {
        File = ' ',
        Module = ' ',
        Namespace = ' ',
        Package = ' ',
        Class = ' ',
        Method = ' ',
        Property = ' ',
        Field = ' ',
        Constructor = ' ',
        Enum = ' ',
        Interface = ' ',
        Function = ' ',
        Variable = ' ',
        Constant = ' ',
        String = ' ',
        Number = ' ',
        Boolean = ' ',
        Array = ' ',
        Object = ' ',
        Key = ' ',
        Null = ' ',
        EnumMember = ' ',
        Struct = ' ',
        Event = ' ',
        Operator = ' ',
        TypeParameter = ' '
    },
	ui_options = {
		noise = true
	}
}
