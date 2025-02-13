--- use https://github.com/nvimdev/dashboard-nvim to create a dashboard with a custom header
local miku = {
"          /＾>》, -‐＜＾}          ",
"        ./:::/,≠´::;::ヽ.          ",
"        /:::〃:::／}::丿ハ         ",
"      ./:::/:::／  ﾉ／ }::}        ",
"     /:::/瓜 イ ＞ ´＜  |':ﾉ      " ,
"　  ./:::|ﾍ.{､ ( ﾌ    ノﾉイ        ",
"    |::::| ／}｀ｽ/￣￣￣￣/        ",
" .　|::::|(_::つ/        /　click! ",
"    .￣￣￣￣＼/＿＿＿＿/￣￣￣￣￣",
}

--- @return LazyPluginSpec
return {
        'nvimdev/dashboard-nvim',
        event = 'VimEnter',
        config = function()
        require('dashboard').setup {
            theme = 'hyper',
            config = {
				header = miku,
				disable_move = true,
				shortcut = {
					{ desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
			},
			hide = {
				tabline = true,
				statusline = true,
				winbar = true,
			},
		}
	}
    end,
        dependencies = {
			{ 'nvim-tree/nvim-web-devicons' }
		}
    }
