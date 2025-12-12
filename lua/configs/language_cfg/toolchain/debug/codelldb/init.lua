local dap = require('dap')
dap.adapters.codelldb = {
    type = "executable",
	command = "codelldb"
	-- detached = false
}
