--- @return LazyPluginSpec
return  {
        'luozhiya/fittencode.nvim',
		event = 'BufReadPre',
		config = function()
			require('fittencode').setup({
				completion_mode='source'
			})
		end
    }
