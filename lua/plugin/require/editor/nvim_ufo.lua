return {
	'kevinhwang91/nvim-ufo',
	event = 'BufRead',
	config = function()
		-- TODO: improve here
		vim.o.foldcolumn = '1' -- '0' is not bad
		vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
		vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
		vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
		vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
		vim.keymap.set('n', 'K', function()
			local winid = require('ufo').peekFoldedLinesUnderCursor()
			if not winid then
				-- choose one of coc.nvim and nvim lsp
				vim.lsp.buf.hover()
			end
		end)



		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true
		}

		require('ufo').setup()
	end,
	dependencies = { 'kevinhwang91/promise-async' }
}
