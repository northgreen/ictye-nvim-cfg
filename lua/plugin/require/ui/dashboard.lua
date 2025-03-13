--- use https://github.com/nvimdev/dashboard-nvim to create a dashboard with a custom header
local miku = {
	"          /＾>》, -‐＜＾}          ",
	"        ./:::/,≠´::;::ヽ.          ",
	"        /:::〃:::／}::丿ハ         ",
	"      ./:::/:::／  ﾉ／ }::}        ",
	"      /:::/瓜イ ＞ ´＜  |':ﾉ      ",
	"　  ./:::|ﾍ.{､ ( ﾌ    ノﾉイ        ",
	"    |::::| ／}｀ｽ/￣￣￣￣/        ",
	" .　|::::|(_::つ/        /　click! ",
	"    .￣￣￣￣＼/＿＿＿＿/￣￣￣￣￣"
}

return {
	'nvimdev/dashboard-nvim',
	event = 'VimEnter',
	opts = {
		theme = 'hyper',
		shortcut_type = 'number',
		change_to_vcs_root = true,
		config = {
			header = miku,
			disable_move = true,
			shortcut = {
				{
					desc = '󰚰 Update',
					group = '@property',
					action = 'Lazy update',
					key = 'u'
				},
				{
					desc = ' Lazy',
					group = '@property',
					action = 'Lazy',
					key = 'l'
				},
				{
					desc = ' Search',
					group = '@property',
					action = 'Telescope',
					key = 's'
				}
			},
			hide = {tabline = true, statusline = true, winbar = true}
		}
	},
	dependencies = {{'nvim-tree/nvim-web-devicons'}}
}
