--- @return LazyPluginSpec
return  {
        'luozhiya/fittencode.nvim',
		event = 'BufReadPre',
        opts = {
				completion_mode='source'
        }
}
