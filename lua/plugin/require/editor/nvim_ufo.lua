return {
	'kevinhwang91/nvim-ufo',
	event = 'BufRead',
	keys = require("core.keymap").ufo,
	config = function()
		-- TODO: improve here
		vim.o.foldcolumn = '1' -- '0' is not bad
		vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true
		}

		require('ufo').setup({})
	end,
	dependencies = {
    'kevinhwang91/promise-async',
  }
}
