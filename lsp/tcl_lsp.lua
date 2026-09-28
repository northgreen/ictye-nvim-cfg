---@brief
---
--- https://github.com/bitwisecook/tcl-lsp
---
--- `tcl-lsp-server`, a language server for Tcl (native Rust binary,
--- installed at ~/.local/bin/tcl-lsp-server by the release installer).
---
--- The editor language id picks the dialect: `tcl-expect` for `.exp`/`.expect`
--- and Expect shebangs, `tk` for `.tk` and `#!/usr/bin/wish` scripts.
--- Everything else is plain `tcl`, where the server detects the dialect from
--- a `# tcl-dialect:` directive, the shebang, or the extension.

local EXTENSION_LANGUAGE_IDS = {
	exp = 'tcl-expect',
	expect = 'tcl-expect',
	tk = 'tk',
}

local SHEBANG_LANGUAGE_IDS = {
	{ 'expect', 'tcl-expect' },
	{ 'wish', 'tk' },
	{ 'jimsh', 'tcl-jim' },
}

-- A `# tcl-dialect:` directive outranks the extension and the shebang on the
-- server side, so when one is present let the server read it: sending a
-- language id would pin the dialect above it.
local function has_dialect_directive(bufnr)
	for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)) do
		if line:match('^%s*#%s*tcl%-dialect:') then
			return true
		end
	end
	return false
end

---@param bufnr integer
---@param filetype string
---@return string
local function language_id(bufnr, filetype)
	if has_dialect_directive(bufnr) then
		return filetype
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	local extension = name:match('%.([%w_]+)$')
	if extension and EXTENSION_LANGUAGE_IDS[extension] then
		return EXTENSION_LANGUAGE_IDS[extension]
	end
	local shebang = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
	if shebang:sub(1, 2) == '#!' then
		for _, entry in ipairs(SHEBANG_LANGUAGE_IDS) do
			if shebang:find(entry[1], 1, true) then
				return entry[2]
			end
		end
	end
	return filetype
end

---@type vim.lsp.Config
return {
	cmd = { vim.fn.expand('~/.local/bin/tcl-lsp-server') },
	filetypes = { 'tcl' },
	root_markers = { 'tclpkg.tcl', '.git' },
	get_language_id = language_id,
	settings = { tclLsp = { dialect = 'tcl8.6' } },
}
