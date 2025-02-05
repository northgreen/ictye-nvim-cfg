
local miku = {
"          /＾>》, -‐＜＾}          ",
"        ./:::/,≠´::;::ヽ.          ",
"        /:::〃:::／}::丿ハ         ",
"      ./:::/:::／  ﾉ／ }::}        ",
"　　  /:::/瓜イ ＞ ´＜  |':ﾉ        ",
"　  ./:::|ﾍ.{､ ( ﾌ    ノﾉイ        ",
"    |::::| ／}｀ｽ/￣￣￣￣/        ",
" .　|::::|(_::つ/        /　click! ",
"    .￣￣￣￣＼/＿＿＿＿/￣￣￣￣￣",
}


return {
    cfg = function()
        require('dashboard').setup {
            theme = "hyper",
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
    end
}
