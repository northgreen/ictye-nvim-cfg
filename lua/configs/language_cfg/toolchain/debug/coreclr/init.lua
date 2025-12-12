local dap = require("dap")

dap.adapters.coreclr = {
    type = "executable",
	command = "netcoredbg",
    arg = {
        "--interpreter=vscode"
    }
}

dap.adapters.godot_mono = {
    type = "executable",
	command = "netcoredbg",
    arg = {
        "--interpreter=vscode"
    }
}
