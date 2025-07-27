if _G.configed[vim.bo.filetype] then
  return
end
_G.configed[vim.bo.filetype] = true

local dap = require('dap')
dap.adapters.haskell = {
  type = 'executable';
  command = 'C:\\Users\\north\\AppData\\Local\\nvim-data\\mason\\bin\\haskell-debug-adapter.cmd';
    args = {'--hackage-version=0.0.33.0'};
}

dap.configurations.haskell = {
  {
    type = 'haskell',
    request = 'launch',
    name = 'Debug',
    workspace = '${workspaceFolder}',
    startup = "${file}",
    stopOnEntry = true,
    logFile = vim.fn.stdpath('data') .. '/haskell-dap.log',
    logLevel = 'WARNING',
    ghciEnv = vim.empty_dict(),
    ghciPrompt = "λ: ",
    -- Adjust the prompt to the prompt you see when you invoke the stack ghci command below 
    ghciInitialPrompt = "λ: ",
    ghciCmd= "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
  },
}
