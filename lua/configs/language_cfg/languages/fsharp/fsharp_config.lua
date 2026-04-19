-- F# LSP configuration
-- Note: For Godot projects, ensure GodotSharp is properly referenced in the project file
local dap = require("dap")

-- DAP configuration
dap.configurations.fsharp = {
  {
    name = "Launch file",
    type = "coreclr",
    request = "launch",
    preLaunchTask = "build",
    program = function()
      return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}