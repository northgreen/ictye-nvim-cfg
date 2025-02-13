--- @return LazyPluginSpec
return  {
        'luozhiya/fittencode.nvim',
		event = 'VeryLazy',
		config = function()
			require('fittencode').setup({
				completion_mode='source'
			})
		end
    }
